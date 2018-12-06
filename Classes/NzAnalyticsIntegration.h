//
//  NzAnalyticsIntegration.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NzAnalyticsSDK.h"
#import "NzIdentity.h"
#import "NzEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NzAnalyticsIntegration : NSObject

- (instancetype)initWithSDK:(NzAnalyticsSDK *) sdk;
- (void)identify:(NzIdentity *)identity;
- (void)track:(NzEvent *)event;
- (void)flush;
- (void)startFlushTimer;
- (void)stopFlushTimer;
@end

NS_ASSUME_NONNULL_END
