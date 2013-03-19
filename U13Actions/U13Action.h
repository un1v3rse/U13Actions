//
//  U13Action.h
//  U13Actions
//
//  Created by Brane on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

#import <Foundation/Foundation.h>

@class U13Action;
@class U13ActionQueue;

typedef int U13ActionType;

typedef void(^U13ActionHandler)(U13Action *action, NSString *message);
typedef void(^U13ActionDataHandler)(U13Action *action, id data);

/** An action that executes asynchronously and returns results in success, failure and/or result callbacks.
 
 */
@interface U13Action : NSOperation

@property (readonly) U13ActionQueue *queue;
@property (readonly) U13Action *parent;
@property (readonly) UIViewController *vc;
@property (readonly) U13ActionType type;
@property (readonly) id obj;
@property (readonly) NSString *throttle_key;
@property (readonly) BOOL needs_online;
@property (readonly) BOOL needs_login;
@property (readonly) BOOL extends_online;
@property (readonly) BOOL authorized;

+ (id)actionWithQueue:(U13ActionQueue *)queue
               parent:(U13Action *)parent
                   vc:(UIViewController *)vc
                 type:(U13ActionType)type
                  obj:(id)obj
              success:(U13ActionHandler)success
              failure:(U13ActionHandler)failure
               result:(U13ActionDataHandler)result;

+ (id)actionWithQueue:(U13ActionQueue *)queue
                   vc:(UIViewController *)vc
                 type:(U13ActionType)type
                  obj:(id)obj
              success:(U13ActionHandler)success
              failure:(U13ActionHandler)failure
               result:(U13ActionDataHandler)result;

+ (id)actionWithParent:(U13Action *)action
               success:(U13ActionHandler)success
               failure:(U13ActionHandler)failure;

- (void)success:(NSString *)msg;
- (void)failure:(NSString *)msg;
- (void)result:(id)obj;

- (void)perform;

@end
