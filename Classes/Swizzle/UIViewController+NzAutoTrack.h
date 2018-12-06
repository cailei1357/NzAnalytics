//
//  UIViewController+NzAutoTrack.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NzAnalyticsViewAutoTrackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NzAutoTrack)<NzAnalyticsViewAutoTrackProtocol>
@property(nonatomic, copy) NSString * nzAutoTrackContent;
@property(nonatomic, assign) BOOL nzAutoTrackIgnore;
+ (void)nz_swizzleViewDidAppear;
- (NSString *)nz_elementContent;

@end

NS_ASSUME_NONNULL_END
