//
//  NzSwizzle.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (NzSwizzle)

+ (void)nz_replaceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;

@end

NS_ASSUME_NONNULL_END
