//
//  NSObject+QQHook.m
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import "NSObject+QQHook.h"
#import "QQPlugin.h"
#import "Helper.h"

@implementation NSObject (QQHook)

+ (void)hookQQ {
    k_hookMethod(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), [self class], @selector(hook_updateUI));
    
    k_hookMethod(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), [self class], @selector(hook_handleAppendNewMsg:));
    
    k_hookMethod(objc_getClass("MQAIOTopBarViewController"), @selector(awakeFromNib), [self class], @selector(hook_awakeFromNib));
}

- (void)hook_updateUI {
    [self hook_updateUI];
    __block NSViewController * topBarVc = nil;
    __block NSButton *settingButton = nil;
    
    NSArray *windows = [[NSApplication sharedApplication] windows];
    [windows enumerateObjectsUsingBlock:^(NSWindow * obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:NSClassFromString(@"MQAIOWindow2")]) {
            if([obj respondsToSelector:@selector(windowController)]) {
                id winVc = [obj performSelector:@selector(windowController)];
                topBarVc = [winVc valueForKey:@"_topBarViewController"];
            }
        }
    }];
    
    [topBarVc.view.subviews enumerateObjectsUsingBlock:^(__kindof NSView * obj, NSUInteger idx, BOOL * stop) {
        if (obj.tag == 10086) {
            settingButton = (NSButton *)obj;
        }
    }];
    
    if (settingButton) {
        if (settingButton.state == NSControlStateValueOn) {
            
            id viewModel = [self valueForKey:@"_viewModel"];
            if (viewModel) {
                id redPackViewModel = [viewModel valueForKey:@"_redPackViewModel"];
                // 判读显示的单条消息是否红包
                if (redPackViewModel) {
                    NSDictionary *redPackDic = [redPackViewModel valueForKey:@"_redPackDic"];
                    WalletContentView *walletContentView = [self valueForKey:@"_walletContentView"];
                    if (walletContentView) {
                        // 判断红包本机是否抢过
                        id redPackOpenStateText = [self valueForKey:@"_redPackOpenStateLabel"];
                        if (redPackOpenStateText) {
                            NSString *redPackOpenState = [redPackOpenStateText performSelector:@selector(stringValue)];
                            if (![redPackOpenState isEqualToString:@"已拆开"]) {
                                NSLog(@"抢到红包 - 红包信息: %@",redPackDic);
                                if([walletContentView respondsToSelector:@selector(performClick)]) {
                                    [walletContentView performSelector:@selector(performClick)];
                                }
                            
                            } else {
                                NSLog(@"检测到历史红包 - 红包信息: %@",redPackDic);
                            }
                        }
                    }
                }
            }
        } else {
            NSLog(@"检测到红包助手关闭");
        }
    }
}

- (void)hook_handleAppendNewMsg:(id)msg {
    [self hook_handleAppendNewMsg:msg];
    if([self respondsToSelector:@selector(didClickNewMsgRemindPerformButton)]) {
        [self performSelector:@selector(didClickNewMsgRemindPerformButton)];
    }
}

- (void)hook_awakeFromNib {
    [self hook_awakeFromNib];
    
    NSViewController * topBarVc = (NSViewController *)self;
    NSButton *setttingButton = [NSButton buttonWithTitle:@"红包助手" target:nil action:nil];
    setttingButton.tag = 10086;
    setttingButton.state = NSControlStateValueOn;
    [setttingButton setButtonType:NSButtonTypeSwitch];
    [topBarVc.view addSubview:setttingButton];
    [setttingButton setFrame:NSMakeRect(topBarVc.view.bounds.size.width, 10, 0, 0)];
    [setttingButton sizeToFit];
}


@end
