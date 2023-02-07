//
//  PushManager.h
//  VoipDemo
//
//  Created by kevin on 2023/2/7.
//

#import <Foundation/Foundation.h>
#import "Call.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^CallsChangedHandler)(void);
@interface CallManager : NSObject

@property(nonatomic ,copy) CallsChangedHandler callsChangedHandler;
@property(nonatomic ,strong)NSMutableSet<Call *> *calls;

+ (instancetype)shareInstance;

-(void)startCallWithHandle:(NSString *)handle isVideo:(BOOL)isVideo;

- (void)endCall:(Call *)call;

- (void)setHeldWithCall:(Call *)call onHold:(BOOL)onHold ;

- (void)requestTransaction:(CXTransaction *)transaction;



- (Call *)callWithUUID:(NSUUID *)uuid;

- (void)addCall:(Call *)call;

- (void)removeCall:(Call *)call;

- (void)removeAllCalls;

@end

NS_ASSUME_NONNULL_END
