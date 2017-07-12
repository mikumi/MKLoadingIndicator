//
//  MKBigLoadingIndicator.h
//  MKCommons
//
//  Created by Michael Kuck on 6/7/14.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import <Foundation/Foundation.h>

//============================================================
//== Public Interface
//============================================================
@interface MKBigLoadingIndicator : NSObject

- (instancetype)init;
- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithTimeout:(NSTimeInterval)timeout;
- (instancetype)initWithText:(NSString *)text timeout:(NSTimeInterval)timeout;

- (void)loadingDidFinish;

@end
