//
//  NzIdentity.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzIdentity.h"


@implementation NzIdentityWechatInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if(self = [super initWithDict:dict properties:[self properties]]) {
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    return  [self toDictionaryWithProperites:[self properties]];
}

- (NSArray *)properties
{
    return [NSArray arrayWithObjects:@"openId",
            @"appId",
            @"appName",
            @"unionId",
            nil];
}

@end

@implementation NzIdentity

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if(self = [super initWithDict:dict properties:[self properties]]) {
//        self.wechatInfo = [[NzIdentityWechatInfo alloc] initWithDict:[dict objectForKey:@"wechatInfo"]];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary * dict = [self toDictionaryWithProperites:[self properties]];
//    if (self.wechatInfo) {
//        [dict setObject:[self.wechatInfo toDictionary] forKey:@"wechatInfo"];
//    }
    return dict;
}

- (NSArray *)properties
{
    return [NSArray arrayWithObjects:@"lfapp_uuid",
            @"externalId",
            @"phone",
            @"email",
            @"name",
            @"country",
            @"state",
            @"city",
            @"company",
            @"department",
            @"title",
            @"industry",
            @"gender",
            @"avatarUrl",
            @"contactId",
            nil];

}

@end
