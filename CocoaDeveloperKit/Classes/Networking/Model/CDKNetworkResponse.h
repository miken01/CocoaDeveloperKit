//
//  CDKNetworkResponse.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDKNetworkResponse : NSHTTPURLResponse

+ (CDKNetworkResponse *)responseWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;
- (id)initWithResponse:(NSHTTPURLResponse *)response rawData:(NSData *)data;

@property (nonatomic, copy) NSData *rawData;
@property (nonatomic, copy) NSError *error;

@end

@interface CDKNetworkJSONResponse : CDKNetworkResponse

+ (CDKNetworkJSONResponse *)JSONResponseWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;

@property (nonatomic, copy) NSDictionary *JSON;

@end