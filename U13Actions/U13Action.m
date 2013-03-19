//
//  U13Action.m
//  U13Actions
//
//  Created by Brane on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import "U13Action.h"

#import "U13ActionQueue.h"

@interface U13Action()

@property (copy) U13ActionHandler success;
@property (copy) U13ActionHandler failure;
@property (copy) U13ActionDataHandler result;

@end

@implementation U13Action

- (id)initWithQueue:(U13ActionQueue *)queue
             parent:(U13Action *)parent
                 vc:(UIViewController *)vc
               type:(U13ActionType)type
                obj:(id)obj
            success:(U13ActionHandler)success
            failure:(U13ActionHandler)failure
             result:(U13ActionDataHandler)result
{
    if ((self = [super init])) {
        _queue = queue;
        _parent = parent;
        _vc = vc;
        _type = type;
        _obj = obj;
        _success = [success copy];
        _failure = [failure copy];
        _result = [result copy];
    }
    return self;
}

+ (id)actionWithQueue:(U13ActionQueue *)queue
               parent:(U13Action *)parent
                   vc:(UIViewController *)vc
                 type:(U13ActionType)type
                  obj:(id)obj
              success:(U13ActionHandler)success
              failure:(U13ActionHandler)failure
               result:(U13ActionDataHandler)result
{
    return [[self alloc] initWithQueue:queue
                                parent:parent
                                    vc:vc
                                  type:type
                                   obj:obj
                               success:success
                               failure:failure
                                result:nil] ;
}

+ (id)actionWithQueue:(U13ActionQueue *)queue
                   vc:(UIViewController *)vc
                 type:(U13ActionType)type
                  obj:(id)obj
              success:(U13ActionHandler)success
              failure:(U13ActionHandler)failure
               result:(U13ActionDataHandler)result
{
    return [[self alloc] initWithQueue:queue
                                parent:nil
                                    vc:vc
                                  type:type
                                   obj:obj
                               success:success
                               failure:failure
                                result:result] ;
}


+ (id)actionWithParent:(U13Action *)action
               success:(U13ActionHandler)success
               failure:(U13ActionHandler)failure
{
    
    return [[self alloc] initWithQueue:action.queue
                                parent:action
                                    vc:action.vc
                                  type:action.type
                                   obj:action.obj
                               success:success
                               failure:failure
                                result:action.result];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@:%d", [self class], _queue, _type];
}

- (NSString *)throttle_key {
    return nil;
}

- (BOOL)needs_online {
    return NO;
}

- (BOOL)needs_login {
    return NO;
}

- (BOOL)extends_online {
    return NO;
}

- (BOOL)authorized {
    return YES;
}

- (void)async_success:(NSString *)msg {
    if (_success && !self.isCancelled) {
        _success( self, msg );
        [_queue update_throttle:self];
    }
}

- (void)success:(NSString *)msg {
    if (_success && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(async_success:) withObject:msg waitUntilDone:YES];
        } else {
            [self async_success:msg];
        }
    }
}

- (void)async_failure:(NSString *)msg {
    if (_failure && !self.isCancelled)
        _failure( self, msg );
}

- (void)failure:(NSString *)msg {
    if (_failure && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(async_failure:) withObject:msg waitUntilDone:YES];
        } else {
            [self async_failure:msg];
        }
    }
}

- (void)async_result:(id)obj {
    if (_result && !self.isCancelled) {
        _result(self,obj);
    }
}

- (void)result:(id)obj {
    if (_result && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(async_result:) withObject:obj waitUntilDone:YES];
        } else {
            [self async_result:obj];
        }
    }
}

- (void)main {
    [_queue perform:self];
}

- (void)perform {
    // gets called back by the queue after validation and setup is completed
}

@end