//
//  MKLoadingIndicator.m
//  MKCommons
//
//  Created by Michael Kuck on 6/7/14.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import "MKLoadingIndicator.h"

static NSString *const CounterLock = @"CounterLock";

static NSUInteger _counter = 0;

//============================================================
//== Private Interface
//============================================================
@interface MKLoadingIndicator ()

@property (strong, atomic) NSTimer *timeoutTimer;
@property (assign, atomic) BOOL    isLoading;

+ (void)increaseCounter;
+ (void)decreaseCounter;
+ (void)updateLoadingIndicator;

- (void)timeoutTimerEvent:(id)sender;

@end

//============================================================
//== Implementation
//============================================================
@implementation MKLoadingIndicator

- (instancetype)init
{
    return [self initWithTimeout:0];
}

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;
{
    self = [super init];
    if (self) {
        _isLoading = YES;
        [MKLoadingIndicator increaseCounter];
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
            [MKLoadingIndicator decreaseCounter];
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
        [MKLoadingIndicator updateLoadingIndicator];
    }
}

+ (void)decreaseCounter
{
    @synchronized(CounterLock) {
        if (_counter > 0) {
            _counter--;
            [MKLoadingIndicator updateLoadingIndicator];
        }
    }
}

+ (void)updateLoadingIndicator
{
    if (_counter > 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)timeoutTimerEvent:(id)sender
{
    [self loadingDidFinish];
}

@end
