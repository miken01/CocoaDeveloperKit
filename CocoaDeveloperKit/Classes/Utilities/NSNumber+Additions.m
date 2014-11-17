//
//  NSNumber+Additions.m
//  CommonLibrary
//
//  Created by Neill, Michael on 2/8/13.
//  Copyright (c) 2013 Velocitor Solutions. All rights reserved.
//

#import "NSNumber+Additions.h"

@implementation NSNumber (NSNumber_Additions)

- (NSString *)currencyString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    return [formatter stringFromNumber:self];
}

@end
