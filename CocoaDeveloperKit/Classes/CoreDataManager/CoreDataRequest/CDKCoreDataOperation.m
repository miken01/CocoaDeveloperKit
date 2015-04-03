//
//  CoreDataOperation.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 10/8/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKCoreDataOperation.h"
#import "CDKCoreDataManager.h"
#import "CDKLogger.h"
#import "NSDate+Additions.h"
#import "PropertyUtilities.h"
#import "NSError+Additions.h"
#import "CDKCoreDataUtilities.h"

@implementation CoreDataOperation

- (id)init
{
    if ((self = [super init]))
    {
        // init the object
        _returnObjects = [[NSMutableArray alloc] init];
        
        // set the unique process ID
        _processID = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return self;
}

- (void)start
{
    NSLog(@"CoreDataOperation - start - Class: %@", self.objectClass);
    
    // allocate a new worker context for this operation
    if (!_workerContext)
    {
        _workerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _workerContext.persistentStoreCoordinator = _mainContext.persistentStoreCoordinator;
        _workerContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        _workerContext.undoManager = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_workerContext];
    }
    
    // perform save operation
    [_workerContext performBlock:^(void)
     {
         @autoreleasepool
         {
             NSLog(@"CDKCoreDataManager - saveJsonObjects - Class: %@", _objectClass);
             
             // save the JSON dictionary starting at the upper most level of the key path
             NSArray *objects = [self saveJSON:_json CDKObjectMapping:_mapping class:_objectClass level:0];
             
             // save the objects so we can access them later to be re-fetched and returned on the main thread
             if (objects.count > 0)
                 [_returnObjects addObjectsFromArray:objects];
             
             // perform synchronous process to save to the main MOC
             @try
             {
                 if (!_saveContextOnComplete)
                 {
                     // call the completion block
                     if (_completion)
                     {
                         _completion(objects, nil);
                     }
                 }
                 else
                 {
                     // push any changes in the main context to the background writer context
                     [_workerContext performBlockAndWait:^(void)
                      {
                          NSError *error = nil;
                          if (![_workerContext save:&error])
                              [CDKLogger LogError:@"CoreDataManger - Error Saving Managed Object Context: %@", error.localizedDescription];
                      }];
                     
                     
                     // submit changes back to the forground context
                     [_mainContext performBlock:^(void)
                      {
                          NSMutableArray *objects = [[NSMutableArray alloc] init];
                          
                          // iterate through the updated objects and find them in the main thread MOC
                          for (NSManagedObject *object in _returnObjects)
                          {
                              // get the object from the main managed object context
                              NSError *error;
                              NSManagedObject *obj = [_mainContext existingObjectWithID:object.objectID error:&error];
                              if (error)
                                  [CDKLogger LogError:@"CDKCoreDataManager - Error: %@", error.localizedDescription];
                              
                              if (obj)
                                  [objects addObject:obj];
                          }
                          
                          // call the completion block
                          if (_completion)
                          {
                              _completion(objects, nil);
                          }
                      }];
                 }
             }
             @catch (NSException *exception)
             {
                 [CDKLogger LogException:exception];
                 return;
             }
         }
     }];
}

#pragma mark - Notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification
{
    [_mainContext performBlock:^(void)
    {
        @try
        {
            [_mainContext mergeChangesFromContextDidSaveNotification:notification];
        }
        @catch (NSException *exception)
        {
            [CDKLogger LogException:exception];
        }
    }];
}

#pragma mark - Data Storage

/*
 * Method Name: saveJSON:withCDKObjectMapping:forClass:
 * @jsonDict: An NSDictionary that contains JSON dictionaries
 * @CDKObjectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @level: The level of the JSON element (number of times this method has been called)
 * @return: An array with the base level object IDs that were saved
 * Description: This method iterates through all JSON dictionaries in the NSArray and attempts to use the CDKObjectMapping object to save the data to the Core Data database
 */

