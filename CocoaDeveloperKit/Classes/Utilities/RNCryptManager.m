//
//  RNCryptManager.m
//  CryptPic
//
//  Created by Rob Napier on 8/9/11.
//  Copyright (c) 2011 Rob Napier. All rights reserved.
//

#import "RNCryptManager.h"

// According to Apple documentaion, you can use a single buffer
// to do in-place encryption or decryption. This does not work
// in cases where you call CCCryptUpdate multiple times and you
// have padding enabled. radar://9930555
#define RNCRYPTMANAGER_USE_SAME_BUFFER 0
#define AES_ITERATIONS 10000;

//static const NSUInteger kMaxReadSize = 1024;

NSString * const
kRNCryptManagerErrorDomain = @"net.robnapier.RNCryptManager";

const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
const NSUInteger kAlgorithmKeySize = kCCKeySizeAES128;
const NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
const NSUInteger kPBKDFSaltSize = 8;
const NSUInteger kPBKDFRounds = AES_ITERATIONS;  // ~80ms on an iPhone 4

@interface NSOutputStream (Data)
- (BOOL)_CMwriteData:(NSData *)data error:(NSError *)error;
@end

@implementation NSOutputStream (Data)
- (BOOL)_CMwriteData:(NSData *)data error:(NSError *)error
{
  // Writing 0 bytes will close the output stream.
  // This is an undocumented side-effect. radar://9930518
  if (data.length > 0) {
    NSInteger bytesWritten = [self write:data.bytes
                               maxLength:data.length];
    if ( bytesWritten != data.length) {
      if (error) {
        error = [self streamError];
      }
      return NO;
    }
  }
  return YES;
}

@end
   
@interface NSInputStream (Data)
- (BOOL)_CMgetData:(NSData *)data
         maxLength:(NSUInteger)maxLength
             error:(NSError *)error;
@end

@implementation NSInputStream (Data)

- (BOOL)_CMgetData:(NSData *)data
         maxLength:(NSUInteger)maxLength
             error:(NSError *)error {

  NSMutableData *buffer = [NSMutableData dataWithLength:maxLength];
  if ([self read:buffer.mutableBytes maxLength:maxLength] < 0) {
    if (error) {
      error = [self streamError];
      return NO;
    }
  }
  
  data = buffer;
  return YES;
}

@end

@implementation RNCryptManager

+ (NSData *)randomDataOfLength:(size_t)length {
  NSMutableData *data = [NSMutableData dataWithLength:length];
  
  int result = SecRandomCopyBytes(kSecRandomDefault, 
                                  length,
                                  data.mutableBytes);
  NSAssert(result == 0, @"Unable to generate random bytes: %d",
           errno);
  
  return data;
}

+ (NSData *)AESKeyForPassword:(NSString *)password 
                         salt:(NSData *)salt {
  NSMutableData *
  derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
  
  int 
  result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
                                password.UTF8String,  // password
                                password.length,  // passwordLength
                                salt.bytes,           // salt
                                salt.length,          // saltLen
                                kCCPRFHmacAlgSHA1,    // PRF
                                kPBKDFRounds,         // rounds
                                derivedKey.mutableBytes, // derivedKey
                                derivedKey.length); // derivedKeyLen
  
  // Do not log password here
  NSAssert(result == kCCSuccess,
           @"Unable to create AES key for password: %d", result);
  
  return derivedKey;
}



+ (NSData *)encryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData *)iv
                            salt:(NSData *)salt
                           error:(NSError *)error {
  NSAssert(iv, @"IV must not be NULL");
  NSAssert(salt, @"salt must not be NULL");
  
//  iv = [self randomDataOfLength:kAlgorithmIVSize];
//  salt = [self randomDataOfLength:kPBKDFSaltSize];
  
  NSData *key = [self AESKeyForPassword:password salt:salt];
  
  size_t outLength;
  NSMutableData *
  cipherData = [NSMutableData dataWithLength:data.length +
                kAlgorithmBlockSize];

  CCCryptorStatus
  result = CCCrypt(kCCEncrypt, // operation
                   kAlgorithm, // Algorithm
                   kCCOptionPKCS7Padding, // options
                   key.bytes, // key
                   key.length, // keylength
                   iv.bytes,// iv
                   data.bytes, // dataIn
                   data.length, // dataInLength,
                   cipherData.mutableBytes, // dataOut
                   cipherData.length, // dataOutAvailable
                   &outLength); // dataOutMoved
    

  if (result == kCCSuccess) {
    cipherData.length = outLength;
  }
  else {
    if (error) {
      error = [NSError errorWithDomain:kRNCryptManagerErrorDomain
                                   code:result
                               userInfo:nil];
    }
    return nil;
  }
  
  return cipherData;
}

+ (NSData *)decryptedDataForData:(NSData *)data
                        password:(NSString *)password
                              iv:(NSData *)iv
                            salt:(NSData *)salt
                           error:(NSError *)error {

  NSData *key = [self AESKeyForPassword:password salt:salt];
  
  size_t outLength;
  NSMutableData *
  decryptedData = [NSMutableData dataWithLength:data.length];
  CCCryptorStatus
  result = CCCrypt(kCCDecrypt, // operation
                   kAlgorithm, // Algorithm
                   kCCOptionPKCS7Padding, // options
                   key.bytes, // key
                   key.length, // keylength
                   iv.bytes,// iv
                   data.bytes, // dataIn
                   data.length, // dataInLength,
                   decryptedData.mutableBytes, // dataOut
                   decryptedData.length, // dataOutAvailable
                   &outLength); // dataOutMoved
  
  if (result == kCCSuccess) {
    [decryptedData setLength:outLength];
  }
  else {
    if (result != kCCSuccess) {
      if (error) {
        error = [NSError
                  errorWithDomain:kRNCryptManagerErrorDomain
                  code:result
                  userInfo:nil];
      }
      return nil;
    }
  }
  
  return decryptedData;
}


@end
