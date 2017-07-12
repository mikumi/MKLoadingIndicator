//
//  MKLoadingIndicator.m
//  MKCommons
//
//  Created by Michael Kuck on 6/7/14.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import "MKLoadingIndicator.h"

#import "MKLog.h"

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

/*
 * (Inherited Comment)
 */
- (instancetype)init
{
    return [self initWithTimeout:0];
}

/**
 * // DOCU: this method comment needs be updated.
 */
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

/*
 * (Inherited Comment)
 */
- (void)dealloc
{
    MKLogDebug(@"dealloc");
    [self loadingDidFinish];
}

/**
 * // DOCU: this method comment needs be updated.
 */
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

/**
 * // DOCU: this method comment needs be updated.
 */
+ (void)increaseCounter
{
    @synchronized(CounterLock) {
        _counter++;
        MKLogDebug(@"Counter was increased to %lu", (unsigned long)_counter);
        [MKLoadingIndicator updateLoadingIndicator];
    }
}

/**
 * // DOCU: this method comment needs be updated.
 */
+ (void)decreaseCounter
{
    @synchronized(CounterLock) {
        if (_counter > 0) {
            _counter--;
            MKLogDebug(@"Counter was decreased to %lu", (unsigned long)_counter);
            [MKLoadingIndicator updateLoadingIndicator];
        }
    }
}

/**
 * // DOCU: this method comment needs be updated.
 */
+ (void)updateLoadingIndicator
{
#ifndef MKCOMMONS_APP_EXTENSIONS
    if (_counter > 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
#endif
}

/**
 * // DOCU: this method comment needs be updated.
 */
- (void)timeoutTimerEvent:(id)sender
{
    MKLogDebug(@"Timeout has been reached.");
    [self loadingDidFinish];
}

@end
