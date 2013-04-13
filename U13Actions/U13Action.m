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
                obj:(NSObject *)obj
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

- (id)initWithQueue:(U13ActionQueue *)queue
                 vc:(UIViewController *)vc
               type:(U13ActionType)type
                obj:(NSObject *)obj
            success:(U13ActionHandler)success
            failure:(U13ActionHandler)failure
             result:(U13ActionDataHandler)result
{
    return [self initWithQueue:queue
                        parent:nil
                            vc:vc
                          type:type
                           obj:obj
                       success:success
                       failure:failure
                        result:result];
}


- (id)initWithParent:(U13Action *)action
             success:(U13ActionHandler)success
             failure:(U13ActionHandler)failure
{
    
    return [self initWithQueue:action.queue
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

- (BOOL)needsOnline {
    return NO;
}

- (BOOL)needsLogin {
    return NO;
}

- (BOOL)extendsOnline {
    return NO;
}

- (BOOL)authorized {
    return YES;
}

- (void)asyncSuccess:(NSString *)msg {
    if (_success && !self.isCancelled) {
        _success( self, msg );
        [_queue updateThrottle:self];
    }
}

- (void)success:(NSString *)msg {
    if (_success && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(asyncSuccess:) withObject:msg waitUntilDone:YES];
        } else {
            [self asyncSuccess:msg];
        }
    }
}

- (void)asyncFailure:(NSString *)msg {
    if (_failure && !self.isCancelled)
        _failure( self, msg );
}

- (void)failure:(NSString *)msg {
    if (_failure && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(asyncFailure:) withObject:msg waitUntilDone:YES];
        } else {
            [self asyncFailure:msg];
        }
    }
}

- (void)asyncResult:(id)obj {
    if (_result && !self.isCancelled) {
        _result(self,obj);
    }
}

- (void)result:(id)obj {
    if (_result && !self.isCancelled) {
        // if this is a top-level action with a view controller, assume the block needs to execute on the main thread
        if (_vc && !_parent) {
            [self performSelectorOnMainThread:@selector(asyncResult:) withObject:obj waitUntilDone:YES];
        } else {
            [self asyncResult:obj];
        }
    }
}

- (void)main {
    [_queue perform:self];
}

- (void)perform {
    // gets called back by the queue after validation and authorization is completed
}

- (U13ActionHandler)success_handler {
    return _success;
}

- (U13ActionHandler)failure_handler {
    return _failure;
}

- (U13ActionDataHandler)result_handler {
    return _result;
}

@end