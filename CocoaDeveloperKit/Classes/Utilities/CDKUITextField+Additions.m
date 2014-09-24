//
//  VS_UITextField+Additions.m
//  VS_Utilities
//
//  Created by Neill, Michael on 12/19/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import "CDKUITextField+Additions.h"

@implementation UITextField (CDKUITextField_Additions)

- (BOOL)validateCharactersInRange:(NSRange)range
                replacementString:(NSString *)replacementString
               allowNegativeValue:(BOOL)allowNegativeValue
                    textFieldType:(int)textFieldType
                        maxLength:(int)maxLength
                         maxValue:(int)maxValue
{
    // if the string is empty, then the user is deleting, so allow it
    if (!replacementString || [replacementString isEqual:@""]) {
        return YES;
    }
    
    // update the string
    NSString *newString = [self.text stringByReplacingCharactersInRange:range withString:replacementString];
    
    // if negatives are allowed, then validate the string with a negative in it
    if (allowNegativeValue == YES) {
        
        // if there is only one character in the string, and if it is a "-", then allow it
        if (newString.length == 1 && [replacementString isEqual:@"-"]) {
            return YES;
        }
        
        // if this is not the first character and if the first character is a "-", then strip it
        if (newString.length > 0) {
            NSString *firstChar = [newString substringToIndex:1];
            if ([firstChar isEqual:@"-"]) {
                newString = [newString substringFromIndex:1];
            }
        }
    }
    
    // verify that the value is not longer than the max length
    if (newString.length > maxLength) {
        return NO;
    }
    
    // verify that the max value has not been surpassed
    if (maxValue > 0 && newString.integerValue > maxValue) {
        return NO;
    }
    
    // setup new scanner to scan the string
    NSScanner *scanner = [NSScanner scannerWithString:replacementString];
    
    // scan the string based on the type
    switch (textFieldType) {
        case UITextFieldTypeInt:
        {
            int val;
            if (![scanner scanInt:&val]) {
                return NO;
            }
        }
            break;
            
        case UITextFieldTypeFloat:
        {
            float val;
            if (![scanner scanFloat:&val]) {
                return NO;
            }
        }
            break;
            
        case UITextFieldTypeDouble:
        {
            double val;
            if (![scanner scanDouble:&val]) {
                return NO;
            }
        }
            break;
    }
    
    scanner = nil;
    
    return YES;
}

@end