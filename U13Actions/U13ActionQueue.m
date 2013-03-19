//
//  U13ActionQueue.m
//  U13Actions
//
//  Created by Chris Wright on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import "U13ActionQueue.h"

#import "U13Action.h"
#import "U13ActionLog.h"

@implementation U13ActionQueue

- (id)init {
    if ((self = [super init])) {
        queue_ = [[NSOperationQueue alloc] init];
        queue_.maxConcurrentOperationCount = 1;
        
        throttles_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)suspend_queue {
    [queue_ setSuspended:YES];
}

- (void)resume_queue {
    [queue_ setSuspended:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self class]];
}

- (BOOL)logged_in {
    return NO;
}


# pragma mark - Execution

- (NSTimeInterval)throttle_seconds:(U13Action *)action {
    return 0;
}

- (NSMutableDictionary *)throttles:(U13Action *)action {
    @synchronized (throttles_) {
        NSNumber *type_key = [NSNumber numberWithInt:action.type];
        NSMutableDictionary *objs = [throttles_ objectForKey:type_key];
        if (!objs) {
            objs = [NSMutableDictionary dictionary];
            [throttles_ setObject:objs forKey:type_key];
        }
        return objs;
    }
}

- (NSString *)throttle_time_key:(U13Action *)action {
    NSString *result = action.throttle_key;
    return result.length ? result : action.obj ? [[action.obj class] description] : @"<null>";
}

- (BOOL)throttled:(U13Action *)action {
    BOOL result = NO;
    NSTimeInterval seconds = [self throttle_seconds:action];
    if (seconds) {
        @synchronized (throttles_) {
            NSDate *next = [[self throttles:action] objectForKey:[self throttle_time_key:action]];
            result = next && [next compare:[NSDate date]] == NSOrderedDescending;
        }
    }
    return result;
}

- (void)update_throttle:(U13Action *)action {
    NSTimeInterval seconds = [self throttle_seconds:action];
    if (seconds) {
        @synchronized (throttles_) {
            [[self throttles:action] setObject:[[NSDate date] dateByAddingTimeInterval:seconds]
                                        forKey:[self throttle_time_key:action]];
        }
    }
}

- (void)reset_throttle:(U13Action *)action {
    @synchronized (throttles_) {
        [throttles_ removeObjectForKey:[self throttle_time_key:action]];
    }
}

- (void)reset_throttles {
    @synchronized (throttles_) {
        [throttles_ removeAllObjects];
    }
}

- (void)enqueue:(U13Action *)action {
    
    if ([self throttled:action]) {
        LOG_VF(@"throttled:%@", action);
        [action failure:nil];
        return;
    }
    
    // TODO: where should this check go?
//    if (queue_.isSuspended) {
//        if (login_window_handle_) {
//            // login dialog still up, this is legit
//            LOG_DF(@"Enqueued while login still showing: %@", action);
//        } else {
//            LOG_E(@"Queue suspended, everything OK? (It's not OK if you're not waiting for user input)");
//            queue_.suspended = NO; // recover in the field, don't want to prevent everything...
//        }
//    }
    
    LOG_VF(@"queued: %@", action);
    [self validate:[U13Action actionWithParent:action
                                        success:^(U13Action *action, NSString *message) {
                                            [queue_ addOperation:action.parent];
                                        }
                                        failure:^(U13Action *action, NSString *message) {
                                            [action.parent failure:message];
                                        }]];
}

- (void)enqueue_without_validation:(U13Action *)action {
    LOG_VF(@"queued: %@", action);
    [queue_ addOperation:action];
}


#pragma mark - Validation

- (void)do_validate:(U13Action *)action {
    [action success:nil];
}

- (void)validate:(U13Action *)action {
    [self do_validate:action];
}


#pragma mark - Perform

- (void)login:(U13Action *)action {
    [action failure:nil];
    
//    __weak U13ActionQueue *weakSelf = self;
//    if (refresh_token_.length) {
//        if ((!token_expiry_) || [token_expiry_ compare:[NSDate date]] == NSOrderedAscending) {
//            [self do_refresh:[U13Action actionWithParent:action
//                                                 success:^(U13Action *action, NSString *msg) {
//                                                     [weakSelf perform:action.parent];
//                                                 }
//                                                 failure:^(U13Action *action, NSString *msg) {
//                                                     // if the failure is real, this will cause the system to ask for a login again
//                                                     if (msg.length)
//                                                         [weakSelf perform:action.parent];
//                                                     else
//                                                         [action.parent failure:msg];
//                                                 } ]];
//            return;
//        }
//    }
//    
//    if (!self.logged_in) {
//        // stop the queue, we gotta ask the user something
//        queue_.suspended = YES;
//        [self login:[U13Action actionWithParent:action
//                                        success:^(U13Action *action, NSString *msg) {
//                                            queue_.suspended = NO;
//                                            [weakSelf perform:action.parent];
//                                        }
//                                        failure:^(U13Action *action, NSString *msg) {
//                                            queue_.suspended = NO;
//                                            [action.parent failure:msg];
//                                        } ]];
//        return;
//    }
    
}

- (void)perform:(U13Action *)action {
    
    if (action.needs_online) {
        if (![self network_available]) {
            [action failure:NSLocalizedString(@"This feature requires an internet connection.", @"This feature requires an internet connection.")];
            return;
        }
    }
    
    if (action.needs_login) {
        __weak U13ActionQueue *weakSelf = self;
        [self login:[U13Action actionWithParent:action
                                        success:^(U13Action *action, NSString *msg) {
                                            [weakSelf perform:action.parent];
                                        }
                                        failure:^(U13Action *action, NSString *msg) {
                                            [action.parent failure:msg];
                                        }]];
    }
    
    // now that we're logged in, check the authorization for the action
    if (!action.authorized) {
        [action failure:NSLocalizedString(@"You are not authorized to perform this action", @"You are not authorized to perform this action")];
        return;
    }
    
    // ok, we're authenticated, do the actual work
    [action perform];
    
    LOG_VF(@"performed: %@", action);
}

- (BOOL)network_available {
    return NO; // override
    //[[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}


@end