- (NSArray *)saveJSON:(NSDictionary *)jsonDict
        CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                class:(Class)managedObjectClass
                level:(int)level
{
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    
    // get the data for the keypath
    NSString *keyPath = nil;
    id data = nil;
    if (CDKObjectMapping.keyPaths && CDKObjectMapping.keyPaths.count > 0)
    {
        keyPath = [CDKObjectMapping.keyPaths objectAtIndex:level];
        data = [jsonDict objectForKey:keyPath];
    }
    else
    {
        data = jsonDict;
    }
    
    // if data for the key path could not be found, then exit the method by returning nothing
    if (!data)
        return nil;
    
    // if there is another keypath to look for, then call this method again
    if (CDKObjectMapping.keyPaths && (CDKObjectMapping.keyPaths.count - 1) > level)
    {
        // increment the level
        level++;
        
        // if the data is a dictionary, then attemp to save it
        if ([data isKindOfClass:[NSDictionary class]])
        {
            NSArray *res = [self saveJSON:data CDKObjectMapping:CDKObjectMapping class:[managedObjectClass class] level:level];
            if (res.count > 0)
                [returnArr addObjectsFromArray:res];
        }
        else
        {
            // loop through each object in the array and attempt to save it
            for (id subData in (NSArray *)data)
            {
                NSArray *res = [self saveJSON:subData CDKObjectMapping:CDKObjectMapping class:[managedObjectClass class] level:level];
                if (res.count > 0)
                    [returnArr addObjectsFromArray:res];
            }
        }
    }
    // else process the data
    else
    {
        // if the data is a dictionary, then attemp to save it
        if ([data isKindOfClass:[NSDictionary class]])
        {
            // attemp to save the data to an object
            CDKBaseManagedObject *object = [self setObjectWithJson:data CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
            if (object)
            {
                // add object to the array
                [returnArr addObject:object];
            }
        }
        // else if the data is an array, then loop through the objects and attempt to save the objects with out any other keys
        else if ([data isKindOfClass:[NSArray class]])
        {
            // loop through each object in the array and attempt to save it
            for (id subData in (NSArray *)data)
            {
                // attemp to save the data to an object
                CDKBaseManagedObject *object = [self setObjectWithJson:subData CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
                if (object)
                {
                    // add object to the array
                    [returnArr addObject:object];
                }
            }
        }
    }
    
    return returnArr;
}

/*
 * Method Name: setObjectWithJson:withCDKObjectMapping:forClass:
 * @json: A JSON dictionary
 * @CDKObjectMapping: A CDKObjectMapping class setup with the mapping for the object class that is expected to be in the JSON dictionaries
 *                 This should be the mapping for the base objects.
 *                 If the JSON has sub objects, then the relationship mapping will be used providing it was setup.
 * @managedObjectClass: The class for the object that is expected to be in the JSON dictionaries
 * @return: An instance of CDKBaseManagedObject
 * Description: This method attempts to either find an existing object with the matching key, or creates a new object and then set's the values from the JSON dictionary to it
 */
- (CDKBaseManagedObject *)setObjectWithJson:(NSDictionary *)jsonDict
                           CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                                   class:(Class)managedObjectClass
{
    // try to get the managed object from the database
    CDKBaseManagedObject *managedObject = [self getObjectForData:jsonDict CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
    
    // if a managed object does not exist, then create a new one in the database
    if (!managedObject)
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:[CDKCoreDataUtilities cleanClassName:[managedObjectClass description]] inManagedObjectContext:_workerContext];
    
    // set the values for the object
    [self setValuesForObject:managedObject CDKObjectMapping:CDKObjectMapping json:jsonDict];
    
    return managedObject;
}

/*
 * Method Name: setValuesForObject:CDKObjectMapping:json:
 * @managedObject: The managed object to set the values to
 * @CDKObjectMapping: An CDKObjectMapping object to be used in order to dertmine how the data will be set to the object
 * @jsonDict: The JSON formatted NSDictionary that contains the data for the object, and it's sub-objects
 * Description: This method attempts to save the values from the JSON dictonary to the managed object, and it's sub-objects, using the object mapping.
 *              Unleash the Kraken!
 */
- (void)setValuesForObject:(CDKBaseManagedObject *)managedObject
             CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                      json:(NSDictionary *)jsonDict
{
    // get class properties
    NSDictionary *classPropertiesDict = [PropertyUtilities classPropsFor:[managedObject class]];
    
    // iterate through the object mapping to set the new values to the original object
    for (id mappingObject in CDKObjectMapping.mapping)
    {
        // if this is a simple pair class, then set the value
        if ([mappingObject isKindOfClass:[CDKObjectMappingAttribute class]])
        {
            // snag a proper pointer to the mapping pair object
            CDKObjectMappingAttribute *pair = (CDKObjectMappingAttribute *)mappingObject;
            
            // if they key exists, then update it, otherwise do nothing
            if ([[jsonDict allKeys] containsObject:pair.keyPath])
            {
                id val = [jsonDict valueForKey:pair.keyPath];
                
                // convert NULL to nil
                if (val == NULL || val == [NSNull null] || [val isEqual:@""])
                    val = nil;
                
                // convert the value based on the object's type
                val = [self convertValue:val attribute:pair.attribute classType:[classPropertiesDict objectForKey:pair.attribute]];
                
                // set the value
                [managedObject setValue:val forKey:pair.attribute];
            }
        }
        // else if this is a relationship, then save out the relationship object
        else if ([mappingObject isKindOfClass:[CDKObjectMappingRelationship class]])
        {
            [self setRelatedObjectsWithJSON:jsonDict parentObject:managedObject relationship:(CDKObjectMappingRelationship *)mappingObject level:0];
        }
    }
    
    // evalute the object
    [managedObject evaluateObjectWithDictionary:jsonDict];
}

/*
 * Method Name: setRelatedObjectsWithJSON:parentObject:relationship:level:
 * @jsonDict: An NSDictionary that contains JSON dictionaries
 * @parentObject: The Object that will containe the data
 * @relationship: A CDKObjectMappingRelationShip object to be used to save the data
 * @level: The level of the JSON element (number of times this method has been called)
 * Description: This method runs through the relationship mapping object and attempts to save the data to a new/or already existing object
 */
- (void)setRelatedObjectsWithJSON:(NSDictionary *)jsonDict
                     parentObject:(CDKBaseManagedObject *)parentManagedObject
                     relationship:(CDKObjectMappingRelationship *)relationship
                            level:(int)level
{
    // get the key path for this level
    NSString *keyPath = [relationship.keyPaths objectAtIndex:level];
    
    // if a key path could not be found, then exit the method by returning nothing
    if (!keyPath)
        return;
    
    // get the data for the keypath
    id data = [jsonDict objectForKey:keyPath];
    
    // if data for the key path could not be found, then exit the method by returning nothing
    if (!data)
        return;
    
    // if there is another keypath to look for, then call this method again
    if ((relationship.keyPaths.count - 1) > level)
    {
        // increment the level
        level++;
        
        // if the data is a dictionary, then attemp to save it
        if ([data isKindOfClass:[NSDictionary class]])
        {
            [self setRelatedObjectsWithJSON:data parentObject:parentManagedObject relationship:relationship level:level];
        }
        else
        {
            // loop through each object in the array and attempt to save it
            for (id subData in (NSArray *)data)
            {
                [self setRelatedObjectsWithJSON:subData parentObject:parentManagedObject relationship:relationship level:level];
            }
        }
    }
    // else process the data
    else
    {
        // if the sub dictionary is not NULL, then continue
        if (data && data != [NSNull null])
        {
            // if the sub dictionary is either an array or a set, the continue
            if ([data isKindOfClass:[NSArray class]])
            {
                // iterate through all sub objects and save/update them in the database
                for (NSDictionary *dict in data)
                {
                    [self setRelatedObjectWithJSON:dict parentObject:parentManagedObject relationship:relationship];
                }
            }
            // else if the sub objects is actually a dictionary, then just save/update the object to the database
            else if ([data isKindOfClass:[NSDictionary class]])
            {
                [self setRelatedObjectWithJSON:data parentObject:parentManagedObject relationship:relationship];
            }
        }
    }
}

- (void)setRelatedObjectWithJSON:(NSDictionary *)jsonDict
                    parentObject:(CDKBaseManagedObject *)parentManagedObject
                    relationship:(CDKObjectMappingRelationship *)relationship
{
    // if there is an inverse object attribute, then set the parent managed object to it
    if (relationship.relationship)
    {
        // get the related object from the parent object and set it to the sub managed object if it exists
        id relatedObject = [parentManagedObject valueForKey:relationship.relationship];
        
        // get/create the sub managed object
        
        // get object class name based on if there is a swift domain
        NSString *objectClassName = nil;
        
        if ([[CDKCoreDataManager sharedManager] swiftDomain] != nil)
            objectClassName = [NSString stringWithFormat:@"%@.%@", [[CDKCoreDataManager sharedManager] swiftDomain], relationship.objectClassName];
        else
            objectClassName = relationship.objectClassName;
        
        CDKObjectMapping *objectMapping = (CDKObjectMapping *)[NSClassFromString(objectClassName) getObjectMapping];
        CDKBaseManagedObject *subManagedObject = [self getObjectForData:jsonDict CDKObjectMapping:objectMapping class:NSClassFromString(objectClassName)];
        
        // create the object if it doesn't exist
        if (!subManagedObject)
        {
            subManagedObject = [NSEntityDescription insertNewObjectForEntityForName:objectClassName inManagedObjectContext:_workerContext];
        }
        
        // set the object's properties
        [self setValuesForObject:subManagedObject CDKObjectMapping:[[subManagedObject class] getObjectMapping] json:jsonDict];
        
        // set the relationship
        if (![relatedObject isKindOfClass:[NSSet class]])
        {
            [parentManagedObject setValue:subManagedObject forKey:relationship.relationship];
        }
        else
        {
            NSMutableSet *set = [(NSSet *)relatedObject mutableCopy];
            [set addObject:subManagedObject];
            [parentManagedObject setValue:set forKey:relationship.relationship];
        }
    }
}

#pragma mark - Object Mapping Getters

- (NSArray *)getObjectsForData:(id)data
                 CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                         class:(Class)managedObjectClass
{
    // get the predicate format and arguments array for the base level objects in dictionary
    NSDictionary *returnDict = [self buildPredicateAndArgumentsArrayForData:data CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
    NSString *format = (NSString *)[returnDict objectForKey:@"predFormat"];
    NSArray *args = (NSArray *)[returnDict objectForKey:@"predArgs"];
    
    if ([format isEqual:@""] || args.count == 0)
        return nil;
    
    // get the results
    NSArray *allobjects = [self getObjectsForClass:managedObjectClass predicate:nil sortDescriptors:nil managedObjectContext:_workerContext];
    NSArray *results = [allobjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:format argumentArray:args]];
    
    if (results.count > 0)
        return results;
    
    return nil;
}

- (CDKBaseManagedObject *)getObjectForData:(NSDictionary *)objectDict
                                inArray:(NSArray *)objects
                          CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                                  class:(Class)managedObjectClass
{
    if (objects && objects.count > 0)
    {
        NSDictionary *returnDict = [self buildPredicateAndArgumentsArrayForObject:objectDict CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
        NSString *predFormat = (NSString *)[returnDict objectForKey:@"predFormat"];
        NSArray *predArgs = (NSArray *)[returnDict objectForKey:@"predArgs"];
        
        if (![predFormat isEqual:@""] && predArgs.count > 0)
        {
            NSArray *results = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predFormat argumentArray:predArgs]];
            if (results && results.count > 0)
                return [results lastObject];
        }
    }
    return nil;
}

- (CDKBaseManagedObject *)getObjectForData:(NSDictionary *)objectDict
                          CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                                  class:(Class)managedObjectClass
{
    NSDictionary *returnDict = [self buildPredicateAndArgumentsArrayForObject:objectDict CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
    NSString *predFormat = (NSString *)[returnDict objectForKey:@"predFormat"];
    NSArray *predArgs = (NSArray *)[returnDict objectForKey:@"predArgs"];
    
    if (![predFormat isEqual:@""] && predArgs.count > 0)
    {
        NSArray *objects = [self getObjectsForClass:managedObjectClass predicate:[NSPredicate predicateWithFormat:predFormat argumentArray:predArgs] sortDescriptors:nil managedObjectContext:_workerContext];
        if (objects && objects.count > 0)
            return [objects lastObject];
    }
    
    return nil;
}

#pragma mark - Object Mapping Predicate Builders

- (NSDictionary *)buildPredicateAndArgumentsArrayForData:(id)data
                                           CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                                                   class:(Class)managedObjectClass
{
    NSMutableString *predFormat = [[NSMutableString alloc] initWithString:@""];
    NSMutableArray *predArgs = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]])
    {
        for (id subData in data)
        {
            NSDictionary *returnDict = (NSDictionary *)[self buildPredicateAndArgumentsArrayForData:subData CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
            NSString *format = (NSString *)[returnDict objectForKey:@"predFormat"];
            NSArray *args = (NSArray *)[returnDict objectForKey:@"predArgs"];
            
            if (![predFormat isEqual:@""])
                [predFormat appendString:@" OR "];
            
            [predFormat appendString:format];
            [predArgs addObjectsFromArray:args];
        }
    }
    else
    {
        NSDictionary *returnDict = [self buildPredicateAndArgumentsArrayForObject:(NSDictionary *)data CDKObjectMapping:CDKObjectMapping class:managedObjectClass];
        NSString *format = (NSString *)[returnDict objectForKey:@"predFormat"];
        NSArray *args = (NSArray *)[returnDict objectForKey:@"predArgs"];
        
        [predFormat appendString:format];
        [predArgs addObjectsFromArray:args];
    }
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:predFormat, predArgs, nil] forKeys:[NSArray arrayWithObjects:@"predFormat", @"predArgs", nil]];
}

