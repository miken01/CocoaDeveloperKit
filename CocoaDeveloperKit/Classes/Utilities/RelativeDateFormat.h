//
//  RelativeDateFormat.h
//  CocoaDeveloperKit
//
//  Created by Michael Neill on 11/21/14.
//  Copyright (c) 2014 Mike Neill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (RelativeDateFormat)

-(NSString*) relativeStringFromDateIfPossible:(NSDate *)date;

@end
