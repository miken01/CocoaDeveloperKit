//
//  CDKCoreDataManager.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKCoreDataManager.h"
#import "CDKLogger.h"
#import "CDKCoreDataOperation.h"
#import "PropertyUtilities.h"
#import "NSDate+Additions.h"
#import "NSError+Additions.h"
#import "CDKCoreDataUtilities.h"
#import "CDKThreadContextRef.h"

@interface CDKCoreDataManager ()
{
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    NSManagedObjectContext *mainManagedObjectContext;
    
    NSMutableArray *managedObjectContexts;
    NSOperationQueue *operationQueue;
}

@end

@implementation CDKCoreDataManager

#pragma mark - General Properties

@synthesize projectName = _projectName;

#pragma mark - CoreData Related Properties

@synthesize enableDebugMode = _enableDebugMode;
@synthesize dateFormat = _dateFormat;

#pragma mark - Singleton Methods

static CDKCoreDataManager *sharedManager = nil;

+ (id)sharedManager
{
    // allow for safe multi-threading and init the object if necessary
    @synchronized (self) {
        if (sharedManager == nil)
        {
            sharedManager = [[super allocWithZone:NULL] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        // setup default date format (E.x. 9/13/2012 12:32:00 PM)
        _dateFormat = @"L/d/yyyy h:mm:ss a";
        
        managedObjectContexts = [[NSMutableArray alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
    mainManagedObjectContext = nil;
    persistentStoreCoordinator = nil;
    managedObjectModel = nil;
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:_projectName ofType:@"momd"];
    //NSURL *momURL = [NSURL fileURLWithPath:path];
    //managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _projectName]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        [CDKLogger LogError:@"CDKCoreDataManager - Error: %@", error.localizedDescription];
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (mainManagedObjectContext != nil)
        return mainManagedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
        mainManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        mainManagedObjectContext.stalenessInterval = 0.0;
        
        CDKThreadContextRef *ref = [[CDKThreadContextRef alloc] init];
        ref.thread = [NSThread mainThread];
        ref.context = mainManagedObjectContext;
        [managedObjectContexts addObject:ref];
    }
    return mainManagedObjectContext;
}

#pragma mark - Notification Methods

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
    [mainManagedObjectContext performBlock:^(void)
    {
        @try
        {
            [mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }
        @catch (NSException *exception)
        {
            [CDKLogger LogException:exception];
        }
    }];
}

#pragma mark - Concurrency Methods

/*
 * Method Name: registerManagedObjectContextForThread:
 * @thread: The NSThread to register the managed object context for
 * Description: This method creates an instance of NSManagedObjectContext to be used specifically with the supplied thread
 */
- (void)registerManagedObjectContextForThread:(NSThread *)thread
{
    BOOL foundRef = NO;
    for (CDKThreadContextRef *ref in managedObjectContexts)
    {
        if (ref.thread == thread)
        {
            foundRef = YES;
            break;
        }
    }
    
    if (!foundRef)
    {
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        context.parentContext = mainManagedObjectContext;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        CDKThreadContextRef *ref = [[CDKThreadContextRef alloc] init];
        ref.thread = thread;
        ref.context = context;
        
        [managedObjectContexts addObject:ref];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
    }
}

/*
 * Method Name: unRegisterManagedObjectContextForThread:
 * @thread: The NSThread to unregister the managed object context for
 * Description: This method deallocates an instance of NSManagedObjectContext that was previously registered with the supplied thread
 */
- (void)unRegisterManagedObjectContextForThread:(NSThread *)thread
{
    CDKThreadContextRef *removeRef = nil;
    
    for (CDKThreadContextRef *ref in managedObjectContexts)
    {
        if (ref.thread == thread)
        {
            removeRef = ref;
            break;
        }
    }
    
    if (removeRef)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:removeRef.context];
        
        [managedObjectContexts removeObject:removeRef];
        removeRef = nil;
    }
}

/*
 * Method Name: managedObjectContextForThread:
 * @thread: The NSThread to register the managed object context for
 * Description: This method gets the instance of NSManagedObjectContext to be used specifically with the supplied thread
 */
- (NSManagedObjectContext *)managedObjectContextForThread:(NSThread *)thread
{
    NSManagedObjectContext *rContext = nil;
    
    if (![[NSThread currentThread] isMainThread])
    {
        for (CDKThreadContextRef *ref in managedObjectContexts)
        {
            if (ref.thread == thread)
            {
                rContext = ref.context;
                break;
            }
        }
    }
    else
    {
        return mainManagedObjectContext;
    }
    
    return rContext;
}

/*
 * Method Name: managedObjectContextForThread
 * Description: Returns the correct NSManagedObjectContext for the calling thread
 */
- (NSManagedObjectContext *)managedObjectContextForCurrentThread
{
    NSManagedObjectContext *rContext = mainManagedObjectContext;
    
    if (![[NSThread currentThread] isMainThread])
    {
        for (CDKThreadContextRef *ref in managedObjectContexts)
        {
            if (ref.thread == [NSThread currentThread])
            {
                rContext = ref.context;
                break;
            }
        }
    }
    
    return rContext;
}

#pragma mark - Public Methods

- (void)resetPersistentStore
{
    // iterate through all persistent stores, and remove them
    for (NSPersistentStore *persistentStore in persistentStoreCoordinator.persistentStores)
    {
        NSError *error;
        
        // get the URL to the database file
        NSURL *storeURL = [NSURL fileURLWithPath:persistentStore.URL.path];
        
        // kill the database file
        if ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path])
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error])
                [CDKLogger LogError:@"CDKCoreDataManager - Error - Managed object store failed to delete persistent store: %@", error.localizedDescription];
        } else
        {
            [CDKLogger LogError:@"CDKCoreDataManager - Error - Asked to delete persistent store but no store file exists at path: %@", storeURL.path];
        }
    }
    
    // clear out the old persistent store coordinator
    managedObjectModel = nil;
    persistentStoreCoordinator = nil;
    mainManagedObjectContext = nil;
    
    // create a new persistent store
    managedObjectModel = [self managedObjectModel];
    persistentStoreCoordinator = [self persistentStoreCoordinator];
    mainManagedObjectContext = [self mainManagedObjectContext];
}

