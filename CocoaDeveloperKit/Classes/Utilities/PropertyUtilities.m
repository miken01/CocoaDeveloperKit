//
//  PropertyUtilities.m
//  CommonLibrary
//
//  Copyright (c) 2012 MKN Dev. All rights reserved.
//

#import "PropertyUtilities.h"
#import "objc/runtime.h"

@implementation PropertyUtilities

+ (NSDictionary *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = property_copyAttributeValue(property, "T");
        
        NSString *propertyName = [NSString stringWithFormat:@"%s", propName];
        NSMutableString *propertyType = [[NSMutableString alloc] initWithFormat:@"%s", propType];
        [propertyType replaceOccurrencesOfString:@"@" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, propertyType.length)];
        [propertyType replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, propertyType.length)];
        
        if (propertyType && ![propertyType isEqual:@""])
        {
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

@end
