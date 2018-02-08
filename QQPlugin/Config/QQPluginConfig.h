//
//  QQPluginConfig.h
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQPluginConfig : NSObject
@property (nonatomic, assign) BOOL preventRevokeEnable;                /**<    是否开启防撤回    */
@property (nonatomic, assign) BOOL redPackEnable;                      /**<    是否自动抢红包    */

+ (instancetype)sharedConfig;
@end
