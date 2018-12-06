//
//  NzAnalyticsUtils.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzAnalyticsUtils.h"

BOOL kLoggerShowLogs = YES;

void nz_dispatch_async(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_async(queue, block);
}

void NzLogShow(BOOL showLog)
{
    kLoggerShowLogs = YES;
}

void NzLog(NSString *format, ...)
{
    if (!kLoggerShowLogs) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

@implementation NzAnalyticsUtils

+ (UIViewController *)topViewController
{
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NzAnalyticsUtils topViewController:rootViewController];
    return currentVC;
}
    
+ (UIViewController *)topViewController:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self topViewController:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self topViewController:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

@end
