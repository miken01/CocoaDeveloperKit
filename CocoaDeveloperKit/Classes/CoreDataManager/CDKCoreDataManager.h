//
//  CDKCoreDataManager.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "CDKBaseManagedObject.h"
#import "CDKObjectMapping.h"

typedef void (^CDKCoreDataManagerJSONSaveCompletion)(NSArray *objects, NSError *error);

@class CoreDataOperation;

@interface CDKCoreDataManager : NSObject

#pragma mark - General Properties

@property (nonatomic, strong) NSString *projectName;

#pragma mark - CoreData Related Properties

@property (nonatomic, assign) BOOL enableDebugMode;
@property (nonatomic, copy) NSString *dateFormat;

+ (id)sharedManager;

#pragma mark - Public Methods

- (void)resetPersistentStore;

/*
 * Method Name: initializeCoreDataWithProjectName:
 * @projectName: The name of the project. This will be used when creating the name of the database file
 * Description: This method initializes Core Data and places the database file in the documents directory if it doesn't exist
 */
- (void)initializeCoreDataWithProjectName:(NSString *)projectName;

/*
 * Method Name: persistentStoreCoordinator:
 * @projectName: The name of the project. This will be used when creating the name of the database file
 * @persistentStoreCoordinator: An NSPersistentStoreCoordinator to be used in place of the default NSPersistentStoreCoordinator
 * Description: You may wish to override the default NSPersistentStoreCoordinator with an EncryptedStore or something of that nature
 */
- (void)initializeCoreDataWithProjectName:(NSString *)projectName persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/*
 * Method Name: initializeCoreDataWithProjectName:
 * @projectName: The name of the project. This will be used when creating the name of the database file
 * @dateFormat: The global format for all date strings to be converted into NSDate objects
 * Description: This method initializes Core Data and places the database file in the documents directory if it doesn't exist
 */
- (void)initializeCoreDataWithProjectName:(NSString *)projectName dateFormat:(NSString *)dateFormat;

/*
 * Method Name: registerManagedObjectContextForThread:
 * @thread: The NSThread to register the managed object context for
 * Description: This method creates an instance of NSManagedObjectContext to be used specifically with the supplied thread
 */
- (void)registerManagedObjectContextForThread:(NSThread *)thread;

/*
 * Method Name: unRegisterManagedObjectContextForThread:
 * @thread: The NSThread to unregister the managed object context for
 * Description: This method deallocates an instance of NSManagedObjectContext that was previously registered with the supplied thread
 */
- (void)unRegisterManagedObjectContextForThread:(NSThread *)thread;

/*
 * Method Name: managedObjectContextForThread:
 * @thread: The NSThread to register the managed object context for
 * Description: This method gets the instance of NSManagedObjectContext to be used specifically with the supplied thread
 */
- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread;

/*
 * Method Name: managedObjectContextForThread
 * Description: Returns the correct NSManagedObjectContext for the calling thread
 */
- (NSManagedObjectContext *)managedObjectContextForCurrentThread;

/*
 * Method Name: saveManagedObjectContext
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContext;

/*
 * Method Name: saveManagedObjectContext
 * @context: An NSManagedObjectContext to save
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContext:(NSManagedObjectContext *)context;

/*
 * Method Name: saveManagedObjectContextAndWait
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContextAndWait;

/*
 * Method Name: saveManagedObjectContextAndWait
 * @context: An NSManagedObjectContext to save
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContextAndWait:(NSManagedObjectContext *)context;

/*
 * Method Name: rollBackManagedObjectContext
 * Description: This method undos changes to the context.
 */
- (void)rollBackManagedObjectContext;

/*
 * Method Name: rollBackManagedObjectContext
 * @context: An NSManagedObjectContext to rollback
 * Description: This method undos changes to the context.
 */
- (void)rollBackManagedObjectContext:(NSManagedObjectContext *)context;

/*
 * Method Name: insertEntityForName:
 * @entityName: A NSString for the object you want to insert a new record for
 * Description: This method inserts a new entity description for the class matching the entityName
 * Note: This method requires that the saveManagedObjectContext be called as it only runs the insert and not a save on the MOC
 */
- (id)insertEntityForName:(NSString *)entityName;

