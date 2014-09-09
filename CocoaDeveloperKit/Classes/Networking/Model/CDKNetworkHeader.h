//
//  CDKNetworkHeader.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/20/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDKNetworkHeader : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;

- (id)initWithKey:(NSString *)key value:(NSString *)value;

@end
