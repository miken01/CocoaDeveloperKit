//
//  NSDate+Additions.h
//  CommonLibrary
//
//  Created by Neill, Michael on 2/8/13.
//  Copyright (c) 2013 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSDateWeekDayStringMonday @"monday"
#define NSDateWeekDayStringTuesday @"tuesday"
#define NSDateWeekDayStringWednesday @"wednesday"
#define NSDateWeekDayStringThursday @"thursday"
#define NSDateWeekDayStringFriday @"friday"
#define NSDateWeekDayStringSaturday @"saturday"
#define NSDateWeekDayStringSunday @"sunday"

enum NSDateWeekDay
{
    NSDateWeekDayNone = 0,
    NSDateWeekDayMonday = 1,
    NSDateWeekDayTuesday = 2,
    NSDateWeekDayWednesday = 3,
    NSDateWeekDayThursday = 4,
    NSDateWeekDayFriday = 5,
    NSDateWeekDaySaturday = 6,
    NSDateWeekDaySunday = 7
};

@interface NSDate (NSDate_Additions)

- (NSString *)stringWithFormat:(NSString *)dateFormat;
+ (NSDate *)dateFromStringWithFormat:(NSString *)dateFormat string:(NSString *)string;

/*
 * Method Name: numericRepresentationOfWeekDay:
 * @weekDay: A string representation of the week day (E.x. monday, tuesday, wednesday, etc)
 * @return: The numeric representation fo the week day where monday is 1, sunday is 7 and nothing is 0
 * Description: This method returns the numeric representation of the weekDay string based on the standards at this URL http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 */
+ (int)numericRepresentationOfWeekDay:(NSString *)weekDay;

/*
 * Method Name: stringRepresentationOfNumericWeekDay:
 * @weekDay: A numeric representation of the week day (E.x. monday = 1, tuesday = 2, wednesday = 3, etc)
 * @return: The string representation fo the week day where 1 is monday, 7 is sunday and nothing is nil
 * Description: This method returns the numeric representation of the weekDay string based on the standards at this URL http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
 */
+ (NSString *)stringRepresentationOfNumericWeekDay:(int)weekDayInt;

/*
 * Method Name: dateForCurrentWeekDay:
 * @weekDay: A value of the NSDateWeekDay enum. NSDateWeekDayNone will return nil
 * @return: An NSDate object based on the given weekday assuming it is in the current week
 */
+ (NSDate *)dateForCurrentWeekDay:(enum NSDateWeekDay)weekDay;

/*
 * Method Name: dateForNextWeekDayOccurrence:
 * @weekDay: A value of the NSDateWeekDay enum. NSDateWeekDayNone will return nil
 * @return: An NSDate object that is the next occurrence of the given weekday
 */
+ (NSDate *)dateForNextWeekDayOccurrence:(enum NSDateWeekDay)weekDay;

@end