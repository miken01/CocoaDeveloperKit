//
//  NSObject+Additions.h
//  CommonLibrary
//
//  Copyright (c) 2012 MKN Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSError_Additions)

/*
 * Method Name: errorWithDomain:code:localizedDescription:
 * @domain: The domain for the error
 * @code: The error code
 * @localizedDescription: The description of the error
 * @return: An NSError object
 * Description: This method creates and returns an NSError object with the data passed into it
 */
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)localizedDescription;

@end
