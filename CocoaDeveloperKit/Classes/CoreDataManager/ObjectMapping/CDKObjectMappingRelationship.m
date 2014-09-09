//
//  CDKObjectMappingRelationship.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/25/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKObjectMappingRelationship.h"

@implementation CDKObjectMappingRelationship

#pragma mark - Properties

@synthesize objectClassName = _objectClassName;
@synthesize keyPath = _keyPath;
@synthesize keyPaths = _keyPaths;
@synthesize relationship = _relationship;
@synthesize inverseAttribute = _inverseAttribute;
@synthesize inverseObject = _inverseObject;

#pragma mark - Memory Management


#pragma mark - Initializer

- (id)initWithKeyPath:(NSString *)keyPath
         relationship:(NSString *)relationship
          withInverse:(NSString *)inverseAttribute
  withObjectClassName:(NSString *)className
{
    if ((self = [super init])) {
        _objectClassName = className;
        _keyPath = keyPath;
        _relationship = relationship;
        _inverseAttribute = inverseAttribute;
    }
    return self;
}

#pragma mark - Getters

/*
 * Method Name: keyPaths:
 * @return: An array of root key paths for a JSON dictionary based on the rootKeyPath property
 * Description: This method creates an array of Key Paths to the location of an object within a JSON dictionary
 */
- (NSMutableArray *)keyPaths
{
    // if there are not any key paths, then create the array based on the rootKeyPath property
    if (!_keyPaths) {
        _keyPaths = [(NSArray *)[_keyPath componentsSeparatedByString:@"."] mutableCopy];
    }
    return _keyPaths;
}

@end
