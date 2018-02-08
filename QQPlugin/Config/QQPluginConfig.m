//
//  QQPluginConfig.m
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import "QQPluginConfig.h"

static NSString * const kPreventRevokeEnableKey = @"kPreventRevokeEnableKey";
static NSString * const kRedPackEnableKey = @"kRedPackEnableKey";

@implementation QQPluginConfig

+ (instancetype)sharedConfig {
    static QQPluginConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[QQPluginConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _preventRevokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kPreventRevokeEnableKey];
        _redPackEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kRedPackEnableKey];

    }
    return self;
}

- (void)setPreventRevokeEnable:(BOOL)preventRevokeEnable {
    _preventRevokeEnable = preventRevokeEnable;
    [[NSUserDefaults standardUserDefaults] setBool:preventRevokeEnable forKey:kPreventRevokeEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRedPackEnable:(BOOL)redPackEnable {
    _redPackEnable = redPackEnable;
    [[NSUserDefaults standardUserDefaults] setBool:redPackEnable forKey:kRedPackEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
