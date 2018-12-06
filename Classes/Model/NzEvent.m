//
//  NzEvent.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzEvent.h"

@implementation NzEvent

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if(self = [super initWithDict:dict properties:[self properties]]) {
        NSArray * dictItems = [dict objectForKey:@"items"];
        if (dictItems) {
            self.items = [NSMutableArray arrayWithCapacity:[dictItems count]];
            [dictItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.items addObject:[[NzEvent alloc] initWithDict: (NSDictionary *)obj]];
            }];
        }
        
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary * dict = [self toDictionaryWithProperites:[self properties]];
    if (self.items) {
        NSMutableArray * dictItems = [NSMutableArray arrayWithCapacity:[self.items count]];
        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [dictItems addObject:[(NzEvent *)obj toDictionary]];
        }];
        [dict setObject:dictItems forKey:@"items"];
    }
    return dict;
}

- (NSArray *)properties
{
    return [NSArray arrayWithObjects:
            @"externalId",
            @"lfapp_uuid",
            @"eventDate",
            @"event",
            @"attr1",
            @"attr2",
            @"attr3",
            @"attr4",
            @"attr5",
            @"attr6",
            @"attr7",
            @"attr8",
            @"attr9",
            @"attr10",
            @"attr11",
            @"attr12",
            @"attr13",
            @"attr14",
            @"attr15",
            @"attr16",
            @"attr17",
            @"attr18",
            @"attr19",
            @"attr20",
            @"sdkVersion",
            @"sdkType",
            @"platform",
            @"ipAddress",
            @"screenWidth",
            @"screenHeight",
            @"appVersion",
            @"os",
            @"osVersion",
            @"networkType",
            @"manufacturer",
            @"deviceModel",
            @"operator",
            @"imei",
            @"latitude",
            @"longitude",
            @"debugMode",
            @"source",
            @"campaign",
            @"medium",
            @"content",
            @"term",
            @"bundleKey",
            nil];
}

@end
