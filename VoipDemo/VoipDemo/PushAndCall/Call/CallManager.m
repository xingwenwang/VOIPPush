//
//  PushManager.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import <CallKit/CallKit.h>

#import "CallManager.h"


@interface CallManager ()



@property(nonatomic ,strong)CXCallController *callController;
@end

@implementation CallManager

+ (instancetype)shareInstance {
    static CallManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CallManager alloc] init];
    });
    return instance;
}

- (NSMutableSet<Call *> *)calls{
    if (!_calls) {
        _calls =[[NSMutableSet alloc]init];
    }
    return  _calls;
}

- (CXCallController *)callController{
    if (!_callController) {
        _callController = [[CXCallController alloc]init];
    }
    return _callController;
}

- (void)startCallWithHandle:(NSString *)handle isVideo:(BOOL)isVideo{
    CXHandle *cxHandle = [[CXHandle alloc]initWithType:CXHandleTypePhoneNumber value:handle];
    CXStartCallAction *startAction = [[CXStartCallAction alloc]initWithCallUUID:[NSUUID UUID] handle:cxHandle];
    startAction.video = isVideo;
    CXTransaction *transaction = [[CXTransaction alloc]initWithAction:startAction];
    [self requestTransaction:transaction];
}

- (void)endCall:(Call *)call{
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc]initWithCallUUID:call.uuid];
    CXTransaction *transaction = [[CXTransaction alloc]initWithAction:endCallAction];
    [self requestTransaction:transaction];
}

- (void)setHeldWithCall:(Call *)call onHold:(BOOL)onHold {
    CXSetHeldCallAction *setHeldCallAction =  [[CXSetHeldCallAction alloc]initWithCallUUID:call.uuid onHold:onHold];
    
    CXTransaction *transaction = [[CXTransaction alloc]init];
    [transaction addAction:setHeldCallAction];
  
    [self requestTransaction:transaction];
}

- (void)requestTransaction:(CXTransaction *)transaction{
    
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"CXCallController  == request  == Success");
        }else{
            NSLog(@"CXCallController  == request  == Error");
        }
    }];
}



- (Call *)callWithUUID:(NSUUID *)uuid{
    for (Call *call in self.calls) {
        if ([call.uuid isEqual:uuid]) {
            return call;
        }
    }
    return nil;
}

- (void)addCall:(Call *)call{
    [self.calls addObject:call];
    call.stateChange = ^{
        if (self.callsChangedHandler) {
            self.callsChangedHandler();
        }
    };
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)removeCall:(Call *)call{
    if (call) {
        [self.calls removeObject:call];
    }
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}

- (void)removeAllCalls{
    [self.calls removeAllObjects];
    if (self.callsChangedHandler) {
        self.callsChangedHandler();
    }
}
@end
