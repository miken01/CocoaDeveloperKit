//
//  CDKBaseManagedObject.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CDKCoreDataManager.h"
#import "CDKObjectMapping.h"

@interface CDKBaseManagedObject : NSManagedObject

#pragma mark - Class Methods

/*
 * Method Name: getObjectMapping
 * @return: A CDKObjectMapping object that should be fully initialized and setup for mapping
 * Description: This method is called whenever the object mapping is required for a sub-class of CDKBaseManagedObject.
 *              This method requires that CDKBaseManagedObject be sub-classed and for all object mapping to be put in the sub-class object.
 *              If this method is called on a CDKBaseManagedObject directly, without sub-classing, then the CDKObjectMapping will be nil.
 */
+ (CDKObjectMapping *)getObjectMapping;

/*
 * Method Name: newObject
 * @return: A new CDKBaseManagedObject
 * Description: This method will insert a new record for the Class and return the new object
 */
+ (CDKBaseManagedObject *)newObject;

/*
 * Method Name: allObjects
 * @return: An array of objects
 * Description: This method gets all objects of this class and returns an array
 * Note: This method requires that you call the saveManagedObjectContext method on the CDKCoreDataManager singleton to commit the change
 */
+ (NSArray *)allObjects;

/*
 * Method Name: convertCDKBaseManagedObjectToDictionary:
 * @CDKBaseManagedObject: A CDKBaseManagedObject to convert into a NSDictionary
 * Description: This method converts a CDKBaseManagedObject into a NSDictionary
 */
+ (NSDictionary *)convertCDKBaseManagedObjectToDictionary:(CDKBaseManagedObject *)CDKBaseManagedObject;

/*
 * Method Name: removeAllObjects
 * Description: This method removes all objects from the table
 */
+ (void)removeAllObjects;

#pragma mark - Public Methods

/*
 * Method Name: save
 * Description: This method saves the object to it's context, and takes care of error handling
 * Note: This method requires that you call the saveManagedObjectContext method on the CDKCoreDataManager singleton to commit the change
 */
- (void)save;

/*
 * Method Name: refresh
 * Description: This method refetches all data from the object context for this object
 */
- (void)refresh;

/*
 * Method Name: delete
 * Description: This method deletes the object from it's context, and takes care of error handling
 * Note: This method requires that you call the saveManagedObjectContext method on the CDKCoreDataManager singleton to commit the change
 */
- (void)delete;

/*
 * Method Name: validatePropertyValues
 * Description: This is a call back method that is invoked on the sub-classes of CDKBaseManagedObject and it is used to validate any properties that require a value
 * Note: This method is ran during the convertCDKBaseManagedObjectToDictionary: method
 */
- (void)validatePropertyValues;

/*
 * Method Name: evaluateObjectWithDictionary:
 * @dictionary: The NSDictionary object that was used to create the object
 * Description: This is a call back method that is invoked on the sub-classes of CDKBaseManagedObject and it is used to evalue an object before saving it.
 * Note: This method is ran during the saveJSON:CDKObjectMapping:class:managedObjectContext:level: method in the CDKCoreDataManager class
 */
- (void)evaluateObjectWithDictionary:(NSDictionary *)dictionary;

@end
