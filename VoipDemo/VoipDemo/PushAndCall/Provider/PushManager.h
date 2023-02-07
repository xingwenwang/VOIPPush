//
//  PushManager.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PushManager : NSObject
+ (instancetype)shareInstance;

//注册
- (void)voipRegistration;

//普通静默推送执行挂断
-(void)pushTypeStop:(NSDictionary *)pushInfo;
@end

NS_ASSUME_NONNULL_END
