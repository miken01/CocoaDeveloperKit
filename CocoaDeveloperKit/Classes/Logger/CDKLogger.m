//
//  CDKLogger.m
//  TT CAD iPad
//
//  Created by Michael Neill on 1/20/13.
//
//

#import "CDKLogger.h"

@implementation CDKLogger

static CDKLogger *sharedLogger = nil;

@synthesize logFileName     = _logFileName;
@synthesize logLevel        = _logLevel;

dispatch_queue_t backgroundQueue;
const char *backgroundQueueName = "CDKLogger.BackgroundQueue";

#pragma mark Singleton Methods

+ (id)sharedLogger
{
    // allow for safe multi-threading and init the object if necessary
    @synchronized (self)
    {
        if (sharedLogger == nil)
        {
            sharedLogger = [[super allocWithZone:NULL] init];
        }
    }
    return sharedLogger;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedLogger];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Class Methods

+ (void)startLoggerWithLogLevel:(CDKLoggerLogLevel)logLevel
{
    // init the logger and set the log level
    CDKLogger *logger = [CDKLogger sharedLogger];
    logger.logLevel = logLevel;
}

+ (void)LogTrace:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    // log string
    [CDKLogger LogTrace:format args:args];
    
    va_end(args);
}

+ (void)LogTrace:(NSString *)format args:(va_list)args
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // if the log level is not set for this type of logging, then do nothing
    if (logger.logLevel !=  CDKLoggerLogLevelAll && logger.logLevel != CDKLoggerLogLevelTrace)
        return;
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Trace - %@", format] arguments:args];
}

+ (void)LogInfo:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [CDKLogger LogInfo:format args:args];
    
    va_end(args);
}

+ (void)LogInfo:(NSString *)format args:(va_list)args
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // if the log level is not set for this type of logging, then do nothing
    if (logger.logLevel !=  CDKLoggerLogLevelAll && logger.logLevel != CDKLoggerLogLevelInfo)
        return;
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Info - %@", format] arguments:args];
}

+ (void)LogDebug:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [CDKLogger LogDebug:format args:args];
    
    va_end(args);
}

+ (void)LogDebug:(NSString *)format args:(va_list)args
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // if the log level is not set for this type of logging, then do nothing
    if (logger.logLevel !=  CDKLoggerLogLevelAll && logger.logLevel != CDKLoggerLogLevelDebug)
        return;
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Debug - %@", format] arguments:args];
}

+ (void)LogError:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [CDKLogger LogError:format args:args];
    
    va_end(args);
}

+ (void)LogError:(NSString *)format args:(va_list)args
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // if the log level is not set for this type of logging, then do nothing
    if (logger.logLevel !=  CDKLoggerLogLevelAll && logger.logLevel != CDKLoggerLogLevelError)
        return;
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Error - %@", format] arguments:args];
}

+ (void)LogException:(NSException *)exception
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // log string
    NSString *string = [NSString stringWithFormat:@"****** Exception ******\nName - %@\nReason: %@ \nCall Stack Return Address: %@ \nCall Stack: %@", exception.name, exception.reason, exception.callStackReturnAddresses, exception.callStackSymbols];
    [logger log:string arguments:nil];
}

+ (void)LogScreenView:(CDKLoggerScreenView *)screenView
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Screen View - %@", screenView.screenTitle] arguments:nil];
}

+ (void)LogEvent:(CDKLoggerEvent *)event
{
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // log string
    [logger log:[NSString stringWithFormat:@"Log Event - %@ - %@", event.category, event.label] arguments:nil];
}

#pragma mark Initialization Methods

- (id)init
{
    if (self = [super init])
    {
        // init the logger
        [self initLogger];
    }
    return self;
}

- (void)dealloc
{
    sharedLogger = nil;
}

#pragma mark - Init Logger Methods

- (void)initLogger
{
    // set the exception handler
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    // setup the background queue
    backgroundQueue = dispatch_queue_create(backgroundQueueName, NULL);
    
    // set the default log file name
    if (!_logFileName)
        _logFileName = @"RunLog.log";
    
    // get the file path
    NSString *filePath = self.logFilePath;
    
    // if there is already a logger filename, then remove it
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            NSLog(@"Logger - Error: %@", error.localizedDescription);
    }
    
    // create a new run-time log
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
}

#pragma mark - Property Getters & Setters

- (NSString *)logFilePath
{
    // get the file path
    NSString *filePath = [CDKLogger applicationDocumentsDirectory];
    return [filePath stringByAppendingPathComponent:_logFileName];
}

#pragma mark - Logging Methods

- (void)log:(NSString *)format arguments:(va_list)args
{
    // perform logging on background thread to improve performance while file system is writing to the log files
    dispatch_sync(backgroundQueue,^
    {
        // get the log string and append a new line and the current date/time to it
        NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *outString = [[NSString alloc] initWithFormat:@"\n%@: %@", [NSDate date], logString];
        
        // log to console
        NSLog(@"Logger: %@", logString);
        
        // write the string to the file path
        [outString appendToFile:self.logFilePath usingEncoding:NSUTF8StringEncoding];
        
        outString = nil;
        
        logString = nil;
    });
}

#pragma mark - Exception Handeling

void exceptionHandler (NSException *exception)
{
    // log the exception
    [CDKLogger LogException:exception];
    
    NSString *filePath = [CDKLogger applicationDocumentsDirectory];
    filePath = [filePath stringByAppendingPathComponent:@"Crash.log"];
    
    // if there is already a crash log file, then remove it
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            NSLog(@"Logger - Error: %@", error.localizedDescription);
    }
    
    CDKLogger *logger = [CDKLogger sharedLogger];
    
    // create the crash log file
    NSError *error = nil;
    if (![[NSFileManager defaultManager] copyItemAtPath:logger.logFilePath toPath:filePath error:&error])
        NSLog(@"Logger - Error: %@", error.localizedDescription);
}

#pragma mark - File System Methods

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end

@implementation NSString (CDKLoggerFileAppend)

- (BOOL)appendToFile:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (fh == nil)
        return [self writeToFile:path atomically:YES encoding:encoding error:nil];
    
    [fh truncateFileAtOffset:[fh seekToEndOfFile]];
    NSData *encoded = [self dataUsingEncoding:encoding];
    
    if (encoded == nil) return NO;
    
    [fh writeData:encoded];
    return YES;
}
@end