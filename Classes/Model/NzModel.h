//
//  NzModel.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NzModel : NSObject

- (instancetype)initWithDict:(NSDictionary *)dict properties: (NSArray *)properties;
- (NSMutableDictionary *)toDictionaryWithProperites: (NSArray *)properties;

//- (void)copyModel:(NzModel *)model;
//- (void)mergeModel:(NzModel *)model;

@end

NS_ASSUME_NONNULL_END
