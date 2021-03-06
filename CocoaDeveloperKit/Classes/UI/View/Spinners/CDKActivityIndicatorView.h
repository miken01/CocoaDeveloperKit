//
//  CDKActivityIndicatorView.h
//  CDKLibrary
//
//  Created by Mike Neill on 8/21/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CDKActivityIndicatorSize)
{
    CDKActivityIndicatorSizeDefault,
    CDKActivityIndicatorSizeLarge
};

@interface CDKActivityIndicatorView : UIView

@property (nonatomic, assign) CDKActivityIndicatorSize indicatorSize;
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL allowUserInteractions;

- (id)initWithSize:(CDKActivityIndicatorSize)indicatorSize inView:(UIView *)inView;

- (void)startAnimating;
- (void)stopAnimating;

@end
