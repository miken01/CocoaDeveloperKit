//
//  CDKObjectMappingAttribute.h
//  CDKCoreDataManager
//
//  Created by Neill, Michael on 9/24/12.
//  Copyright (c) 2012 Velocitor Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDKObjectMappingAttribute : NSObject

#pragma mark - Properties

/*
 * @keyPath: The key path for the value in the the JSON dictonary
 */
@property (nonatomic, strong) NSString *keyPath;

/*
 * @attribute: The attribute name of the local object's property the value will be saved to
 */
@property (nonatomic, strong) NSString *attribute;

#pragma mark - Initializer

- (id)initWithKeyPath:(NSString *)keyPath attribute:(NSString *)attribute;

@end
