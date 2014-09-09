//
//  CDKNetworkResponse.m
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "CDKNetworkResponse.h"
#import "CDKNetworkGlobals.h"
#import "NSError+Additions.h"

@implementation CDKNetworkResponse

+ (CDKNetworkResponse *)responseWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    CDKNetworkResponse *resp = [[CDKNetworkResponse alloc] initWithResponse:response rawData:data];
    return resp;
}

- (id)initWithResponse:(NSHTTPURLResponse *)response rawData:(NSData *)data
{
    if (self = [super initWithURL:response.URL statusCode:response.statusCode HTTPVersion:@"HTTP/1.1" headerFields:response.allHeaderFields])
    {
        _rawData = [data copy];
        
        // handle any error responses
        if (self.statusCode > 299)
        {
            NSString *localizedDescription = nil;
            switch (response.statusCode)
            {
                case CDKNetworkHTTPStatusCodeRedirection:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_300", nil, [NSBundle mainBundle], @"301 Moved Permanently", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeNotModified:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_304", nil, [NSBundle mainBundle], @"Not Modified", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeClientError:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_400", nil, [NSBundle mainBundle], @"400 Client Error", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeClientUnauthorized:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_401", nil, [NSBundle mainBundle], @"401 Unauthorized", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodePaymentRequired:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_402", nil, [NSBundle mainBundle], @"Payment Required", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeNotFound:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_404", nil, [NSBundle mainBundle], @"Not Found", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeMethodNotAllowed:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_405", nil, [NSBundle mainBundle], @"Method Not Allowed", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeServerError:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_500", nil, [NSBundle mainBundle], @"500 Internal Server Error", nil);
                    break;
                    
                case CDKNetworkHTTPStatusCodeNotImplemented:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_501", nil, [NSBundle mainBundle], @"Not Implemented", nil);
                    break;
                    
                default:
                    localizedDescription = NSLocalizedStringWithDefaultValue(@"MKN_CONNECTION_MANAGER_ERROR_UNKNOWN", nil, [NSBundle mainBundle], @"Unknown Error", nil);
                    break;
            }
            
            self.error = [NSError errorWithDomain:CDKNetworkErrorDomain code:response.statusCode localizedDescription:localizedDescription];
        }
    }
    return self;
}

@end

@implementation CDKNetworkJSONResponse

+ (CDKNetworkJSONResponse *)JSONResponseWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    CDKNetworkJSONResponse *resp = [[CDKNetworkJSONResponse alloc] initWithResponse:response rawData:data];
    
    if (data.length > 0)
    {
        NSError *e = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
        
        if (e)
        {
            resp.error = [NSError errorWithDomain:CDKNetworkErrorDomain code:CDKNetworkErrorJSONSerializationError userInfo:nil];
        }
        else if (!json)
        {
            resp.error = [NSError errorWithDomain:CDKNetworkErrorDomain code:CDKNetworkErrorJSONSerializationError userInfo:nil];
        }
        else
        {
            resp.JSON = [json copy];
        }
    }
    
    return resp;
}

@end