//
//  NzAnalyticsSDK.h
//  NzAnalytics
//
//  Created by FY on 2018/10/16.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NzAnalyticsConfiguration.h"
#import "NzContext.h"
#import "NzIdentity.h"
#import "NzEvent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NzAnalyticsSDK : NSObject

@property(nonatomic, strong) NzAnalyticsConfiguration * configuration;
@property(nonatomic, strong) NSString * version;
@property(nonatomic, strong) NzContext * nzContext;

+ (void)setupWithConfiguration: (NzAnalyticsConfiguration *)configuration;
+ (instancetype)shared;

- (instancetype)initWithConfiguration: (NzAnalyticsConfiguration *)configuration;
- (void)identify:(NzIdentity *)identity;
- (void)trackEvent:(NzEvent *)event;
- (void)trackScreenView: (UIView *)view;
- (void)trackScreenView: (UIView *)view withContent:(NSString * _Nullable)content;
- (void)trackScreenView: (UIView *)view topViewController:(UIViewController *)topViewController withContent:(NSString * _Nullable)content;
@end

NS_ASSUME_NONNULL_END
