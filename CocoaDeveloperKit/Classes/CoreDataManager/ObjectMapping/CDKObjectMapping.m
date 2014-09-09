//
//  CDKObjectMapping.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKObjectMapping.h"

@implementation CDKObjectMapping

#pragma mark - Properties

@synthesize rootKeyPath = _rootKeyPath;
@synthesize objectUUID = _objectUUID;
@synthesize keyPaths = _keyPaths;
@synthesize primaryKeyAttribute = _primaryKeyAttribute;
@synthesize mapping = _mapping;

#pragma mark - Memory Management


#pragma mark - Initializer

- (id)init
{
    if ((self = [super init])) {
        _mapping = [[NSMutableArray alloc] init];
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
        _keyPaths = [(NSArray *)[_rootKeyPath componentsSeparatedByString:@"."] mutableCopy];
    }
    return _keyPaths;
}

#pragma mark - Public Methods

/*
 * Method Name: mapKeyPath:toAttribute:
 * @keyPath: The key path value for the linked attribute. This is generally going to be the key in the JSON dictonary that an attribute will be linked to
 * @attribute: The name of the object attribute to link the key path to.
 * Description: This method creates an instance of CDKObjectMappingAttribute and sets the approriate attributes to it.
 */
- (void)mapKeyPath:(NSString *)keyPath toAttribute:(NSString *)attribute
{
    CDKObjectMappingAttribute *pair = [[CDKObjectMappingAttribute alloc] initWithKeyPath:keyPath attribute:attribute];
    [_mapping addObject:pair];
    pair = nil;
}

/*
 * Method Name: mapKeyPath:toRelationship:withInverse:withObjectClassName:
 * @keyPath: The key path value for the linked attribute. This is generally going to be the key in the JSON dictonary that an attribute will be linked to
 * @relationship: The name of the attribute the relationship will be set to
 * @inverseAttribute: The name inverse attribute the relationship look back to. Generally the parent object
 * @className: The name of the class that this relationship will use the object mapping for
 * Description: This method creates an instance of CDKObjectMappingRelationship and sets the approriate attributes to it.
 */
- (void)mapKeyPath:(NSString *)keyPath
    toRelationship:(NSString *)relationship
       withInverse:(NSString *)inverseAttribute
withObjectClassName:(NSString *)className
{
    CDKObjectMappingRelationship *rel = [[CDKObjectMappingRelationship alloc] initWithKeyPath:keyPath relationship:relationship withInverse:inverseAttribute withObjectClassName:className];
    [_mapping addObject:rel];
    rel = nil;
}

@end
