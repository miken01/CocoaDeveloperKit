//
//  NSObjectUtilities.m
//  CommonLibrary
//
//  Copyright (c) 2012 MKN Dev. All rights reserved.
//

#import "NSError+Additions.h"

@implementation NSObject (NSError_Additions)

/*
 * Method Name: errorWithDomain:code:localizedDescription:
 * @domain: The domain for the error
 * @code: The error code
 * @localizedDescription: The description of the error
 * @return: An NSError object
 * Description: This method creates and returns an NSError object with the data passed into it
 */
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}

@end
