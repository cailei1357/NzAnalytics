//
//  NzAnalyticsConfiguration.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kNetworkPolicyWifiOnly,     //  只在WIFI连接时发送
    kNetworkPolicyReachable     //  在有网络连接的时候发送
} NzNetworkPolicy;

@interface NzAnalyticsConfiguration : NSObject

@property(nonatomic, copy) NSString* endpoint;
@property(nonatomic, copy) NSString* writeKey;
@property(nonatomic, assign) NSInteger flushInterval;
@property(nonatomic, assign) NSInteger flushBulkSize;
@property(nonatomic, assign) NSInteger maxQueueSize;
@property(nonatomic, assign) BOOL trackViewScreen;
@property(nonatomic, assign) BOOL trackAppLifecycleEvents;
@property(nonatomic, assign) BOOL trackAppClick;
@property(nonatomic, strong) NSArray * trackAppClickControls;
@property(nonatomic, strong) NSDictionary* launchOptions;
@property(nonatomic, assign) BOOL debugMode;
@property(nonatomic, assign) NzNetworkPolicy networkPolicy;

@end

NS_ASSUME_NONNULL_END
