//
//  CoreDataOperation.h
//  CoreDataManager
//
//  Created by Neill, Michael on 10/8/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^CompletionBlock)(NSArray *objects, NSError *error);

@class CDKObjectMapping;

@interface CoreDataOperation : NSOperation

@property (nonatomic, readonly) NSString *processID;

@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) CDKObjectMapping *mapping;
@property (nonatomic, assign) __unsafe_unretained Class objectClass;
@property (nonatomic, strong) NSManagedObjectContext *workerContext;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, copy) CompletionBlock completion;
@property (nonatomic, assign) BOOL saveContextOnComplete;

@property (nonatomic, strong) NSMutableArray *returnObjects;

@end
