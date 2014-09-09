//
//  CDKLoggerEvent.m
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import "CDKLoggerEvent.h"

@implementation CDKLoggerEvent

@synthesize category = _category;;
@synthesize label = _label;


+ (CDKLoggerEvent *)eventWithCategory:(NSString *)category label:(NSString *)label, ...
{
    CDKLoggerEvent *event = [[CDKLoggerEvent alloc] init];
    event.category = category;
    
    va_list args;
    va_start(args, label);
    
    // log string
    event.label = [[NSString alloc] initWithFormat:label arguments:args];
    
    va_end(args);
    
    return event;
}

@end
