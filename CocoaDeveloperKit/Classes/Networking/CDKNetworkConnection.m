//
//  CDKNetworkConnection.m
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "CDKNetworkConnection.h"
#import "NSURL+CDKNetwork.h"

@implementation CDKNetworkConnection
{
    NSMutableArray *parameters;
    NSMutableArray *headers;
    
    NSMutableData *returnData;
    NSHTTPURLResponse *response;
    CDKNetworkConnectionCompletion completionBlock;
    CDKNetworkJSONConnectionCompletion jsonCompletionBlock;
}

#pragma mark - Factory Methods

+ (CDKNetworkConnection *)networkConnectionWithURL:(NSURL *)url
{
    CDKNetworkConnection *conn = [[CDKNetworkConnection alloc] initWithURL:url];
    return conn;
}

+ (CDKNetworkConnection *)JSONNetworkConnectionWithURL:(NSURL *)url
{
    CDKNetworkConnection *conn = [[CDKNetworkConnection alloc] initWithURL:url serializationType:CDKNetworkSerializationTypeJSON];
    return conn;
}

#pragma mark - Initialization

- (id)init
{
    if (self = [super init])
    {
        _method = CDKNetworkMethodGET;
        _serializationType = CDKNetworkSerializationTypeNone;
        _timeoutInterval = CDKNetworkDefaultTimeInterval;
        parameters = [[NSMutableArray alloc] init];
        headers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [self init])
    {
        _url = [url copy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url serializationType:(CDKNetworkSerializationType)serilizationType
{
    if (self = [super init])
    {
        _url = [url copy];
        _method = CDKNetworkMethodGET;
        _serializationType = CDKNetworkSerializationTypeNone;
        _timeoutInterval = CDKNetworkDefaultTimeInterval;
        parameters = [[NSMutableArray alloc] init];
        headers = [[NSMutableArray alloc] init];
        _serializationType = serilizationType;
        
        if (_serializationType == CDKNetworkSerializationTypeJSON)
        {
            [self addHeader:@"Accept" value:@"application/json"];
            [self addHeader:@"Content-Type" value:@"application/json"];
        }
    }
    
    return self;
}

#pragma mark - Getters

- (NSURL *)url
{
    return [_url URLByAppendingParameters:parameters];
}

- (NSArray *)parameters
{
    return [parameters copy];
}

- (NSArray *)headers
{
    return [headers copy];
}

- (NSURLRequest *)request
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
    
    // set HTTP method
    switch (self.method)
    {
        case CDKNetworkMethodDELETE:
        {
            req.HTTPMethod = @"DELETE";
        }
            break;
            
        case CDKNetworkMethodPOST:
        {
            req.HTTPMethod = @"POST";
        }
            break;
            
        case CDKNetworkMethodHEAD:
        {
            req.HTTPMethod = @"HEAD";
        }
            break;
            
        case CDKNetworkMethodMERGE:
        {
            req.HTTPMethod = @"MERGE";
        }
            break;
            
        case CDKNetworkMethodGET:
        default:
        {
            req.HTTPMethod = @"GET";
        }
            break;
    }
    
    // set headers
    for (CDKNetworkHeader *h in headers)
    {
        [req setValue:h.value forHTTPHeaderField:h.key];
    }
    
    // set body copy
    if (self.httpBody != nil)
    {
        req.HTTPBody = self.httpBody;
    }
    
    return req;
}

#pragma mark - URL Parameters

- (void)addParameter:(NSString *)key value:(NSString *)value
{
    CDKNetworkParameter *p = [[CDKNetworkParameter alloc] initWithKey:key value:value];
    [parameters addObject:p];
}

- (void)addHeader:(NSString *)key value:(NSString *)value
{
    CDKNetworkHeader *h = [[CDKNetworkHeader alloc] initWithKey:key value:value];
    [headers addObject:h];
}

#pragma mark - Perform Connection

- (void)performConnectionWithCompletion:(CDKNetworkConnectionCompletion)completion
{
    [self performConnectionWithRequest:self.request completion:completion];
}

- (void)performConnectionWithRequest:(NSURLRequest *)request completion:(CDKNetworkConnectionCompletion)completion
{
    NSLog(@"[CDKNetworkConnection][performConnectionWithRequest:completion:] - Start connection with URL %@", self.url);
    
    completionBlock = completion;
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [conn start];
}

- (void)performJSONConnectionWithCompletion:(CDKNetworkJSONConnectionCompletion)completion
{
    [self performJSONConnectionWithRequest:self.request completion:completion];
}

- (void)performJSONConnectionWithRequest:(NSURLRequest *)request completion:(CDKNetworkJSONConnectionCompletion)completion
{
    NSLog(@"[CDKNetworkConnection][performJSONConnectionWithRequest:] - Start connection with URL %@", self.url);
    
    jsonCompletionBlock = completion;
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    [conn start];
}

#pragma mark - NSURLConnection Delegates

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)resp
{
    // get HTTP status code
    if([resp isKindOfClass:[NSHTTPURLResponse class]])
    {
        response = (NSHTTPURLResponse *)resp;
        NSLog(@"[CDKNetworkConnection][performConnectionWithCompletion] - Status Code %ld", (long)response.statusCode);
    }
    
    // reset the data container
    returnData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [returnData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"[CDKNetworkConnection][performConnectionWithCompletion] - Connection did complete with %ld byte(s) returned", (unsigned long)returnData.length);
    
    switch (_serializationType)
    {
        case CDKNetworkSerializationTypeJSON:
        {
            CDKNetworkJSONResponse *resp = [CDKNetworkJSONResponse JSONResponseWithResponse:response data:returnData];
            jsonCompletionBlock(resp.error, resp);
        }
            break;
            
        case CDKNetworkSerializationTypeNone:
        default:
        {
            CDKNetworkResponse *resp = [CDKNetworkResponse responseWithResponse:response data:returnData];
            completionBlock(resp.error, resp);
        }
            break;
    }
}

- (void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"[CDKNetworkConnection][performConnectionWithCompletion] - Connection did faile with error %@", error);
    
    switch (_serializationType)
    {
        case CDKNetworkSerializationTypeJSON:
        {
            jsonCompletionBlock(error, nil);
        }
            break;
            
        case CDKNetworkSerializationTypeNone:
        default:
        {
            completionBlock(error, nil);
        }
            break;
    }
}

#pragma mark - Convenience

- (void)setJSONData:(NSDictionary *)JSON
{
    self.httpBody = [CDKNetworkConnection getDataFromJSON:JSON];
}

+ (NSData *)getDataFromJSON:(NSDictionary *)JSON
{
    NSError *e;
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:&e];
    
    if (e)
        NSLog(@"[CDKNetworkConnection][setJSONData] - Serialization Failed with Error: %@", e);
    
    return data;
}

- (void)printHTTPBody
{
    NSString *string = [[NSString alloc] initWithData:self.httpBody encoding:NSUTF8StringEncoding];
    NSLog(@"[CDKNetworkConnection][printHTTPBody] %@", string);
}

@end
