//
//  NzContext.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/13.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzContext.h"

@interface NzContext ()

@property(nonatomic, strong) NSString * lastLaunchDate;
@property(nonatomic, strong) NSNumber * launchTime;
@property(nonatomic, strong) NSString * isFirstLaunch;
@property(nonatomic, strong) NSString * isFirstLaunchToday;

@end

@implementation NzContext

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if(self = [super initWithDict:dict properties:[self properties]]) {
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary * dict = [self toDictionaryWithProperites:[self properties]];
    return dict;
}

- (NSArray *)properties
{
    return [NSArray arrayWithObjects:@"lastLaunchDate",
            @"launchTime",
            @"isFirstLaunch",
            @"isFirstLaunchToday",
            nil];
    
}

- (NSString *)firstLaunch
{
    if (self.isFirstLaunch) {
        return self.isFirstLaunch;
    } else {
        return @"YES";
    }
}

- (NSString *)firstLaunchToday
{
    if (self.isFirstLaunchToday) {
        return self.isFirstLaunchToday;
    } else {
        return @"YES";
    }
}

- (void)appLaunch
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if(self.launchTime) {
        // 有launchTime，说明已经有过加载
        NSDate * lastLaunchDate= [NSDate dateWithTimeIntervalSince1970:[self.launchTime doubleValue]];
        self.lastLaunchDate = [dateFormatter stringFromDate:lastLaunchDate];
        self.isFirstLaunch = @"NO";
    } else {
        self.isFirstLaunch = @"YES";
    }

    NSDate * nowDate = [NSDate date];
    NSString * launchDate = [dateFormatter stringFromDate:nowDate];
    if ([launchDate isEqualToString:self.lastLaunchDate]) {
        self.isFirstLaunchToday = @"NO";
    } else {
        self.isFirstLaunchToday = @"YES";
    }
    self.launchTime = [NSNumber numberWithDouble:[nowDate timeIntervalSince1970]];
}

- (NSDate *)launchDateTime
{
    if (self.launchTime) {
        return [NSDate dateWithTimeIntervalSince1970:[self.launchTime doubleValue]];
    } else {
        return [NSDate date];
    }
}
@end
