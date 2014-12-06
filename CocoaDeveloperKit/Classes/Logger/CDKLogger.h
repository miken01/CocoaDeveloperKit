//
//  CDKLogger.h
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import <Foundation/Foundation.h>

#import "CDKLoggerScreenView.h"
#import "CDKLoggerEvent.h"

#pragma mark - Log Levels

typedef enum : NSUInteger {
    CDKLoggerLogLevelTrace     = 1,
    CDKLoggerLogLevelInfo      = 2,
    CDKLoggerLogLevelDebug     = 3,
    CDKLoggerLogLevelError     = 4,
    CDKLoggerLogLevelAll       = 5
} CDKLoggerLogLevel;

@interface CDKLogger : NSObject

#pragma mark - Properties

@property (nonatomic, strong) NSString *logFileName;
@property (nonatomic, assign) CDKLoggerLogLevel logLevel;

@property (weak, nonatomic, readonly) NSString *logFilePath;

#pragma mark Singleton Methods

+ (id)sharedLogger;

#pragma mark Class Methods

+ (void)startLoggerWithLogLevel:(CDKLoggerLogLevel)logLevel;

+ (void)LogTrace:(NSString *)format, ...;
+ (void)LogInfo:(NSString *)format, ...;
+ (void)LogDebug:(NSString *)format, ...;
+ (void)LogError:(NSString *)format, ...;
+ (void)LogException:(NSException *)exception;

+ (void)LogScreenView:(CDKLoggerScreenView *)screenView;
+ (void)LogEvent:(CDKLoggerEvent *)event;

#pragma mark - Exception Handeling

void exceptionHandler (NSException *exception);

#pragma mark - File System Methods

+ (NSString *)applicationDocumentsDirectory;

@end

@interface NSString (CDKLoggerFileAppend)

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

@end