//
//  NSObject+QQHook.m
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import "NSObject+QQHook.h"
#import "QQPluginConfig.h"
#import "QQPlugin.h"
#import "Helper.h"
#import "fishhook.h"

@implementation NSObject (QQHook)

+ (void)hookQQ {
    //抢红包
    k_hookMethod(objc_getClass("TChatWalletTransferViewController"), @selector(_updateUI), [self class], @selector(hook_updateUI));
    k_hookMethod(objc_getClass("MQAIOChatViewController"), @selector(handleAppendNewMsg:), [self class], @selector(hook_handleAppendNewMsg:));
    k_hookMethod(objc_getClass("MQAIOChatViewController"), @selector(revokeMessages:), [self class], @selector(hook_revokeMessages:));
    k_hookMethod(objc_getClass("QQMessageRevokeEngine"), @selector(handleRecallNotify:isOnline:), [self class], @selector(hook_handleRecallNotify:isOnline:));
    //防撤回
    
    //      替换沙盒路径
    rebind_symbols((struct rebinding[1]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains }
    }, 1);
    
    [self setup];
}

+ (void)setup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addAssistantMenuItem];
    
    });
}

/**
 菜单栏添加 menuItem
 */
+ (void)addAssistantMenuItem {
    //        消息防撤回
    NSMenuItem *preventRevokeItem = [[NSMenuItem alloc] initWithTitle:@"开启消息防撤回" action:@selector(onPreventRevoke:) keyEquivalent:@"L"];
    preventRevokeItem.state = [[QQPluginConfig sharedConfig] preventRevokeEnable];
    //        自动回复
    NSMenuItem *autoReplyItem = [[NSMenuItem alloc] initWithTitle:@"自动抢红包设置" action:@selector(onRedPack:) keyEquivalent:@"K"];
    autoReplyItem.state = [[QQPluginConfig sharedConfig] redPackEnable];
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"QQ小助手"];
    [subMenu addItem:preventRevokeItem];
    [subMenu addItem:autoReplyItem];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:@"QQ小助手"];
    [menuItem setSubmenu:subMenu];
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

#pragma mark - menuItem 的点击事件
/**
 菜单栏-QQ小助手-消息防撤回 设置
 
 @param item 消息防撤回的item
 */
- (void)onPreventRevoke:(NSMenuItem *)item {
    item.state = !item.state;
    [[QQPluginConfig sharedConfig] setPreventRevokeEnable:item.state];
}

/**
 菜单栏-QQ小助手-自动抢红包 设置
 */
- (void)onRedPack:(NSMenuItem *)item {
    item.state = !item.state;
    [[QQPluginConfig sharedConfig] setRedPackEnable:item.state];
}

#pragma mark - Hook

- (void)hook_updateUI {
    [self hook_updateUI];
    //判断是否开启了自动抢红包
    if(![[QQPluginConfig sharedConfig] redPackEnable])return;
    
    id viewModel = [self valueForKey:@"_viewModel"];
    if(!viewModel)return;
    
    id redPackViewModel = [viewModel valueForKey:@"_redPackViewModel"];
    if(!redPackViewModel)return;
    
    NSDictionary *redPackDic = [redPackViewModel valueForKey:@"_redPackDic"];
    WalletContentView *walletContentView = [self valueForKey:@"_walletContentView"];
    if(!walletContentView)return;
    // 判断红包本机是否抢过
    id redPackOpenStateText = [self valueForKey:@"_redPackOpenStateLabel"];
    if(!redPackOpenStateText)return;
    //调用红包页面抢红包方法
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

- (void)hook_handleAppendNewMsg:(id)msg {
    [self hook_handleAppendNewMsg:msg];
    if([self respondsToSelector:@selector(didClickNewMsgRemindPerformButton)]) {
        [self performSelector:@selector(didClickNewMsgRemindPerformButton)];
    }
}

- (void)hook_revokeMessages:(id)msg {
    if([[QQPluginConfig sharedConfig] preventRevokeEnable]) {
        
    }else {
        [self hook_revokeMessages:msg];
    }
}

- (void)hook_handleRecallNotify:(struct RecallModel*)notify isOnline:(BOOL)isOnline {
    if([[QQPluginConfig sharedConfig] preventRevokeEnable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserNotification *userNotification = [[NSUserNotification alloc] init];
            userNotification.informativeText = @"成功拦截一条撤回消息";
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
        });
    }else {
        [self hook_handleRecallNotify:notify isOnline:isOnline];
    }
   
}

#pragma mark - 替换 NSSearchPathForDirectoriesInDomains & NSHomeDirectory
static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    if (domainMask == NSUserDomainMask) {
        NSMutableArray<NSString *> *directories = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
        [directories enumerateObjectsUsingBlock:^(NSString * _Nonnull object, NSUInteger index, BOOL * _Nonnull stop) {
            switch (directory) {
                case NSDocumentDirectory: directories[index] = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Containers/com.tencent.qq/Data/Documents"]; break;
                case NSLibraryDirectory: directories[index] = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Containers/com.tencent.qq/Data/Library"]; break;
                case NSApplicationSupportDirectory: directories[index] = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Containers/com.tencent.qq/Data/Library/Application Support"]; break;
                case NSCachesDirectory: directories[index] = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Containers/com.tencent.qq/Data/Library/Caches"]; break;
                default: break;
            }
        }];
        return directories;
    } else {
        return original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde);
    }
}

@end
