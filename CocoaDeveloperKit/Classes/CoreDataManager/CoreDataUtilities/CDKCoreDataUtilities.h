//
//  CDKCoreDataUtilities.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 11/7/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDKObjectMapping;

@interface CDKCoreDataUtilities : NSObject

/*
 * Method Name: convertObjectToDictionary:usingCDKObjectMapping:
 * @object: An object to convert into a NSDictionary
 * @CDKObjectMapping: A CDKObjectMapping object used to convert the object
 * Description: This method using the supplied CDKObjectMapping to convert a object to a NSDictionary
 * Note: This method is really only used when it is nessecary to convert an object that is not a subclass of CDKBaseManagedObject
 */
+ (NSDictionary *)convertObjectToDictionary:(id)object usingObjectMapping:(CDKObjectMapping *)objectMapping;

+ (NSString *)cleanClassName:(NSString *)className;

@end
