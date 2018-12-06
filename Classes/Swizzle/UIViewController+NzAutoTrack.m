//
//  UIViewController+NzAutoTrack.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+NzAutoTrack.h"
#import "NzSwizzle.h"
#import "NzAnalyticsUtils.h"
#import "NzAnalyticsSDK.h"
#import "NzEvent.h"

@implementation UIViewController (NzAutoTrack)

- (NSString *)nzAutoTrackContent {
    return objc_getAssociatedObject(self, @"nzAutoTrackContent");
}

- (void)setNzAutoTrackContent:(NSString *)nzAutoTrackContent {
    objc_setAssociatedObject(self, @"nzAutoTrackContent", nzAutoTrackContent, OBJC_ASSOCIATION_COPY);
}

- (BOOL)nzAutoTrackIgnore {
    NSNumber * boolNumber =objc_getAssociatedObject(self, @"nzAutoTrackIgnore");
    if (boolNumber != nil) {
        return [boolNumber boolValue];
    } else {
        return NO;
    }
}

- (void)setNzAutoTrackIgnore:(BOOL)nzAutoTrackIgnore {
    objc_setAssociatedObject(self, @"nzAutoTrackIgnore", [NSNumber numberWithBool:nzAutoTrackIgnore], OBJC_ASSOCIATION_ASSIGN);
}



+ (void)nz_swizzleViewDidAppear
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self nz_replaceMethod:@selector(viewDidAppear:) withMethod:@selector(nz_viewDidAppear:)];
    });
}

- (void)nz_viewDidAppear:(BOOL)animated
{
//    if ([self isKindOfClass:[UINavigationController class]]) {
//        NzLog(@"Skip for UINavigationController, scree view will be track by sub UIViewController");
//        return;
//    }
    
    UIViewController * currentVC = [NzAnalyticsUtils topViewController];
    if (!currentVC) {
        NzLog(@"Cannot find current UIViewController");
        return;
    }
    
    if (self != currentVC) {
        NzLog(@"I am not currentVC, event show be reported by currentVC itself");
        return;
    }
    
    if (self.nzAutoTrackIgnore != YES) {
        [[NzAnalyticsSDK shared] trackScreenView:currentVC.view topViewController:currentVC withContent:nil];
    }
    
    [self nz_viewDidAppear:animated];
}

- (NSString *)nz_elementContent
{
    NSString * content;
    if ([self.view conformsToProtocol:@protocol(NzAnalyticsViewAutoTrackProtocol)]
        && [self.view respondsToSelector:@selector(nz_elementContent)]){
        content = [self.view performSelector:@selector(nz_elementContent)];
    }
    if (!content) {
        content = [self title];
    }
    if (!content && self.navigationItem) {
        content = [self.navigationItem title];
    }
    return content;
}

@end
