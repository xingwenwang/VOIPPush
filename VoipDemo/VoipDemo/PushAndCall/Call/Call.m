//
//  PushManager.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import "Call.h"

@implementation Call

- (instancetype)initWith:(NSUUID *)uuid
              isOutGoing:(BOOL)outgoing
                  handle:(NSString *)handle
                pushInfo:(NSDictionary *)pushInfo{
    self =[super init];
    self.uuid = uuid;
    self.outgoing = outgoing;
    self.handle = handle;
    self.isAutoEnd = false;
    self.pushInfo = pushInfo;
    return self;
}
- (void)startCall:(Completion)completed{
    if (completed) {
        completed(YES);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.callState = CallStateConnecting;
        self.connectedstate = ConnectedStatePending;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.callState = CallStateActive;
            self.connectedstate = ConnectedStateComplete;
            
        });
        
    });
}
#pragma mark - 开始接听
- (void)answer{
    self.callState = CallStateActive;
    /*
     *接听电话，打开音频/视频，例如项目接入zoom，此时打开zoom视频页面。
     */
    
}

#pragma mark - 挂断
- (void)end:(CallEndCompletion)completed{
    
    if(self.callState == CallStateActive){
        //接听后挂断callkit
    } else if(self.callState == CallStateConnecting) {
        if (self.isAutoEnd) {
            self.isAutoEnd = false;
            //未接听-1分钟自动后自动挂断
        }else{
            //未接听挂断用户主动挂断
        }
        if (completed) completed(true);
    }
    self.callState = CallStateEnded;
}

    
#pragma mark - 状态更改
- (void)setCallState:(CallState)callState{
    _callState = callState;
    if (callState == CallStateEnded) {
        if (_stateChange) {
            self.stateChange();
        }
    }
}

- (void)setConnectedstate:(ConnectedState)connectedstate{
    _connectedstate = connectedstate;
    if (connectedstate == ConnectedStatePending) {
        if (_connectedStateChanged) {
            self.connectedStateChanged();
        }
    }
}

@end
