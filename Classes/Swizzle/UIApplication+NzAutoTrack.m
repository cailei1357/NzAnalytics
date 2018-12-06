//
//  UIApplication+NzAutoTrack.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/14.
//  Copyright © 2018 FY. All rights reserved.
//

#import "UIApplication+NzAutoTrack.h"
#import "NzAnalyticsUtils.h"
#import "NzSwizzle.h"
#import "NzAnalyticsSDK.h"
#import "UIView+NzAutoTrack.h"
#import "UIViewController+NzAutoTrack.h"

#define trackUIControlList @[@"UIButton"];
//NSArray * trackUIEventList = @[@""];

@implementation UIApplication (NzAutoTrack)

+ (void)nz_swizzleSendActionToFromForEvent
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self nz_replaceMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(nz_sendAction:to:from:forEvent:)];
    });
}

- (void)nz_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event
{
    NzLog(@"enter nz_sendAction:to:from:forEvent:");
    @try {
        [self nz_trackAction:action to:to from:from forEvent:event];
    }
    @catch(NSException * err) {
        NzLog(@"Error: trackAction");
    }
    [self nz_sendAction:action to:to from:from forEvent:event];
}

- (void)nz_trackAction:(SEL)action to:(id)to from:(id)from forEvent: (UIEvent *)event
{
    if (!from) {
        return;
    }
    
    if ([NzAnalyticsSDK shared].configuration.trackAppClick == NO) {
        NzLog(@"nz_trackAction: trackAppClick is off");
        return;
    }
    
    if (![from isKindOfClass:[UIControl class]]) {
        NzLog(@"nz_trackAction: from is not kind of class UIControl");
        return;
    }
    
    UIControl * fromControl = from;
    if(fromControl.nzAutoTrackIgnore == YES) {
        return;
    }
    
    UIViewController * cv = [NzAnalyticsUtils topViewController];
    if (cv.nzAutoTrackIgnore == YES) {
        return;
    }
    
    NSArray * trackControlList = [NzAnalyticsSDK shared].configuration.trackAppClickControls;
    if (trackControlList == nil) {
        NzLog(@"nz_trackAction: no trackAppClick control");
        return;
    }
    
    BOOL trackControl = NO;
    for (int i = 0; i < [trackControlList count]; i++) {
        NSString * controlName = [trackControlList objectAtIndex:i];
        if ([from isKindOfClass:[NSClassFromString(controlName) class]]) {
            trackControl = YES;
            break;
        }
    }
    
    if (!trackControl) {
        NzLog(@"nz_trackAction: from class not in track control list");
        return;
    }
    
    NzEvent * trackEvent = [[NzEvent alloc] init];
    // attr1  element position
    // attr2  element content
    // attr3  element type
    // attr4  是否首日访问App
    // attr5  页面名称
    // attr6  页面标题
    trackEvent.event = @"UDC__APP_ELEMENT_CLICK";
    trackEvent.attr2 = [fromControl nz_elementContent];
    if ([from isKindOfClass:[UIButton class]]){
        trackEvent.attr3 = @"UIButton";
        trackEvent.attr4 = [NzAnalyticsSDK shared].nzContext.firstLaunchToday;
    }
    trackEvent.attr5 = NSStringFromClass([cv class]);
    trackEvent.attr6 = [cv nz_elementContent];
    [[NzAnalyticsSDK shared] trackEvent:trackEvent];
}

@end
