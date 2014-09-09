//
//  CDKLoggerEvent.h
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import <Foundation/Foundation.h>

@interface CDKLoggerEvent : NSObject

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *label;

+ (CDKLoggerEvent *)eventWithCategory:(NSString *)category label:(NSString *)label, ...;

@end
