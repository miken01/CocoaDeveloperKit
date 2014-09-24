//
//  VS_UITextField+Additions.h
//  VS_Utilities
//
//  Created by Neill, Michael on 12/19/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (CDKUITextField_Additions)

- (BOOL)validateCharactersInRange:(NSRange)range
                replacementString:(NSString *)replacementString
               allowNegativeValue:(BOOL)allowNegativeValue
                    textFieldType:(int)textFieldType
                        maxLength:(int)maxLength
                         maxValue:(int)maxValue;

@end

enum UITextFieldTypes {
    UITextFieldTypeDefault = 0,
    UITextFieldTypeInt = 1,
    UITextFieldTypeFloat = 2,
    UITextFieldTypeDouble = 3
};