/*
 * Method Name: initializeCoreDataWithProjectName:
 * @projectName: The name of the project. This will be used when creating the name of the database file
 * Description: This method initializes Core Data and places the database file in the documents directory if it doesn't exist
 */
- (void)initializeCoreDataWithProjectName:(NSString *)projectName
{
    // initialize all objects for CD
    _projectName = projectName;
    managedObjectModel = [self managedObjectModel];
    persistentStoreCoordinator = [self persistentStoreCoordinator];
    mainManagedObjectContext = [self mainManagedObjectContext];
}

/*
 * Method Name: initializeCoreDataWithProjectName:
 * @projectName: The name of the project. This will be used when creating the name of the database file
 * @dateFormat: The global format for all date strings to be converted into NSDate objects
 * Description: This method initializes Core Data and places the database file in the documents directory if it doesn't exist
 */
- (void)initializeCoreDataWithProjectName:(NSString *)projectName dateFormat:(NSString *)dateFormat
{
    [self initializeCoreDataWithProjectName:projectName];
    _dateFormat = [dateFormat copy];
}

/*
 * Method Name: saveManagedObjectContext
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContext
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    [self saveManagedObjectContext:context];
}

/*
 * Method Name: saveManagedObjectContext
 * @context: An NSManagedObjectContext to save
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContext:(NSManagedObjectContext *)context
{
    @try
    {
        // perform synchronous process to save to the main MOC
        [context performBlockAndWait:^(void)
         {
             __block NSError *error = nil;
             
             // push any changes in the main context to the background writer context
             [context performBlockAndWait:^(void)
              {
                  if (![context save:&error])
                      [CDKLogger LogError:@"CoreDataManger - Error Saving Managed Object Context: %@", error.localizedDescription];
              }];
         }];
    }
    @catch (NSException *exception)
    {
        [CDKLogger LogException:exception];
    }
}

/*
 * Method Name: saveManagedObjectContextAndWait
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContextAndWait
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    [self saveManagedObjectContextAndWait:context];
}

/*
 * Method Name: saveManagedObjectContextAndWait
 * @context: An NSManagedObjectContext to save
 * Description: This method saves the entire context at one time.
 */
