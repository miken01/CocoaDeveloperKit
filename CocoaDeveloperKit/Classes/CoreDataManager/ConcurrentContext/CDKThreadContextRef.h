//
//  CDKThreadContextRef.h
//  CommonLibrary
//
//  Created by Neill, Michael on 7/1/13.
//  Copyright (c) 2013 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CDKThreadContextRef : NSObject

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
