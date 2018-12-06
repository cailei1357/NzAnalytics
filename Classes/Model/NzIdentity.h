//
//  NzIdentity.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NzModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NzIdentityWechatInfo : NzModel

@property(nonatomic, copy) NSString * openId;
@property(nonatomic, copy) NSString * appId;
@property(nonatomic, copy) NSString * appName;
@property(nonatomic, copy) NSString * unionId;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

@end

@interface NzIdentity : NzModel

@property(nonatomic, copy) NSString * lfapp_uuid;
//@property(nonatomic, copy) NSString * anonymousId;
@property(nonatomic, copy) NSString * externalId;
@property(nonatomic, copy) NSString * phone;
@property(nonatomic, copy) NSString * email;
@property(nonatomic, copy) NSString * name;
@property(nonatomic, copy) NSString * country;
@property(nonatomic, copy) NSString * state;
@property(nonatomic, copy) NSString * city;
@property(nonatomic, copy) NSString * company;
@property(nonatomic, copy) NSString * department;
@property(nonatomic, copy) NSString * title;
@property(nonatomic, copy) NSString * industry;
@property(nonatomic, copy) NSString * gender;
@property(nonatomic, copy) NSString * avatarUrl;
@property(nonatomic, copy) NSNumber * contactId;
//@property(nonatomic, strong) NzIdentityWechatInfo * wechatInfo;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
