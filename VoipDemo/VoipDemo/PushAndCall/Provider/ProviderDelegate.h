//
//  ProviderDelegate.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//


#import <CallKit/CallKit.h>
#import "CallManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface ProviderDelegate : NSObject

+ (instancetype)shareInstance;

//接电话
- (void)reportIncomingCallHandle:(NSString *)handle
                        pushInfo:(NSDictionary *)pushInfoDic
           withCompletionHandler:(nonnull void (^)(void))completion;

//替换推送内容
-(void)changeHadIncomingInfopushInfo:(NSDictionary *)pushInfoDic;
//挂断
-(void) stopCalling;
//静默推送-挂断
-(void) pushStopCalling;

//检查是否有电话
-(BOOL)checkHadIncomingCall;
//检查是否有电话-正在通话中
-(BOOL)checkHadCallActive:(NSString *)action;

@end

NS_ASSUME_NONNULL_END