- (void)saveManagedObjectContextAndWait:(NSManagedObjectContext *)context
{
    @try
    {
        // perform synchronous process to save to the main MOC
        [context performBlockAndWait:^(void)
         {
             __block NSError *error = nil;
             
             // push any changes in the main context to the background writer context
             [context performBlockAndWait:^(void)
             {
                 if (![context save:&error])
                     [CDKLogger LogError:@"CoreDataManger - Error Saving Managed Object Context: %@", error.localizedDescription];
             }];
         }];
    }
    @catch (NSException *exception)
    {
        [CDKLogger LogException:exception];
    }
}

/*
 * Method Name: rollBackManagedObjectContext
 * Description: This method undos changes to the context.
 */
- (void)rollBackManagedObjectContext
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    [self rollBackManagedObjectContext:context];
}

/*
 * Method Name: rollBackManagedObjectContext
 * @context: An NSManagedObjectContext to rollback
 * Description: This method undos changes to the context.
 */
- (void)rollBackManagedObjectContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^(void)
     {
         if ([context hasChanges])
             [context rollback];
     }];
}

/*
 * Method Name: insertEntityForName:
 * @entityName: A NSString for the object you want to insert a new record for
 * Description: This method inserts a new entity description for the class matching the entityName
 * Note: This method requires that the saveManagedObjectContext be called as it only runs the insert and not a save on the MOC
 */
- (id)insertEntityForName:(NSString *)entityName
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    return [self insertEntityForName:[CDKCoreDataUtilities cleanClassName:entityName] managedObjectContext:context];
}

/*
 * Method Name: insertEntityForName:
 * @entityName: A NSString for the object you want to insert a new record for
 * @context: An NSManagedObjectContext to add the object to
 * Description: This method inserts a new entity description for the class matching the entityName
 * Note: This method requires that the saveManagedObjectContext be called as it only runs the insert and not a save on the MOC
 */
- (id)insertEntityForName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)context
{
    id newObject = [NSEntityDescription insertNewObjectForEntityForName:[CDKCoreDataUtilities cleanClassName:entityName] inManagedObjectContext:context];
    return newObject;
}

/*
 * Method Name: deleteObject:
 * @managedObject: A NSManagedObject to delete
 * Description: This method deletes a NSManagedObject subclass from the appropriate context
 */
- (void)deleteObject:(NSManagedObject *)managedObject
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    [self deleteObject:managedObject managedObjectContext:context];
}

/*
 * Method Name: deleteObject:managedObjectContext:
 * @managedObject: A NSManagedObject to delete
 * @context: An NSManagedObjectContext to delete the object from
 * Description: This method deletes a NSManagedObject subclass from the appropriate context
 */
- (void)deleteObject:(NSManagedObject *)managedObject managedObjectContext:(NSManagedObjectContext *)context
{
    // delete the object
    [context deleteObject:managedObject];
}

/*
 * Method Name: objectForContext:
 * @object: The NSManagedObject to obtain the object from the context
 * @managedObjectContext: The NSManagedObjectContext to get the object from
 * Description: This method gets a NSManagedObject subclass from the appropriate context
 */
- (NSManagedObject *)managedObject:(NSManagedObject *)object forContext:(NSManagedObjectContext *)managedObjectContext
{
    return [managedObjectContext objectWithID:object.objectID];
}

/*
 * Method Name: refreshContext:
 * @managedObjectContext: A NSManagedObjectContext to refresh
 * Description: This method runs the refreshObject:mergeChanges: on the managed object context
 */
- (void)refreshContext:(NSManagedObjectContext *)managedObjectContext
{
    NSSet *objects = [managedObjectContext registeredObjects];
    for (NSManagedObject *object in objects)
    {
        [managedObjectContext refreshObject:object mergeChanges:YES];
    }
}

/*
 * Method Name: refreshObject:
 * @managedObject: A NSManagedObject to refresh
 * Description: This method runs the refreshObject:mergeChanges: on the managed object context
 */
