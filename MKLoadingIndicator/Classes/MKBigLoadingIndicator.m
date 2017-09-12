//
//  MKBigLoadingIndicator.m
//  MKCommons
//
//  Created by Michael Kuck on 6/7/14.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

// TODO: don't just copy and paste MKLoadingIndicator. Do it properly

#import "MKBigLoadingIndicator.h"

static NSString *const CounterLock = @"CounterLock";
static NSString *const ViewLock    = @"ViewLock";
static NSString *const TextLock    = @"TextLock";

static NSUInteger _counter           = 0;
static UIView     *_bigIndicatorView = nil;
static NSString   *_indicatorText    = @"Loading";

//============================================================
//== Private Interface
//============================================================
@interface MKBigLoadingIndicator ()

@property (strong, atomic) NSTimer *timeoutTimer;
@property (assign, atomic) BOOL    isLoading;

+ (void)increaseCounter;
+ (void)decreaseCounter;
+ (void)updateLoadingIndicator;
+ (void)bigNetworkActivityIndicatorVisible:(BOOL)isVisible;
+ (void)setIndicatorText:(NSString *)text;
+ (NSString *)indicatorText;

- (void)timeoutTimerEvent:(id)sender;

@end

//============================================================
//== Implementation
//============================================================
@implementation MKBigLoadingIndicator

- (instancetype)init
{
    return [self initWithText:nil timeout:0];
}

- (instancetype)initWithText:(NSString *)text
{
    return [self initWithText:text timeout:0];
}

- (instancetype)initWithTimeout:(NSTimeInterval)timeout
{
    return [self initWithText:nil timeout:0];
}

- (instancetype)initWithText:(NSString *)text timeout:(NSTimeInterval)timeout
{
    self = [super init];
    if (self) {
        _isLoading = YES;
        [MKBigLoadingIndicator setIndicatorText:text];
        [MKBigLoadingIndicator increaseCounter];
        if (timeout > 0) {
            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self
                                                           selector:@selector(timeoutTimerEvent:) userInfo:nil
                                                            repeats:NO];
        }
    }
    return self;
}

- (void)dealloc
{
    [self loadingDidFinish];
}

- (void)loadingDidFinish
{
    @synchronized(self) {
        if (self.isLoading) {
            self.isLoading = NO;
            [MKBigLoadingIndicator decreaseCounter];
            [self.timeoutTimer invalidate];
            self.timeoutTimer = nil;
        }
    }
}

//=== Private Implementation ===//
#pragma mark - Private Implementation

+ (void)increaseCounter
{
    @synchronized(CounterLock) {
        _counter++;
        [MKBigLoadingIndicator updateLoadingIndicator];
    }
}

+ (void)decreaseCounter
{
    @synchronized(CounterLock) {
        if (_counter > 0) {
            _counter--;
            [MKBigLoadingIndicator updateLoadingIndicator];
        }
    }
}

+ (void)updateLoadingIndicator
{
    if (_counter > 0) {
        [MKBigLoadingIndicator bigNetworkActivityIndicatorVisible:YES];
    } else {
        [MKBigLoadingIndicator bigNetworkActivityIndicatorVisible:NO];
    }
}

+ (void)bigNetworkActivityIndicatorVisible:(BOOL)isVisible
{
    @synchronized(ViewLock) {
        UIView *const rootView = [UIApplication sharedApplication].keyWindow;

        if (isVisible && _bigIndicatorView != nil) {
            [rootView bringSubviewToFront:_bigIndicatorView];
        } else if (isVisible && _bigIndicatorView == nil) {
            // Setup Frame
            CGFloat const viewWidth      = 100;
            CGFloat const viewHeight     = 100;

            // Indicator view container
            _bigIndicatorView = [[UIView alloc] init];
            _bigIndicatorView.layer.cornerRadius  = 10.0f;
            _bigIndicatorView.layer.masksToBounds = YES;
            _bigIndicatorView.backgroundColor     = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];

            // Indicator view
            UIActivityIndicatorView *const indicatorView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicatorView.frame = CGRectMake(35.0, 25.0, 30.0, 30.0);

            // Loading label
            UILabel *const label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 75.0, 80.0, 15.0)];
            label.backgroundColor = [UIColor clearColor];
            label.font            = [UIFont boldSystemFontOfSize:13.0];
            label.textColor       = [UIColor whiteColor];
            label.text            = [MKBigLoadingIndicator indicatorText];
            label.textAlignment   = NSTextAlignmentCenter;

            // Combine everything
            [_bigIndicatorView addSubview:indicatorView];
            [_bigIndicatorView addSubview:label];
            [indicatorView startAnimating];
            [rootView addSubview:_bigIndicatorView];
            // Set height & width and stay center when rotating
            [_bigIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [rootView addConstraint:[NSLayoutConstraint constraintWithItem:_bigIndicatorView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual toItem:rootView
                                                                 attribute:NSLayoutAttributeCenterX multiplier:1.0
                                                                  constant:0]];
            [rootView addConstraint:[NSLayoutConstraint constraintWithItem:_bigIndicatorView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual toItem:rootView
                                                                 attribute:NSLayoutAttributeCenterY multiplier:1.0
                                                                  constant:0]];
            [rootView addConstraint:[NSLayoutConstraint constraintWithItem:_bigIndicatorView attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0
                                                                   constant:viewWidth]];
            [rootView addConstraint:[NSLayoutConstraint constraintWithItem:_bigIndicatorView attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0
                                                                    constant:viewHeight]];

            [rootView bringSubviewToFront:_bigIndicatorView];
        } else if (_bigIndicatorView != nil) {
            [_bigIndicatorView removeFromSuperview];
            _bigIndicatorView = nil;
        }
    }
}

+ (void)setIndicatorText:(NSString *)text
{
    @synchronized(TextLock) {
        if (text != nil) {
            _indicatorText = text;
        }
    }
}

+ (NSString *)indicatorText
{
    @synchronized(TextLock) {
        return _indicatorText;
    }
}

- (void)timeoutTimerEvent:(id)sender
{
    [self loadingDidFinish];
}

@end
