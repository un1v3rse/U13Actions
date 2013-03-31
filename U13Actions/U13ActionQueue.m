//
//  U13ActionQueue.m
//  U13Actions
//
//  Created by Brane on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import "U13ActionQueue.h"

#import "U13Action.h"
#import "U13ActionLog.h"

@interface U13ActionQueue()

@property (assign) BOOL loginShowing;

@end

@implementation U13ActionQueue

- (id)init {
    if ((self = [super init])) {
        queue_ = [[NSOperationQueue alloc] init];
        queue_.maxConcurrentOperationCount = 1;
        
        throttles_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)suspendQueue {
    [queue_ setSuspended:YES];
}

- (void)resumeQueue {
    [queue_ setSuspended:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self class]];
}


# pragma mark - Execution

- (NSTimeInterval)throttleSeconds:(U13Action *)action {
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

- (NSString *)throttleTimeKey:(U13Action *)action {
    NSString *result = action.throttleKey;
    return result.length ? result : action.obj ? [[action.obj class] description] : @"<null>";
}

- (BOOL)throttled:(U13Action *)action {
    BOOL result = NO;
    NSTimeInterval seconds = [self throttleSeconds:action];
    if (seconds) {
        @synchronized (throttles_) {
            NSDate *next = [[self throttles:action] objectForKey:[self throttleTimeKey:action]];
            result = next && [next compare:[NSDate date]] == NSOrderedDescending;
        }
    }
    return result;
}

- (void)updateThrottle:(U13Action *)action {
    NSTimeInterval seconds = [self throttleSeconds:action];
    if (seconds) {
        @synchronized (throttles_) {
            [[self throttles:action] setObject:[[NSDate date] dateByAddingTimeInterval:seconds]
                                        forKey:[self throttleTimeKey:action]];
        }
    }
}

- (void)resetThrottle:(U13Action *)action {
    @synchronized (throttles_) {
        [throttles_ removeObjectForKey:[self throttleTimeKey:action]];
    }
}

- (void)resetThrottles {
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
    
    if (queue_.isSuspended) {
        if (self.loginShowing) {
            // login dialog still up, this is legit
            LOG_DF(@"Enqueued while login still showing: %@", action);
        } else {
            LOG_E(@"Queue suspended, everything OK? (It's not OK if you're not waiting for user input)");
            queue_.suspended = NO; // recover in the field, don't want to prevent everything...
        }
    }
    
    LOG_VF(@"queued: %@", action);
    [self validate:[[U13Action alloc] initWithParent:action
                                             success:^(U13Action *action, NSString *message) {
                                                 [queue_ addOperation:action.parent];
                                             }
                                             failure:^(U13Action *action, NSString *message) {
                                                 [action.parent failure:message];
                                             }]];
}

- (void)enqueueWithoutValidation:(U13Action *)action {
    LOG_VF(@"queued: %@", action);
    [queue_ addOperation:action];
}


#pragma mark - Validation

- (void)doValidate:(U13Action *)action {
    [action success:nil];
}

- (void)validate:(U13Action *)action {
    [self doValidate:action];
}


#pragma mark - Network

- (BOOL)networkAvailable {
    return NO; // override for network detection (if you need network for your actions)
}


#pragma mark - Authorization

- (BOOL)loggedIn {
    return NO; // override for login status (if you need login for your actions)
}

- (BOOL)refreshTokenValid {
    return NO; // override for refresh token status (if you support refresh tokens for authentication)
}

- (BOOL)refreshTokenExpired {
    return NO;
}

- (void)invalidateRefreshToken {
    
}


- (void)refreshAccessToken:(U13Action *)action {
    // override to refresh the access token without user intervention
    
    // call [action failure] if unable to refresh the token (or if the system does not support that)
    [action failure:nil];
}

- (void)showLogin:(U13Action *)action {
    // override to show login, presented from action's vc
    
    // call [action failure] if unable to show login screen
    [action failure:nil];
}


#pragma mark - Perform

- (void)perform:(U13Action *)action {
    
    if (action.needsOnline) {
        if (![self networkAvailable]) {
            [action failure:NSLocalizedString(@"This feature requires an internet connection.", @"This feature requires an internet connection.")];
            return;
        }
    }
    
    if (action.needsLogin) {
        __weak U13ActionQueue *weakSelf = self;
        if (self.refreshTokenValid) {
            if (self.refreshTokenExpired) {
                [self refreshAccessToken:[[U13Action alloc] initWithParent:action
                                                                   success:^(U13Action *action, NSString *msg) {
                                                                       [weakSelf perform:action.parent];
                                                                   }
                                                                   failure:^(U13Action *action, NSString *msg) {
                                                                       [self invalidateRefreshToken];
                                                                       // if the failure is real, this will cause the system to ask for a login again
                                                                       if (msg.length)
                                                                           [weakSelf perform:action.parent];
                                                                       else
                                                                           [action.parent failure:msg];
                                                                   }]];
                
                return; // the parent will be re-called after refresh is completed
            }
        }
        
        if (!self.loggedIn) {
            // stop the queue, we gotta ask the user something
            queue_.suspended = YES;
            self.loginShowing = YES;
            
            U13Action *loginAction = [[U13Action alloc] initWithParent:action
                                                               success:^(U13Action *action, NSString *msg) {
                                                                   queue_.suspended = NO;
                                                                   self.loginShowing = NO;
                                                                   [weakSelf perform:action.parent];
                                                               }
                                                               failure:^(U13Action *action, NSString *msg) {
                                                                   queue_.suspended = NO;
                                                                   self.loginShowing = NO;
                                                                   [action.parent failure:msg];
                                                               }];
            [self performSelectorOnMainThread:@selector(showLogin:) withObject:loginAction waitUntilDone:NO];
            return; // the parent will be re-called after refresh is completed
        }
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


@end

