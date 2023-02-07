//
//  PushManager.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CallStateConnecting,
    CallStateActive,
    CallStateOnHold,
    CallStateEnded
} CallState;
typedef enum : NSUInteger {
    ConnectedStatePending,
    ConnectedStateComplete
} ConnectedState;
typedef void (^StateChange)(void);
typedef void (^ConnectedStateChanged)(void);
typedef void (^Completion)(BOOL completed);
typedef void (^CallEndCompletion)(BOOL completed);

@interface Call : NSObject
@property(nonatomic ,strong)NSUUID *uuid;

@property(nonatomic ,assign)BOOL outgoing;

@property(nonatomic ,copy)NSString *handle;

@property(nonatomic ,assign)CallState callState;

@property(nonatomic ,assign)ConnectedState connectedstate;

@property(nonatomic ,copy)StateChange stateChange;

@property(nonatomic ,assign)BOOL isAutoEnd;//倒计时自动挂断
@property(nonatomic ,assign)BOOL isPushEnd;//收到静默推送挂断

@property(nonatomic ,copy)ConnectedStateChanged connectedStateChanged;

@property(nonatomic ,strong)NSDictionary *pushInfo;


- (instancetype)initWith:(NSUUID *)uuid
              isOutGoing:(BOOL)outgoing
                  handle:(NSString *)handle
                pushInfo:(NSDictionary *)pushInfo;

- (void)startCall:(Completion)completed;

- (void)answer;

- (void)end:(CallEndCompletion)completed;

@end

NS_ASSUME_NONNULL_END
