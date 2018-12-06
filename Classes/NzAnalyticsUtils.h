//
//  NzAnalyticsUtils.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

void nz_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
void NzLogShow(BOOL showLog);
void NzLog(NSString *format, ...);

@interface NzAnalyticsUtils : NSObject

+ (UIViewController *) topViewController;

@end


NS_ASSUME_NONNULL_END