- (NSDictionary *)buildPredicateAndArgumentsArrayForObject:(NSDictionary *)objectDict
                                             CDKObjectMapping:(CDKObjectMapping *)CDKObjectMapping
                                                     class:(Class)managedObjectClass
{
    NSDictionary *classPropertiesDict = [PropertyUtilities classPropsFor:managedObjectClass];
    
    NSMutableString *predFormat = [[NSMutableString alloc] initWithString:@""];
    NSMutableArray *predArgs = [[NSMutableArray alloc] init];
    
    if (CDKObjectMapping.objectUUID)
    {
        NSString *objectUUIDKeyPath = [self findAttribute:CDKObjectMapping.objectUUID inMapping:CDKObjectMapping];
        if (objectUUIDKeyPath && ![objectUUIDKeyPath isEqual:@""])
        {
            id objectUUIDValue = [objectDict valueForKey:objectUUIDKeyPath];
            if (objectUUIDValue)
            {
                [predFormat appendString:@"%K == %@"];
                [predArgs addObject:CDKObjectMapping.objectUUID];
                [predArgs addObject:objectUUIDValue];
            }
        }
    }
    else if ([CDKObjectMapping.primaryKeyAttribute isKindOfClass:[NSArray class]])
    {
        NSMutableString *format = [[NSMutableString alloc] initWithString:@""];
        NSMutableArray *args = [[NSMutableArray alloc] init];
        
        for (NSString *primaryKey in CDKObjectMapping.primaryKeyAttribute)
        {
            NSString *primaryAttributeKeyPath = [self findAttribute:primaryKey inMapping:CDKObjectMapping];
            if (primaryAttributeKeyPath)
            {
                id primaryKeyValue = [objectDict valueForKey:primaryAttributeKeyPath];
                primaryKeyValue = [self convertValue:primaryKeyValue attribute:primaryKey classType:[classPropertiesDict objectForKey:primaryKey]];
                if (primaryKeyValue)
                {
                    if (![format isEqual:@""])
                        [format appendString:@" AND "];
                    
                    [format appendString:@"%K == %@"];
                    [args addObject:primaryKey];
                    [args addObject:primaryKeyValue];
                }
            }
        }
        
        if (![format isEqual:@""])
        {
            [predFormat appendFormat:@"(%@)", format];
            [predArgs addObjectsFromArray:args];
        }
    }
    else if ([CDKObjectMapping.primaryKeyAttribute isKindOfClass:[NSString class]])
    {
        NSString *primaryAttributeKeyPath = [self findAttribute:CDKObjectMapping.primaryKeyAttribute inMapping:CDKObjectMapping];
        if (primaryAttributeKeyPath)
        {
            id primaryKeyValue = [objectDict valueForKey:primaryAttributeKeyPath];
            primaryKeyValue = [self convertValue:primaryKeyValue attribute:CDKObjectMapping.primaryKeyAttribute classType:[classPropertiesDict objectForKey:CDKObjectMapping.primaryKeyAttribute]];
            if (primaryKeyValue)
            {
                if (![predFormat isEqual:@""])
                    [predFormat appendString:@" AND "];
                
                [predFormat appendString:@"%K == %@"];
                [predArgs addObject:CDKObjectMapping.primaryKeyAttribute];
                [predArgs addObject:primaryKeyValue];
            }
        }
    }
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:predFormat, predArgs, nil] forKeys:[NSArray arrayWithObjects:@"predFormat", @"predArgs", nil]];
}

