//
//  CDKLoggerScreenView.m
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import "CDKLoggerScreenView.h"

@implementation CDKLoggerScreenView

@synthesize screenTitle = _screenTitle;


+ (CDKLoggerScreenView *)screenViewWithScreenTitle:(NSString *)screenTitle, ...
{
    CDKLoggerScreenView *screenView = [[CDKLoggerScreenView alloc] init];
    
    va_list args;
    va_start(args, screenTitle);
    
    // log string
    screenView.screenTitle = [NSString stringWithFormat:screenTitle, args];
    
    va_end(args);
    
    return screenView;
}

@end
