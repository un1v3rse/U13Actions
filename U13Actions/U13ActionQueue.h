//
//  U13ActionQueue.h
//  U13Actions
//
//  Created by Brane on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import <Foundation/Foundation.h>

@class U13Action;

@interface U13ActionQueue : NSObject {
    NSOperationQueue *queue_;
    NSMutableDictionary *throttles_;
}

@property (readonly) BOOL loggedIn;

/** number of seconds an action can not be re-fired after being fired, 0 == no throttle */
- (NSTimeInterval)throttleSeconds:(U13Action *)action;
- (void)updateThrottle:(U13Action *)action;
- (void)resetThrottles;
- (void)resetThrottle:(U13Action *)action;

- (void)enqueue:(U13Action *)action;
- (void)enqueueWithoutValidation:(U13Action *)action;

- (void)validate:(U13Action *)action;
- (void)perform:(U13Action *)action;


@end
