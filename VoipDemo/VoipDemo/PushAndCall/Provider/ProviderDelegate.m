//
//  ProviderDelegate.m
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import "ProviderDelegate.h"
#import <UIKit/UIKit.h>

@interface ProviderDelegate ()<CXProviderDelegate>

@property(nonatomic ,strong)CallManager *callManager;
@property(nonatomic ,strong)CXProvider *provider;
@property(nonatomic ,strong)NSUUID *uuid;
@property(nonatomic ,assign)BOOL isHadReportIncomingCall;//是否已经有系统电话

@property (nonatomic,assign) BOOL preJumpNoAnswerPageWhenBackground;
@end
@implementation ProviderDelegate

+ (instancetype)shareInstance {
    static ProviderDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ProviderDelegate alloc] init];
        [instance addNotification];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CallManager *manager = [CallManager shareInstance];
        self.callManager = manager;
        CXProvider *provider = [[CXProvider alloc]initWithConfiguration:[self providerConfiguration]];
        [provider setDelegate:self queue:nil];
        self.provider = provider;
    }
    return self;
}

- (CXProviderConfiguration *)providerConfiguration{
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc]initWithLocalizedName:@"HELPO"];
    providerConfiguration.supportsVideo = YES;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
    return providerConfiguration;
}

#pragma mark - 弹出系统来电界面
- (void)reportIncomingCallHandle:(NSString *)handle
                        pushInfo:(NSDictionary *)pushInfoDic
           withCompletionHandler:(nonnull void (^)(void))completion{
    if (!self.isHadReportIncomingCall) {
        self.isHadReportIncomingCall = YES;
        NSUUID *uuid = [NSUUID UUID];
        self.uuid = uuid;
        CXCallUpdate *update = [[CXCallUpdate alloc]init];
        update.remoteHandle = [[CXHandle alloc]initWithType:CXHandleTypePhoneNumber value:handle];
        update.localizedCallerName =handle;
        update.supportsHolding = NO; //通话过程中再来电，是否支持保留并接听
        update.supportsGrouping = NO; //通话是否可以加入一个群组
        update.supportsDTMF = NO; //是否支持键盘拨号
        update.hasVideo = YES;//本次通话是否有视频
        
        
        [self.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
            Call *call = [[Call alloc]initWith:uuid isOutGoing:NO handle:handle pushInfo:pushInfoDic];
            [self.callManager addCall:call];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for (Call *call in self.callManager.calls) {
                    if (call.callState == CallStateConnecting && call.uuid == uuid) {
                        call.isAutoEnd = YES;
                        [self stopCalling];//倒计时1分钟，用户还未接听，代码挂断
                    }
                }
            });
            completion();
        }];
    }
}
//替换推送内容
-(void)changeHadIncomingInfopushInfo:(NSDictionary *)pushInfoDic{
    for (Call *call in self.callManager.calls) {
        if (call.uuid  == self.uuid) {
            call.pushInfo =pushInfoDic;
        }
    }
}

//检查是否有电话
-(BOOL)checkHadIncomingCall{
    for (Call *call in self.callManager.calls) {
        if (call) {
            return YES;
        }
    }
    return  NO;
}

//检查是否有电话-正在通话中
-(BOOL)checkHadCallActive:(NSString *)action{
    for (Call *call in self.callManager.calls) {
        NSString *call_action = call.pushInfo[@"action"];
        if (call.callState == CallStateActive && [action isEqualToString:call_action]) {
            return YES;
        }
    }
    return  NO;
}

//挂断
-(void) stopCalling{
    for (Call *call in self.callManager.calls) {
        if (call) {
            [self.callManager endCall:call];
        }
    }
    self.uuid = nil;
}


//静默推送-挂断
-(void) pushStopCalling{
    for (Call *call in self.callManager.calls) {
        if (call && call.callState == CallStateConnecting) {
            call.isPushEnd = YES;
            [self.callManager endCall:call];
        }
    }
    self.uuid = nil;
}

#pragma mark - 当接收到呼叫重制时 调用的函数，这个函数必须被实现，其不需要做任何逻辑，只要用来重置状态
- (void)providerDidReset:(nonnull CXProvider *)provider {
    for (Call *call in self.callManager.calls) {
        [call end:^(BOOL completed) {

        }];
    }
    [self.callManager.calls removeAllObjects];
}

#pragma mark - 接听方成功接听一个电话时触发
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action{
    Call *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
        self.isHadReportIncomingCall = NO;
    }
    [call answer];
    [action fulfill];
}
#pragma mark - 接听方拒接电话或者双方结束通话时触发
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action{
    Call *call = [self.callManager callWithUUID:action.callUUID];
    if (!call) {
        [action fail];
    }
    
    [call end:^(BOOL completed) {
        [self jumpNoAnswerPage];
    }];
    
    self.isHadReportIncomingCall = NO;
    self.uuid = nil;
    
    [action fulfill];
    [self.callManager removeCall:call];
}
#pragma mark - 当点击系统通话界面的 静音 按钮时，会触发
- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action{
    [action fulfill];
}
#pragma mark - 当点击系统通话界面的 暂停 按钮时，会触发-暂时无用
- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action{
}
#pragma mark - 拨打方成功发起一个通话后触发-暂时无用
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action{
}

//音频会话激活状态的回调
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession{
}

//点击组按钮的回调
- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    
}
//DTMF功能回调
- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    
}

#pragma -mark Notify

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationWillEnterForegroundNotification)
//                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationDidBecomeActiveNotification {
    if (self.preJumpNoAnswerPageWhenBackground) {
           [self jumpNoAnswerPage];
    }
}
//挂断跳转无应答页面
-(void) jumpNoAnswerPage{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {
        self.preJumpNoAnswerPageWhenBackground = YES;
        return;
    }

    //打开无应答页面
}
@end




