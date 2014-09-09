//
//  CDKCoreDataUtilities.m
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 11/7/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKCoreDataUtilities.h"
#import "CDKCoreDataManager.h"
#import "CDKLogger.h"
#import "PropertyUtilities.h"
#import "Base64.h"

@implementation CDKCoreDataUtilities

/*
 * Method Name: convertObjectToDictionary:usingObjectMapping:
 * @object: An object to convert into a NSDictionary
 * @objectMapping: A ObjectMapping object used to convert the object
 * Description: This method using the supplied ObjectMapping to convert a object to a NSDictionary
 * Note: This method is really only used when it is nessecary to convert an object that is not a subclass of CDKBaseManagedObject
 */
+ (NSDictionary *)convertObjectToDictionary:(id)object usingObjectMapping:(CDKObjectMapping *)objectMapping
{
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    
    NSDictionary *objectProperties = [PropertyUtilities classPropsFor:[object class]];
    
    // iterate through the object mapping and set each property to the dictionary
    for (id mappingObject in objectMapping.mapping)
    {
        // if this is an attribute, then set it
        if ([mappingObject isKindOfClass:[CDKObjectMappingAttribute class]])
        {
            // snag a proper pointer to the attribute and get the object's value
            CDKObjectMappingAttribute *attribute = (CDKObjectMappingAttribute *)mappingObject;
            id value = [object valueForKey:attribute.attribute];
            
            // if no value, then set it to an NSNull object
            if (!value)
            {
                // set default value for type of class
                NSString *type = [objectProperties valueForKey:attribute.attribute];
                Class propClass = NSClassFromString(type);
                if (propClass == [NSString class] || propClass == [NSDate class])
                {
                    value = @"";
                }
                else if (propClass == [NSNumber class])
                {
                    value = [NSNumber numberWithInt:0];
                }
                else
                {
                    value = [[NSNull alloc] init];
                }
            }
            // else if this is a NSData object, then convert it to a Base64 string
            else if ([value isKindOfClass:[NSData class]])
            {
                value = [Base64 encode:value];
            }
            // else if this an NSDate, then convert it to a DotNet date/time string
            else if ([value isKindOfClass:[NSDate class]])
            {
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.locale = locale;
                dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
                dateFormatter.dateFormat = [[CDKCoreDataManager sharedManager] dateFormat];
                value = [dateFormatter stringFromDate:value];
            }
            
            // set the value to the proper keypath
            [returnDictionary setObject:value forKey:attribute.keyPath];
        }
        // else this is a relationship, so call the method again to get it's properties, and set it to a new dictionary
        else
        {    
            // snag a proper pointer to the attribute and the object's value
            CDKObjectMappingRelationship *relationship = (CDKObjectMappingRelationship *)mappingObject;
            id value = [object valueForKey:relationship.relationship];
            
            // if the value is null, then set an NSNull object
            if (!value)
            {
                // set default value for type of class
                NSString *type = [objectProperties valueForKey:relationship.relationship];
                Class propClass = NSClassFromString(type);
                if (propClass == [NSString class] || propClass == [NSDate class])
                {
                    value = @"";
                }
                else if (propClass == [NSNumber class])
                {
                    value = 0;
                }
                else
                {
                    value = [[NSNull alloc] init];
                }
                
                // set the return type
                [returnDictionary setObject:value forKey:relationship.keyPath];
            }
            // if this is an array or set then iterate through each object, call this method again to get each object's dictionary and add to an array
            else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]])
            {
                NSMutableArray *retArr = [[NSMutableArray alloc] init];
                for (id object in value)
                {
                    NSDictionary *retDict = [CDKBaseManagedObject convertCDKBaseManagedObjectToDictionary:object];
                    [retArr addObject:retDict];
                }
                
                // set the array to the proper keypath
                [returnDictionary setObject:retArr forKey:relationship.keyPath];
            }
            // else, this is a direct object relationship, so just call this method once to get the object's dictionary
            else
            {
                NSDictionary *retDict = [CDKBaseManagedObject convertCDKBaseManagedObjectToDictionary:value];
                [returnDictionary setObject:retDict forKey:relationship.keyPath];
            }
        }
    }
    
    return returnDictionary;
}

+ (NSString *)cleanClassName:(NSString *)className
{
    NSString *nClassName = [className copy];
    
    if ([nClassName rangeOfString:@"?"].location == NSNotFound)
    {
        NSRange r = [nClassName rangeOfString:@"."];
        nClassName = [nClassName substringFromIndex:r.location + r.length];
    }
    
    return nClassName;
}

@end