#pragma mark - Convenience Methods

/*
 * Method Name: getObjectsForClass:withPredicate:withSortDescriptors:
 * @class: The class for the object you want to get from the Core Data database
 * @predicate: An NSPredicate object used for filtering the object. If none is supplied then all objects will be returned
 * @sortDescriptors: An NSArray of NSSortDescriptors that will be applied to the NSFetchRequest object. If none is supplied then no sorting will be done.
 * @managedObjectContext: The managed object context to commit the changes to. If NULL then the default managed object context will be used
 * Description: This method returns all obects that match the conditions from the Core Data database
 */
- (NSArray *)getObjectsForClass:(Class)class
                      predicate:(NSPredicate *)predicate
                sortDescriptors:(NSArray *)sortDescriptors
           managedObjectContext:(NSManagedObjectContext *)moc
{
    NSArray *results = nil;
    
    @try
    {
        NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:[CDKCoreDataUtilities cleanClassName:[class description]]];
        if (predicate) {
            [fetchReq setPredicate:predicate];
        }
        if (sortDescriptors) {
            [fetchReq setSortDescriptors:sortDescriptors];
        }
        
        NSError *error;
        results = [moc executeFetchRequest:fetchReq error:&error];
        
        if (error)
        {
            [CDKLogger LogError:@"CDKCoreDataManager - Error - Unable to fetch data: %@", error.localizedDescription];
            results = nil;
        }
    }
    @catch (NSException *exception)
    {
        [CDKLogger LogError:@"CDKCoreDataManager - Error - Unable to fetch data: Unknown Error"];
    }
    
    return results;
}

