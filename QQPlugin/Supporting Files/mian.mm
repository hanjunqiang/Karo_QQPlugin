//
//  mian.m
//  QQPlugin
//
//  Created by AlbertHuang on 2018/2/8.
//  Copyright © 2018年 Karo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+QQHook.h"

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"++++++++ QQPlugin loaded ++++++++");
    [NSObject hookQQ];
    
}
