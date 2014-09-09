//
//  CDKBaseManagedObject.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKBaseManagedObject.h"
#import "CDKCoreDataManager.h"
#import "CDKCoreDataUtilities.h"
#import "CDKLogger.h"
#import "NSDate+Additions.h"
#import "PropertyUtilities.h"

@implementation CDKBaseManagedObject

#pragma mark - Class Methods

/*
 * Method Name: getObjectMapping
 * @return: A CDKObjectMapping object that should be fully initialized and setup for mapping
 * Description: This method is called whenever the object mapping is required for a sub-class of CDKBaseManagedObject.
 *              This method requires that CDKBaseManagedObject be sub-classed and for all object mapping to be put in the sub-class object.
 *              If this method is called on a CDKBaseManagedObject directly, without sub-classing, then the CDKObjectMapping will be nil.
 */
+ (CDKObjectMapping *)getObjectMapping
{
    // used by subclasses to set the object mapping
    return nil;
}

/*
 * Method Name: newObject
 * @return: A new CDKBaseManagedObject
 * Description: This method will insert a new record for the Class and return the new object
 */
+ (CDKBaseManagedObject *)newObject
{
    return [[CDKCoreDataManager sharedManager] insertEntityForName:[[self class] description]];
}

/*
 * Method Name: allObjects
 * @return: An array of objects
 * Description: This method gets all objects of this class and returns an array
 */
+ (NSArray *)allObjects
{
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:[CDKCoreDataUtilities cleanClassName:[self.class description]]];
    NSArray *results = [[CDKCoreDataManager sharedManager] executeFetchRequest:fetchReq];
    if (results.count > 0)
        return results;
    return nil;
}

/*
 * Method Name: convertCDKBaseManagedObjectToDictionary:
 * @CDKBaseManagedObject: A CDKBaseManagedObject to convert into a NSDictionary
 * Description: This method converts a CDKBaseManagedObject into a NSDictionary
 */
+ (NSDictionary *)convertCDKBaseManagedObjectToDictionary:(CDKBaseManagedObject *)CDKBaseManagedObject
{
    // validate any properties
    [CDKBaseManagedObject validatePropertyValues];
    
    // convert the object into a dictionary
    return [CDKCoreDataUtilities convertObjectToDictionary:CDKBaseManagedObject usingObjectMapping:[CDKBaseManagedObject.class getObjectMapping]];
}

/*
 * Method Name: removeAllObjects
 * Description: This method removes all objects from the table
 */
+ (void)removeAllObjects
{
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:[CDKCoreDataUtilities cleanClassName:[self.class description]]];
    NSArray *results = [[CDKCoreDataManager sharedManager] executeFetchRequest:fetchReq];
    if (results.count > 0)
    {
        for (CDKBaseManagedObject *object in results)
        {
            [[CDKCoreDataManager sharedManager] deleteObject:object];
        }
        
        [[CDKCoreDataManager sharedManager] saveManagedObjectContext];
    }
}

#pragma mark - Super Class Overrides

/*
 * Method Name: setValue:forKey
 * @value: A "id" type object that is the value to be set to the object
 * @key: The attribute key to save the value to
 * Description: This method is an override of the NSObject classes setValue:forKey method, and pre-processes data before it's saved to ensure the data is of the property type for the attribute
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    // set NULL values to nil to prevent a crash while saving
    if (value == NULL || value == [NSNull null]) {
        value = nil;
    }
    
    // if the value is not nil, then make sure the value is the correct type that is required for the attribute
    if (value != nil && value != 0)
    {
        // get a dictionary of all the object's properties
        NSDictionary *propDict = [PropertyUtilities classPropsFor:[self class]];
        Class attrClass = NSClassFromString([propDict objectForKey:key]);
        
        // if this is an NSDate class, then
        if (attrClass == [NSDate class] && [value isKindOfClass:[NSString class]])
        {
            NSDate *convertedDate = [NSDate dateFromStringWithFormat:[[CDKCoreDataManager sharedManager] dateFormat] string:value];
            if (convertedDate)
                value = convertedDate;
        }
    }
    
    // set the value
    [super setValue:value forKey:key];
}

#pragma mark - Public Methods

/*
 * Method Name: save
 * Description: This method saves the object to it's context, and takes care of error handling
 * Note: This method requires that you call the saveManagedObjectContext method on the CDKCoreDataManager singleton to commit the change
 */
- (void)save
{
    [[CDKCoreDataManager sharedManager] saveManagedObjectContext:self.managedObjectContext];
}

/*
 * Method Name: refresh
 * Description: This method refetches all data from the object context for this object
 */
- (void)refresh
{
    [self.managedObjectContext refreshObject:self mergeChanges:YES];
}

/*
 * Method Name: delete
 * Description: This method deletes the object from it's context, and takes care of error handling
 * Note: This method requires that you call the saveManagedObjectContext method on the CDKCoreDataManager singleton to commit the change
 */
- (void)delete
{
    [[CDKCoreDataManager sharedManager] deleteObject:self managedObjectContext:self.managedObjectContext];
}

/*
 * Method Name: validatePropertyValues
 * Description: This is a call back method that is invoked on the sub-classes of CDKBaseManagedObject and it is used to validate any properties that require a value
 * Note: This method is ran during the convertCDKBaseManagedObjectToDictionary: method
 */
- (void)validatePropertyValues
{
    // do nothing
}

/*
 * Method Name: evaluateObjectWithDictionary:
 * @dictionary: The NSDictionary object that was used to create the object
 * Description: This is a call back method that is invoked on the sub-classes of CDKBaseManagedObject and it is used to evalue an object before saving it.
 * Note: This method is ran during the saveJSON:CDKObjectMapping:class:managedObjectContext:level: method in the CDKCoreDataManager class
 */
- (void)evaluateObjectWithDictionary:(NSDictionary *)dictionary
{
    // do nothing
}

@end
