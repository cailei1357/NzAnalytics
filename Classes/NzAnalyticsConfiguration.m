//
//  NzAnalyticsConfiguration.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzAnalyticsConfiguration.h"

@implementation NzAnalyticsConfiguration

- (instancetype) init
{
    if (self = [super init]) {
        self.flushBulkSize = 100;
        self.flushInterval = 60;
        self.maxQueueSize = 1000;
        self.trackViewScreen = NO;
        self.trackAppLifecycleEvents = NO;
        self.trackAppClick = NO;
        self.trackAppClickControls = [NSArray arrayWithObjects:@"UIButton", nil];
        self.networkPolicy = kNetworkPolicyReachable;
        self.debugMode = NO;
    }
    return self;
}

- (void) setFlushInterval:(NSInteger)flushInterval
{
    if (flushInterval < 30) {
        _flushInterval = 30;
    } else if (flushInterval > 300) {
        _flushInterval = 300;
    } else {
        _flushInterval = flushInterval;
    }
}

- (void) setFlushBulkSize:(NSInteger)flushSize
{
    if (_flushBulkSize <= 50) {
        _flushBulkSize = 50;
    } else if (_flushBulkSize > 200) {
        _flushBulkSize = 200;
    } else {
        _flushBulkSize = flushSize;
    }
}

- (void) setMaxQueueSize:(NSInteger)maxQueueSize
{
    if (maxQueueSize < 1000) {
        _maxQueueSize = 1000;
    } else if (maxQueueSize > 5000) {
        _maxQueueSize = 5000;
    } else {
        _maxQueueSize = maxQueueSize;
    }
}

@end
