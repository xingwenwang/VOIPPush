//
//  PushManager.m
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import "PushManager.h"
#import <PushKit/PushKit.h>
#import "ProviderDelegate.h"

@interface PushManager ()<PKPushRegistryDelegate>
@property(nonatomic ,copy)NSString *topicTime_old;

@end

@implementation PushManager

+ (instancetype)shareInstance {
    static PushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PushManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - 第一步-VOIP注册
- (void)voipRegistration {
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    voipRegistry.delegate = self;
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    NSData *deviceToken = credentials.token;
    NSString *token = @"";
    if (@available(iOS 13.0, *)) {
        const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
        NSMutableString *myToken  = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
        for (int i = 0; i < deviceToken.length; i++) {
            [myToken appendFormat:@"%02x", dataBuffer[i]];
        }
        token = (NSString *)[myToken copy];
    } else {
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
        NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:characterSet];
        token = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSLog(@"didUpdatePushCredentials token = %@", token);

    //[self savePushToken:token];
    //将token上传到后台服务器与用户绑定，与普通推送token处理方式一样。可以根据自己的业务处理。
}

#pragma mark - 第二步-收到VOIP推送信息-处理数据
/*
 *后台服务推送消息，与普通推送类似
 *脚本有差别
 */
/// iOS8.0-iOS11.0
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    [self didReceiveIncomingPushWithPayload:payload withCompletionHandler:^{}];
}

/// iOS11.0+
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type withCompletionHandler:(nonnull void (^)(void))completion {
    [self didReceiveIncomingPushWithPayload:payload withCompletionHandler:completion];
}

- (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload withCompletionHandler:(nonnull void (^)(void))completion{
    
    //推送内容解析
    NSString *action = [payload.dictionaryPayload objectForKey:@"action"];
    NSString *title = [payload.dictionaryPayload objectForKey:@"title"];
    title = title == nil?@"voip标题":title;//title为nil崩溃
    
    //检查是否已有通话
    if ([[ProviderDelegate shareInstance] checkHadIncomingCall]) {
        [[ProviderDelegate shareInstance] changeHadIncomingInfopushInfo:payload.dictionaryPayload];
    }else{
        //没有通话可以展示系统通话界面
        [[ProviderDelegate shareInstance] reportIncomingCallHandle:title pushInfo:payload.dictionaryPayload withCompletionHandler:completion];
    }
}


@end


