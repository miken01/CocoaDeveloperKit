//
//  CDKObjectMappingRelationship.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/25/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDKObjectMappingRelationship : NSObject

/*
 * @objectClassName: The class name that the relationship object should be a type of
 */
@property (nonatomic, strong) NSString *objectClassName;

/*
 * @keyPath: The key path for the value in the the JSON dictonary
 */
@property (nonatomic, strong) NSString *keyPath;

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
 * @relationship: The attribute that the relationship will be tied to. This is the attribute from the parent object.
 */
@property (nonatomic, strong) NSString *relationship;

/*
 * @inverseAttribute: This is the attribute name for the inverse, or parent, of the relationship object.
 */
@property (nonatomic, strong) NSString *inverseAttribute;

/*
 * @inverseAttribute: This is the actual object to be used as the inverse, or parent, of the relationship object.
 */
@property (nonatomic, strong) id inverseObject;

#pragma mark - Initializer

- (id)initWithKeyPath:(NSString *)keyPath
         relationship:(NSString *)relationship
          withInverse:(NSString *)inverseAttribute
  withObjectClassName:(NSString *)className;

@end
