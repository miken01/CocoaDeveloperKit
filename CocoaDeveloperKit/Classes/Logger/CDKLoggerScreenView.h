//
//  CDKLoggerScreenView.h
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import <Foundation/Foundation.h>

@interface CDKLoggerScreenView : NSObject

@property (nonatomic, strong) NSString *screenTitle;

+ (CDKLoggerScreenView *)screenViewWithScreenTitle:(NSString *)screenTitle, ...;

@end
