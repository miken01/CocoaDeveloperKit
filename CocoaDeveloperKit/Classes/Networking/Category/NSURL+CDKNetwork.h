//
//  NSURL+CDKNetwork.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/19/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (NSURL_CDKNetwork)

- (NSURL *)URLByAppendingParameters:(NSArray *)parameters;

@end
