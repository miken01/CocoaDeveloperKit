//
//  CDKObjectMapping.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDKObjectMappingAttribute.h"
#import "CDKObjectMappingRelationship.h"

@interface CDKObjectMapping : NSObject

#pragma mark - Properties

/* 
 * @rootKeyPath: The root key path from the JSON dictonary
 */
@property (nonatomic, strong) NSString *rootKeyPath;

/*
 * @objectUUID: A property used to store some other form of primary key. This will be used before the primaryKeyAttribute when doing lookups
 */
@property (nonatomic, strong) NSString *objectUUID;

/*
 * @keyPaths: An array of root key paths from the JSON dictonary for an object that is a sub-object. See example JSON below
 * Note: This will be set automatically with the shortcut KeyPath.SubKeyPath (TablesInfo.TablesInfo).
 * "TablesInfo":[{
 *      "TablesInfo":{
 *          "Name":"String Content",
 *          "Rows":1234
 *      }
 *  }]
 */
@property (nonatomic, readonly) NSMutableArray *keyPaths;

/* 
 * @primaryKeyAttribute: The primary key attribute for the local object 
 * Note: This can be either a single string or an array of strings.
 *       If an array of strings is set, then all strings will be used to find the object in the database during the save process
 */
//@property (nonatomic, strong) NSString *primaryKeyAttribute;
@property (nonatomic, strong) id primaryKeyAttribute;

/* 
 * @mapping: An array of CDKObjectMappingAttributes or CDKObjectMappingRelationships
 */
@property (nonatomic, strong) NSMutableArray *mapping;

#pragma mark - Getters

/*
 * Method Name: keyPaths:
 * @return: An array of root key paths for a JSON dictionary based on the rootKeyPath property
 * Description: This method creates an array of Key Paths to the location of an object within a JSON dictionary
 */
- (NSMutableArray *)keyPaths;

#pragma mark - Public Methods

/*
 * Method Name: mapKeyPath:toAttribute:
 * @keyPath: The key path value for the linked attribute. This is generally going to be the key in the JSON dictonary that an attribute will be linked to
 * @attribute: The name of the object attribute to link the key path to.
 * Description: This method creates an instance of CDKObjectMappingAttribute and sets the approriate attributes to it.
 */
- (void)mapKeyPath:(NSString *)keyPath toAttribute:(NSString *)attribute;

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
withObjectClassName:(NSString *)className;

@end
