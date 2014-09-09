//
//  CDKActivityIndicatorView.m
//  CSGLibrary
//
//  Created by Mike Neill on 8/21/14.
//  Copyright (c) 2014 Cardinal Solutions. All rights reserved.
//

#import "CDKActivityIndicatorView.h"

@implementation CDKActivityIndicatorView
{
    UIActivityIndicatorView *activityIndicatorView;
    BOOL viewDrawn;
}

- (id)initWithSize:(CSGActivityIndicatorSize)indicatorSize inView:(UIView *)inView
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.backgroundColor = [UIColor clearColor];
        
        // set default properties
        _indicatorSize = indicatorSize;
        _parentView = inView;
        _tintColor = [UIColor whiteColor];
        _contentInset = UIEdgeInsetsMake(25, 25, 25, 25);
        _cornerRadius = 10;
        _allowUserInteractions = NO;
        
        // set frame
        self.frame = [self viewFrame];
        
        // add activity indicator view
        activityIndicatorView = [self activityIndicatorView];
        [self addSubview:activityIndicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // set frames
    self.frame = [self viewFrame];
    activityIndicatorView.frame = CGRectMake((self.bounds.size.width - activityIndicatorView.frame.size.width) / 2, (self.bounds.size.height - activityIndicatorView.frame.size.height) / 2, activityIndicatorView.frame.size.width, activityIndicatorView.frame.size.height);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // set colors
    activityIndicatorView.color = _tintColor;
    
    // set background
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_cornerRadius];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, bPath.CGPath);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75].CGColor);
    CGContextFillPath(ctx);
    
    viewDrawn = YES;
}

#pragma mark - Setters

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = [tintColor copy];
    
    if (viewDrawn)
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    
    if (viewDrawn)
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)setParentView:(UIView *)parentView
{
    _parentView = parentView;
    
    if (viewDrawn)
    {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

#pragma mark - Public Methods

- (void)startAnimating
{
    [activityIndicatorView startAnimating];
    
    if (!_allowUserInteractions)
        _parentView.userInteractionEnabled = NO;
}

- (void)stopAnimating
{
    [activityIndicatorView stopAnimating];
    _parentView.userInteractionEnabled = YES;
}

#pragma mark - Convenience Methods

- (CGRect)viewFrame
{
    // set frame
    CGSize activityIndicatorSize = [self activityIndicatorSize];
    CGSize viewSize = CGSizeMake(activityIndicatorSize.width + _contentInset.left + _contentInset.right, activityIndicatorSize.height + _contentInset.top + _contentInset.bottom);
    CGPoint position = CGPointMake((_parentView.bounds.size.width - viewSize.width) / 2, (_parentView.bounds.size.height - viewSize.height) / 2);
    return CGRectMake(position.x, position.y, viewSize.width, viewSize.height);
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    UIActivityIndicatorView *indicatorView = nil;
    
    switch (_indicatorSize)
    {
        case CSGActivityIndicatorSizeLarge:
        {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
            break;
            
        default:
        {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
            break;
    }
    
    return indicatorView;
}

- (CGSize)activityIndicatorSize
{
    switch (_indicatorSize)
    {
        case CSGActivityIndicatorSizeLarge:
        {
            return CGSizeMake(37, 37);
        }
            break;
            
        default:
        {
            return CGSizeMake(20, 20);
        }
            break;
    }
}

@end
