//
//  QQPlugin.h
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for QQPlugin.
FOUNDATION_EXPORT double QQPluginVersionNumber;

//! Project version string for QQPlugin.
FOUNDATION_EXPORT const unsigned char QQPluginVersionString[];

typedef void (*CDUnknownFunctionPointerType)(void);

struct RecallModel {
    CDUnknownFunctionPointerType *_field1;
    int _field2;
    _Bool _field3;
    _Bool _field5;
    unsigned long long _field6;
    union {
        unsigned long long _field1;
        unsigned long long _field2;
    } _field7;
};

@interface TChatWalletTransferViewController : NSViewController

- (void)_updateUI;

@end


@interface MQAIOChatViewController : NSViewController

- (void)handleAppendNewMsg:(id)msg;

- (void)didClickNewMsgRemindPerformButton;

- (void)revokeMessages:(id)msg;

@end


@interface WalletContentView : NSObject

- (void)performClick;

@end

@interface QQMessageRevokeEngine: NSObject

- (void)handleRecallNotify:(struct RecallModel*)notify isOnline:(BOOL)isOnline;

@end

@interface BHMsgListManager: NSObject

- (void)getMessageKey:(id)msg;

@end

@interface RedPackHelper: NSObject

- (void)openRedPackWithMsgModel:(id)arg0 operation:(id)arg1;

@end 

