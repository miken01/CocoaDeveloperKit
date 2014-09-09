//
//  CDKObjectMappingAttribute.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKObjectMappingAttribute.h"

@implementation CDKObjectMappingAttribute

#pragma mark - Properties

@synthesize keyPath = _keyPath;
@synthesize attribute = _attribute;

#pragma mark - Memory Management


#pragma mark - Initializer

- (id)initWithKeyPath:(NSString *)keyPath attribute:(NSString *)attribute
{
    if ((self = [super init])) {
        _keyPath = keyPath;
        _attribute = attribute;
    }
    return self;
}

@end
