//
//  NSDataAdditions.h
//  TT CAD iPad
//
//  Created by Michael Neill on 5/22/12.
//  Copyright (c) 2012 RD2 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSDataAdditions)

+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger) lineLength;

- (BOOL) hasPrefixBytes:(const void *) prefix length:(NSUInteger) length;
- (BOOL) hasSuffixBytes:(const void *) suffix length:(NSUInteger) length;

@end