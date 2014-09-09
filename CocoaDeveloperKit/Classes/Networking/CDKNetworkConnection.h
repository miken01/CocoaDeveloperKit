//
//  CDKNetworkConnection.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDKNetworkGlobals.h"
#import "CDKNetworkParameter.h"
#import "CDKNetworkHeader.h"
#import "CDKNetworkResponse.h"

typedef void (^CDKNetworkConnectionCompletion)(NSError *error, CDKNetworkResponse *response);
typedef void (^CDKNetworkJSONConnectionCompletion)(NSError *error, CDKNetworkJSONResponse *response);

@interface CDKNetworkConnection : NSObject <NSURLConnectionDelegate>

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) CDKNetworkMethod method;
@property (nonatomic, readonly) CDKNetworkSerializationType serializationType;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly) NSArray *parameters;
@property (nonatomic, readonly) NSArray *headers;
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, copy) NSData *httpBody;

+ (CDKNetworkConnection *)networkConnectionWithURL:(NSURL *)url;
+ (CDKNetworkConnection *)JSONNetworkConnectionWithURL:(NSURL *)url;

- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url serializationType:(CDKNetworkSerializationType)serilizationType;

- (void)addParameter:(NSString *)key value:(NSString *)value;
- (void)addHeader:(NSString *)key value:(NSString *)value;

- (void)performConnectionWithCompletion:(CDKNetworkConnectionCompletion)completion;
- (void)performConnectionWithRequest:(NSURLRequest *)request completion:(CDKNetworkConnectionCompletion)completion;

- (void)performJSONConnectionWithCompletion:(CDKNetworkJSONConnectionCompletion)completion;
- (void)performJSONConnectionWithRequest:(NSURLRequest *)request completion:(CDKNetworkJSONConnectionCompletion)completion;

+ (NSData *)getDataFromJSON:(NSDictionary *)JSON;
- (void)setJSONData:(NSDictionary *)JSON;
- (void)printHTTPBody;

@end