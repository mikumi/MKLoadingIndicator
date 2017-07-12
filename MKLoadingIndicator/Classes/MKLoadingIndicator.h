//
//  MKLoadingIndicator.h
//  MKCommons
//
//  Created by Michael Kuck on 6/7/14.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import <Foundation/Foundation.h>

//============================================================
//== Public Interface
//============================================================
@interface MKLoadingIndicator : NSObject

- (instancetype)init;
- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

- (void)loadingDidFinish;

@end