- (void)refreshObject:(NSManagedObject *)managedObject
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    [context refreshObject:managedObject mergeChanges:YES];
}

/*
 * Method Name: executeFetchRequest:
 * @fetchRequest: An NSFetchRequest to run on the Managed Object Context
 * Description: This method runs an NSFetchRequest on the Managed Object Context and returns the results
 */
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest
{
    NSManagedObjectContext *context = [self managedObjectContextForCurrentThread];
    return [self executeFetchRequest:fetchRequest managedObjectContext:context];
}

/*
 * Method Name: executeFetchRequest:
 * @fetchRequest: An NSFetchRequest to run on the Managed Object Context
 * @managedObjectContext: A NSManagedObjectContext to execute the fetch request against
 * Description: This method runs an NSFetchRequest on the Managed Object Context and returns the results
 */
- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *results = nil;
    
    @try
    {
        NSError *error;
        results = [context executeFetchRequest:fetchRequest error:&error];
        
        if (error)
        {
            [CDKLogger LogError:@"CDKCoreDataManager - Error - Unable to fetch data: %@", error.localizedDescription];
            return nil;
        }
        
        if (results.count == 0)
            return nil;
    }
    @catch (NSException *exception)
    {
        [CDKLogger LogError:@"CDKCoreDataManager - Error - Unable to fetch data: %@", exception];
    }
    
    return results;
}

/*
 * Method Name: saveJsonObjects:objectMapping:objectClass:completion:
 * @jsonObjects: A dictionary that contains JSON data
 * @objectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @completion: A block to run after once the method is complete
 * @return: An array with the base level objects that were saved
 * Description: This method iterates through all JSON dictionaries in the NSArray and attempts to use the CDKObjectMapping object to save the data to the Core Data database
 * Note: This method does not require that the saveManagedObjectContext to be called as it already implements this method interally
 */
- (void)saveJsonObjects:(NSDictionary *)jsonDict
          objectMapping:(CDKObjectMapping *)objectMapping
                  objectClass:(__unsafe_unretained Class)managedObjectClass
             completion:(CDKCoreDataManagerJSONSaveCompletion)completion
{
    [self saveJsonObjects:jsonDict CDKObjectMapping:objectMapping objectClass:managedObjectClass managedObjectContext:nil saveContextOnComplete:YES completion:completion];
}

/*
 * Method Name: saveJsonObjects:objectMapping:objectClass:completion:
 * @jsonObjects: A dictionary that contains JSON data
 * @objectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @managedObjectContext: The NSManagedObjectContext to run the save on
 * @completion: A block to run after once the method is complete
 * @return: An array with the base level objects that were saved
 * Description: This method iterates through all JSON dictionaries in the NSArray and attempts to use the CDKObjectMapping object to save the data to the Core Data database
 * Note: This method does not require that the saveManagedObjectContext to be called as it already implements this method interally
 */
- (void)saveJsonObjects:(NSDictionary *)jsonDict
          objectMapping:(CDKObjectMapping *)objectMapping
                  objectClass:(__unsafe_unretained Class)managedObjectClass
   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
  saveContextOnComplete:(BOOL)saveContextOnComplete
             completion:(CDKCoreDataManagerJSONSaveCompletion)completion
{
    if (!managedObjectContext)
    {
        managedObjectContext = [self managedObjectContextForCurrentThread];
    }
    
    if (managedObjectContext == mainManagedObjectContext)
    {
        managedObjectContext = nil;
    }
    
    // create a core data operation and add it to the queue
    CoreDataOperation *operation = [[CoreDataOperation alloc] init];
    operation.json = jsonDict;
    operation.mapping = objectMapping;
    operation.objectClass = managedObjectClass;
    operation.mainContext = mainManagedObjectContext;
    operation.workerContext = managedObjectContext;
    operation.completion = completion;
    operation.saveContextOnComplete = saveContextOnComplete;
    [operationQueue addOperation:operation];
    
    if (!operationQueue.isSuspended)
    {
        [operationQueue setSuspended:NO];
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return path;
}

// Returns the URL to the application's Library directory.
- (NSURL *)applicationLibraryDirectory
{
    NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return path;
}

@end