/*
 * Method Name: insertEntityForName:
 * @entityName: A NSString for the object you want to insert a new record for
 * @context: An NSManagedObjectContext to add the object to
 * Description: This method inserts a new entity description for the class matching the entityName
 * Note: This method requires that the saveManagedObjectContext be called as it only runs the insert and not a save on the MOC
 */
- (id)insertEntityForName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)context;

/*
 * Method Name: deleteObject:
 * @managedObject: A NSManagedObject to delete
 * @context: An NSManagedObjectContext to rollback
 * Description: This method deletes a NSManagedObject subclass from the appropriate context
 */
- (void)deleteObject:(NSManagedObject *)managedObject;

/*
 * Method Name: deleteObject:managedObjectContext:
 * @managedObject: A NSManagedObject to delete
 * Description: This method deletes a NSManagedObject subclass from the appropriate context
 */
- (void)deleteObject:(NSManagedObject *)managedObject managedObjectContext:(NSManagedObjectContext *)context;

/*
 * Method Name: objectForContext:
 * @object: The NSManagedObject to obtain the object from the context
 * @managedObjectContext: The NSManagedObjectContext to get the object from
 * Description: This method gets a NSManagedObject subclass from the appropriate context
 */
- (NSManagedObject *)managedObject:(NSManagedObject *)object forContext:(NSManagedObjectContext *)managedObjectContext;

/*
 * Method Name: refreshContext:
 * @managedObjectContext: A NSManagedObjectContext to refresh
 * Description: This method runs the refreshObject:mergeChanges: on the managed object context
 */
- (void)refreshContext:(NSManagedObjectContext *)managedObjectContext;

/*
 * Method Name: refreshObject:
 * @managedObject: A NSManagedObject to refresh
 * Description: This method runs the refreshObject:mergeChanges: on the managed object context
 */
- (void)refreshObject:(NSManagedObject *)managedObject;

/*
 * Method Name: executeFetchRequest:
 * @fetchRequest: An NSFetchRequest to run on the Managed Object Context
 * Description: This method runs an NSFetchRequest on the Managed Object Context and returns the results
 */
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest;

/*
 * Method Name: executeFetchRequest:
 * @fetchRequest: An NSFetchRequest to run on the Managed Object Context
 * @managedObjectContext: A NSManagedObjectContext to execute the fetch request against
 * Description: This method runs an NSFetchRequest on the Managed Object Context and returns the results
 */
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context;

/*
 * Method Name: saveJsonObjects:CDKObjectMapping:objectClass:completion:
 * @jsonObjects: A dictionary that contains JSON data
 * @CDKObjectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @completion: A block to run after once the method is complete
 * @return: An array with the base level objects that were saved
 * Description: This method iterates through all JSON dictionaries in the NSArray and attempts to use the CDKObjectMapping object to save the data to the Core Data database
 * Note: This method does not require that the saveManagedObjectContext to be called as it already implements this method interally
 */
- (void)saveJsonObjects:(NSDictionary *)jsonDict objectMapping:(CDKObjectMapping *)objectMapping objectClass:(__unsafe_unretained Class)managedObjectClass completion:(CDKCoreDataManagerJSONSaveCompletion)completion;

/*
 * Method Name: saveJsonObjects:CDKObjectMapping:objectClass:completion:
 * @jsonObjects: A dictionary that contains JSON data
 * @CDKObjectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @managedObjectContext: The NSManagedObjectContext to run the save on
 * @completion: A block to run after once the method is complete
 * @return: An array with the base level objects that were saved
 * Description: This method iterates through all JSON dictionaries in the NSArray and attempts to use the CDKObjectMapping object to save the data to the Core Data database
 * Note: This method does not require that the saveManagedObjectContext to be called as it already implements this method interally
 */
- (void)saveJsonObjects:(NSDictionary *)jsonDict objectMapping:(CDKObjectMapping *)objectMapping objectClass:(__unsafe_unretained Class)managedObjectClass managedObjectContext:(NSManagedObjectContext *)managedObjectContext saveContextOnComplete:(BOOL)saveContextOnComplete completion:(CDKCoreDataManagerJSONSaveCompletion)completion;

@end
