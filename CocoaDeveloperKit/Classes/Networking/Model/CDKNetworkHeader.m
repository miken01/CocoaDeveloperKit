//
//  CDKNetworkHeader.m
//  CDKLibrary
//
//  Created by Mike Neill on 8/20/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "CDKNetworkHeader.h"

@implementation CDKNetworkHeader

- (id)initWithKey:(NSString *)key value:(NSString *)value
{
    if (self = [super init])
    {
        _key = [key copy];
        _value = [value copy];
    }
    return self;
}

@end
