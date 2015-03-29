//
//  NSString+Additions.m
//  CommonLibrary
//
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "NSString+Additions.h"
#import "RNCryptManager.h"
#import "NSNumber+Additions.h"

@implementation NSString (NSString_Additions)

/*
 * Method Name: sha1
 * @return: A NSString containing the sh1 encrypted version of the string
 * Description: This method returns a NSString containing the sh1 encrypted version of the string
 */
- (NSString*)sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

/*
 * Method Name: stringByStrippingHTML
 * @return: A NSString that is void of any HTML characters
 * Description: This method removes all HTML characters from the reciver and returns a new NSString object
 */
- (NSString *)stringByStrippingHTML
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    return s;
}

/*
 * Method Name: stringByRemovingNonASCIICharacters
 * @return: A NSString that is void of any non ASCII characters
 * Description: This method removes all non ASCII characters from the reciver and returns a new NSString object
 */
- (NSString *)stringByRemovingNonASCIICharacters
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\x20-\x7E]" options:0 error:&error];
    NSString * modifiedText = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    
    return modifiedText;
}

/*
 * Method Name: stringByCheckingForNonASCIICharacters
 * @return: The number of ASCII characters in the string
 * Description: This method checks the string for ASCII characters and returns the number of matches
 */
- (NSUInteger)stringByCheckingForNonASCIICharacters
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\x20-\x7E]" options:0 error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    return matches;
}

/*
 * Method Name: stringByApplyingPhoneFormat
 * @return: A string formatted as a phone number
 * Description: This method will format the string as a phone number
 */
- (NSString *)stringByApplyingPhoneFormat
{
    if (self.length > 10)
        return nil;
    
    NSMutableString *formattedNumber = [NSMutableString stringWithString:self];
    
    switch ([self length])
    {
        case 10:
        {
            [formattedNumber insertString:@"(" atIndex:0];
            [formattedNumber insertString:@") " atIndex:4];
            [formattedNumber insertString:@"-" atIndex:9];
            
            return formattedNumber;
        }
            break;
        case 7:
        {
            [formattedNumber insertString:@"-" atIndex:4];
            
            return formattedNumber;
        }
            
        default:
            return formattedNumber;
            break;
    }
    
    return formattedNumber;
}

- (NSString*) stringByReplacingOccurrencesOfRegex:(NSString*)regexString withString:(NSString*)replaceWithString
{
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange fullrange = NSMakeRange(0,self.length);
    return [regex stringByReplacingMatchesInString:self options:NSMatchingWithTransparentBounds range:fullrange withTemplate:replaceWithString];
}

- (NSString *)stringByConvertingToMoneyFormat
{
    NSString *text = self;
    
    if (!text || [text isEqual:@""])
    {
        text = @"0.00";
    }
    else
    {
        // remove dollar signs and decimals from the string
        text = [text stringByReplacingOccurrencesOfRegex:@"[^0-9]" withString:@""];
        
        // validate it's three digits, and if not, then add zero padding
        NSInteger strLen = text.length;
        
        if (strLen < 3)
        {
            NSMutableString *zeros = [[NSMutableString alloc] init];
            for (int i = 0; i < 3 - strLen; i++)
            {
                [zeros appendString:@"0"];
            }
            
            text = [zeros stringByAppendingString:text];
        }
        
        NSString *beforeDecimal = [text substringToIndex:text.length - 2];
        NSString *afterDecimal = [text substringFromIndex:text.length - 2];
        text = [NSString stringWithFormat:@"%@.%@", beforeDecimal, afterDecimal];
    }
    
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:text];
    
    return [decimalNumber currencyString];
}

/*
 * Method Name: validateEmail:
 * @emailAddress: An email address string
 * @return: boolean
 * Description: Validates an email address
 */

+ (BOOL)validateEmail:(NSString *)emailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

@end