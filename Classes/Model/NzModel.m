//
//  NzModel.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/10/30.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzModel.h"
//#import <objc/runtime.h>

@interface NzModel ()

//@property(nonatomic, strong) NSMutableArray * properties;

@end

@implementation NzModel

- (instancetype)initWithDict:(NSDictionary *)dict properties: (NSArray *)properties
{
    if (self = [self init]) {
        if (dict) {
            [properties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * propertyName = (NSString *)obj;
                [self setValue:[dict valueForKey:propertyName] forKey:propertyName];
            }];
        }
    }
    return self;
}

- (NSMutableDictionary *)toDictionaryWithProperites:(NSArray *)properties
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
    [properties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * propertyName = (NSString *)obj;
        [dict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }];
    return dict;
}

//- (NSMutableArray *)properties
//{
//    if (_properties == nil) {
//        _properties = [NSMutableArray arrayWithCapacity:20];
//        unsigned int propertyCount = 0;
//        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
//        for (unsigned int i = 0; i < propertyCount; i++ ) {
//            objc_property_t thisProperty = propertyList[i];
//            NSString * propertyName = [NSString stringWithCString:property_getName(thisProperty) encoding:NSUTF8StringEncoding];
//            [_properties addObject:propertyName];
//        }
//        free(propertyList);
//        NSLog(@"class %@ all properties %@", NSStringFromClass([self class]), [_properties componentsJoinedByString:@","]);
//    }
//    return _properties;
//}

@end
