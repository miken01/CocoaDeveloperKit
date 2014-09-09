//
//  NSDate+Additions.m
//  CommonLibrary
//
//  Created by Neill, Michael on 2/8/13.
//  Copyright (c) 2013 Velocitor Solutions. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (NSDate_Additions)

- (NSString *)stringWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)dateFromStringWithFormat:(NSString *)dateFormat string:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    return [dateFormatter dateFromString:string];
}

/*
 * Method Name: numericRepresentationOfWeekDay:
 * @weekDay: A string representation of the week day (E.x. monday, tuesday, wednesday, etc)
 * @return: The numeric representation fo the week day where monday is 1, sunday is 7 and nothing is 0
 * Description: This method returns the numeric representation of the weekDay string based on the standards at this URL http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 */
+ (int)numericRepresentationOfWeekDay:(NSString *)weekDay
{
    int returnVal = NSDateWeekDayNone;
    
    if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringMonday])
    {
        returnVal = NSDateWeekDayMonday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringTuesday])
    {
        returnVal = NSDateWeekDayTuesday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringWednesday])
    {
        returnVal = NSDateWeekDayWednesday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringThursday])
    {
        returnVal = NSDateWeekDayThursday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringFriday])
    {
        returnVal = NSDateWeekDayFriday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringSaturday])
    {
        returnVal = NSDateWeekDaySaturday;
    }
    else if ([weekDay.lowercaseString isEqualToString:NSDateWeekDayStringSunday])
    {
        returnVal = NSDateWeekDaySunday;
    }
    
    return returnVal;
}

/*
 * Method Name: stringRepresentationOfNumericWeekDay:
 * @weekDay: A numeric representation of the week day (E.x. monday = 1, tuesday = 2, wednesday = 3, etc)
 * @return: The string representation fo the week day where 1 is monday, 7 is sunday and nothing is nil
 * Description: This method returns the numeric representation of the weekDay string based on the standards at this URL http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 */
+ (NSString *)stringRepresentationOfNumericWeekDay:(int)weekDayInt
{
    NSString *returnVal = nil;
    
    switch (weekDayInt)
    {
        case NSDateWeekDayMonday:
            returnVal = NSDateWeekDayStringMonday;
            break;
            
        case NSDateWeekDayTuesday:
            returnVal = NSDateWeekDayStringTuesday;
            break;
            
        case NSDateWeekDayWednesday:
            returnVal = NSDateWeekDayStringWednesday;
            break;
            
        case NSDateWeekDayThursday:
            returnVal = NSDateWeekDayStringThursday;
            break;
            
        case NSDateWeekDayFriday:
            returnVal = NSDateWeekDayStringFriday;
            break;
            
        case NSDateWeekDaySaturday:
            returnVal = NSDateWeekDayStringSaturday;
            break;
            
        case NSDateWeekDaySunday:
            returnVal = NSDateWeekDayStringSunday;
            break;
    }
    
    return returnVal;
}

/*
 * Method Name: dateForCurrentWeekDay:
 * @weekDay: A value of the NSDateWeekDay enum. NSDateWeekDayNone will return nil
 * @return: An NSDate object based on the given weekday assuming it is in the current week
 */
+ (NSDate *)dateForCurrentWeekDay:(enum NSDateWeekDay)weekDay
{
    // if the weekday is none, then return nothing
    if (weekDay == NSDateWeekDayNone)
        return nil;
    
    // get current date in parts to be used in equation below
    NSDate *currentDate = [NSDate date];
    NSString *currentMonthStr = [currentDate stringWithFormat:@"M"];
    NSString *currentYearStr = [currentDate stringWithFormat:@"yyyy"];
    
    NSString *currentWeekDayStr = [currentDate stringWithFormat:@"eeee"];
    int currentdayOfMonthInt = [(NSString *)[currentDate stringWithFormat:@"d"] intValue];
    int currentWeekDayInt = [NSDate numericRepresentationOfWeekDay:currentWeekDayStr];
    
    // get the selected day of the month based off of the current day of the month
    int givenWeekDayOfMonth = (weekDay - currentWeekDayInt) + currentdayOfMonthInt;
    
    NSString *givenDateString = [NSString stringWithFormat:@"%@/%d/%@", currentMonthStr, givenWeekDayOfMonth, currentYearStr];
    NSDate *givenDate = [NSDate dateFromStringWithFormat:@"M/d/yyyy" string:givenDateString];
    
    return givenDate;
}

/*
 * Method Name: dateForNextWeekDayOccurrence:
 * @weekDay: A value of the NSDateWeekDay enum. NSDateWeekDayNone will return nil
 * @return: An NSDate object that is the next occurrence of the given weekday
 */
+ (NSDate *)dateForNextWeekDayOccurrence:(enum NSDateWeekDay)weekDay
{
    // if the weekday is none, then return nothing
    if (weekDay == NSDateWeekDayNone)
        return nil;
    
    // get current date in parts to be used in equation below
    NSDate *currentDate = [NSDate date];
    NSString *currentWeekDayStr = [currentDate stringWithFormat:@"eeee"];
    int currentWeekDayInt = [NSDate numericRepresentationOfWeekDay:currentWeekDayStr];
    
    int weekDayInt = weekDay;
    
    // get the selected day of the month based off of the current day of the month
    int dayOffset = 0;
    if (weekDayInt < currentWeekDayInt)
    {
        dayOffset = (weekDayInt - currentWeekDayInt) + 7;
    }
    else
    {
        dayOffset = weekDayInt - currentWeekDayInt;
    }
    
    // get the number of seconds that the day offset will be
    int timeInterval = dayOffset * 86400;
    return [currentDate dateByAddingTimeInterval:timeInterval];
}

@end
