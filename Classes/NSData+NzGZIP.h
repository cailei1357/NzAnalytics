//
//  NSData+NzGZIP.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (NzGZIP)

- (nullable NSData *)nz_gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)nz_gzippedData;
- (nullable NSData *)nz_gunzippedData;
- (BOOL)nz_isGzippedData;

@end

NS_ASSUME_NONNULL_END
