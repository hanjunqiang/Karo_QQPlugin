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



@interface TChatWalletTransferViewController : NSViewController

- (void)_updateUI;

@end


@interface MQAIOChatViewController : NSViewController

- (void)handleAppendNewMsg:(id)msg;

- (void)didClickNewMsgRemindPerformButton;

@end


@interface MQAIOTopBarViewController : NSViewController

- (void)awakeFromNib;

@end

@interface WalletContentView : NSObject

- (void)performClick;

@end

