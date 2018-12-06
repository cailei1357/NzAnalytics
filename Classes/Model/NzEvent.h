//
//  NzEvent.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzModel.h"

@interface NzEvent : NzModel

@property(nonatomic, copy) NSString * externalId;
@property(nonatomic, copy) NSString * lfapp_uuid;
@property(nonatomic, copy) NSNumber * eventDate;
@property(nonatomic, copy) NSString * event;

// common attributes
@property(nonatomic, copy) NSString * sdkVersion;
@property(nonatomic, copy) NSString * sdkType;
@property(nonatomic, copy) NSString * platform;
@property(nonatomic, copy) NSString * ipAddress;
@property(nonatomic, copy) NSNumber * screenWidth;
@property(nonatomic, copy) NSNumber * screenHeight;
@property(nonatomic, copy) NSString * appVersion;
@property(nonatomic, copy) NSString * os;
@property(nonatomic, copy) NSString * osVersion;
@property(nonatomic, copy) NSString * networkType;
@property(nonatomic, copy) NSString * manufacturer;
@property(nonatomic, copy) NSString * deviceModel;
@property(nonatomic, copy) NSString * operator;
@property(nonatomic, copy) NSString * imei;
@property(nonatomic, copy) NSNumber * latitude;
@property(nonatomic, copy) NSNumber * longitude;
@property(nonatomic, copy) NSNumber * debugMode;
@property(nonatomic, copy) NSString * bundleKey;

@property(nonatomic, copy) NSString * source;
@property(nonatomic, copy) NSString * campaign;
@property(nonatomic, copy) NSString * medium;
@property(nonatomic, copy) NSString * content;
@property(nonatomic, copy) NSString * term;

// dynamic attributes
@property(nonatomic, copy) NSString * attr1;
@property(nonatomic, copy) NSString * attr2;
@property(nonatomic, copy) NSString * attr3;
@property(nonatomic, copy) NSString * attr4;
@property(nonatomic, copy) NSString * attr5;
@property(nonatomic, copy) NSString * attr6;
@property(nonatomic, copy) NSString * attr7;
@property(nonatomic, copy) NSString * attr8;
@property(nonatomic, copy) NSString * attr9;
@property(nonatomic, copy) NSString * attr10;
@property(nonatomic, copy) NSString * attr11;
@property(nonatomic, copy) NSString * attr12;
@property(nonatomic, copy) NSString * attr13;
@property(nonatomic, copy) NSString * attr14;
@property(nonatomic, copy) NSString * attr15;
@property(nonatomic, copy) NSString * attr16;
@property(nonatomic, copy) NSString * attr17;
@property(nonatomic, copy) NSString * attr18;
@property(nonatomic, copy) NSString * attr19;
@property(nonatomic, copy) NSString * attr20;
@property(nonatomic, copy) NSMutableArray * items; // sub events

- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

@end
