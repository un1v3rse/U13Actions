//
//  U13ActionQueue.h
//  U13Actions
//
//  Created by Chris Wright on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import <Foundation/Foundation.h>

@class U13Action;

@interface U13ActionQueue : NSObject {
    NSOperationQueue *queue_;
    NSMutableDictionary *throttles_;
}

@property (readonly) BOOL logged_in;

/** number of seconds an action can not be re-fired after being fired, 0 == no throttle */
- (NSTimeInterval)throttle_seconds:(U13Action *)action;
- (void)update_throttle:(U13Action *)action;
- (void)reset_throttles;
- (void)reset_throttle:(U13Action *)action;

- (void)enqueue:(U13Action *)action;
- (void)enqueue_without_validation:(U13Action *)action;

- (void)validate:(U13Action *)action;
- (void)perform:(U13Action *)action;


@end
