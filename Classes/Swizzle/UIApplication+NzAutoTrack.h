//
//  UIApplication+NzAutoTrack.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/14.
//  Copyright © 2018 FY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (NzAutoTrack)

+ (void)nz_swizzleSendActionToFromForEvent;

@end

NS_ASSUME_NONNULL_END
