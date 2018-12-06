//
//  NzHttpClient.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NzHttpClient : NSObject

- (instancetype)initWithBaseUrl:(NSString *)baseUrl;

- (NSURLSessionTask *)post:(id)body
                          path:(NSString *)path
             completionHandler:(void (^)(NSData * data, NSError * error))completionHandler;

- (NSURLSessionTask *)post:(id)body
                          path:(NSString *)path
                        params:(NSDictionary * _Nullable)params
             completionHandler:(void (^)(NSData * data, NSError * error))completionHandler;

@end

NS_ASSUME_NONNULL_END
