//
//  NzContext.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/13.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NzContext : NzModel


- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

- (NSString *)firstLaunch;
- (NSString *)firstLaunchToday;
- (NSDate *)launchDateTime;
- (void)appLaunch;
@end

NS_ASSUME_NONNULL_END
