//
//  NSString+Additions.h
//  CommonLibrary
//
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Additions)

/*
 * Method Name: sha1
 * @return: A NSString containing the sh1 encrypted version of the string
 * Description: This method returns a NSString containing the sh1 encrypted version of the string
 */
- (NSString*)sha1;

/*
 * Method Name: stringByStrippingHTML
 * @return: A NSString that is void of any HTML characters
 * Description: This method removes all HTML characters from the reciver and returns a new NSString object
 */
- (NSString *)stringByStrippingHTML;

/*
 * Method Name: stringByRemovingNonASCIICharacters
 * @return: A NSString that is void of any non ASCII characters
 * Description: This method removes all non ASCII characters from the reciver and returns a new NSString object
 */
- (NSString *)stringByRemovingNonASCIICharacters;

/*
 * Method Name: stringByCheckingForNonASCIICharacters
 * @return: The number of ASCII characters in the string
 * Description: This method checks the string for ASCII characters and returns the number of matches
 */
-(NSUInteger *)stringByCheckingForNonASCIICharacters;

/*
 * Method Name: stringByApplyingPhoneFormat
 * @return: A string formatted as a phone number
 * Description: This method will format the string as a phone number
 */
- (NSString *)stringByApplyingPhoneFormat;

- (NSString*) stringByReplacingOccurrencesOfRegex:(NSString*)regexString withString:(NSString*)replaceWithString;
- (NSString *)stringByConvertingToMoneyFormat;

@end