- (id)convertValue:(id)val attribute:(NSString *)attribute classType:(NSString *)classType
{
    id newVal = val;
    
    // if there is a value and if it's a string value, then figure out what type of object this value should be and convert it to the appropriate format if needed
    if (newVal && [newVal isKindOfClass:[NSString class]])
    {
        if (classType && ![classType isEqual:@""])
        {
            // NSDate
            if ([classType isEqual:@"NSDate"])
            {
                // get the date
                NSDate *date = [NSDate dateFromStringWithFormat:[[CDKCoreDataManager sharedManager] dateFormat] string:newVal];
                
                // if the conversion was successful then set the value
                if (date)
                {
                    newVal = date;
                }
                // else the conversion failed so the given format is invalid, so set the value to nil and log an error
                else
                {
                    [CDKLogger LogError:@"CDKCoreDataManager Error: Date (%@) was not a valid format (%@)", attribute, newVal];
                    newVal = nil;
                }
            }
        }
    }
    
    return newVal;
}

- (NSString *)findAttribute:(NSString *)attribute inMapping:(CDKObjectMapping *)CDKObjectMapping
{
    for (CDKObjectMappingAttribute *pair in CDKObjectMapping.mapping) {
        if ([pair.attribute isEqual:attribute]) {
            return pair.keyPath;
        }
    }
    return nil;
}

@end
