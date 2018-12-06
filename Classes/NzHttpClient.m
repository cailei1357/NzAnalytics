//
//  NzHttpClient.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzHttpClient.h"
#import "const.h"
#import "NSData+NzGZIP.h"
#import "NzAnalyticsUtils.h"
#import "NzAnalyticsSDK.h"

@interface NzHttpClient()

@property(nonatomic, strong) NSURLSession * session;
@property(nonatomic, strong) NSString * baseUrl;

@end

@implementation NzHttpClient

- (instancetype)initWithBaseUrl:(NSString *)baseUrl
{
    if (self = [super init]) {
        self.baseUrl = baseUrl;
    }
    return self;
}

- (NSURLSession *)sessionForWriteKey:(NSString *)writeKey
{
    if (self.session == nil) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10;
        config.HTTPAdditionalHeaders =  @{
                                          @"Accept-Encoding" : @"gzip",
                                          //                                          @"Content-Encoding" : @"gzip",
                                          @"Content-Type" : @"application/json",
                                          @"User-Agent" : [NSString stringWithFormat:@"analytics-ios/%@", [[NzAnalyticsSDK shared] version]],
                                          };
        self.session = [NSURLSession sessionWithConfiguration:config];
    }
    return self.session;
}

- (NSURLSessionTask *)post:(id)body
                      path:(NSString *)path
         completionHandler:(void (^)(NSData * , NSError * ))completionHandler
{
    return [self post:body
                 path:path
               params:nil
    completionHandler:completionHandler];
}

- (NSURLSessionTask *)post:(id)body
                      path:(NSString *)path
                    params:(NSDictionary * _Nullable)params
         completionHandler:(void (^)(NSData * , NSError * ))completionHandler
{
    NSURLSession * session = [self sessionForWriteKey:nil];
    
    NSMutableString * fullPath = [NSMutableString stringWithFormat:@"%@/%@",  self.baseUrl, path];
    NSURL * url = [self buildURLWithPath:fullPath params:params];
    NSLog(@"POST with full url %@", url.absoluteString);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *sendData;
    @try {
        if ([NSJSONSerialization isValidJSONObject:body]) {
            sendData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
            if (error) {
                error = [NSError errorWithDomain:kErrorDomainIntegration
                                            code:kErrorDomainIntegrationBizCode
                                        userInfo:nil];
            }
        } else {
            error = [NSError errorWithDomain:kErrorDomainIntegration
                                        code:kErrorDomainIntegrationBizCode
                                    userInfo:nil];
        }
    }
    @catch (NSException *exp) {
        if (!error) {
            error = [NSError errorWithDomain:kErrorDomainIntegration
                                        code:kErrorDomainIntegrationBizCode
                                    userInfo:nil];
        }
    }
    if (error) {
        completionHandler(nil, error);
        return nil;
    }
    
    //    NSData *gzippedData = [sendData nz_gzippedData];
    NSData *gzippedData = sendData;
    NzLog(@"send post request %@", request.URL.absoluteString);
    NSURLSessionUploadTask * task = [session uploadTaskWithRequest:request
                                                          fromData:gzippedData
                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                     NzLog(@"receive response for request %@", request.URL.absoluteString);
                                                     if (error) {
                                                         completionHandler(nil, [NSError errorWithDomain:kErrorDomainIntegration
                                                                                                    code:kErrorDomainIntegrationSysCode
                                                                                                userInfo:error.userInfo]);
                                                         return;
                                                     }
                                                     
                                                     if (response) {
                                                         NSInteger statusCode =((NSHTTPURLResponse *)response).statusCode;
                                                         if(statusCode >= 400 && statusCode < 500) {
                                                             completionHandler(nil, [NSError errorWithDomain:kErrorDomainIntegration
                                                                                                        code:kErrorDomainIntegrationSysCode
                                                                                                    userInfo:nil]);
                                                             return;
                                                         } else if (statusCode >= 500) {
                                                             completionHandler(nil, [NSError errorWithDomain:kErrorDomainIntegration
                                                                                                        code:kErrorDomainIntegrationBizCode
                                                                                                    userInfo:nil]);
                                                             return;
                                                         }
                                                     }
                                                     
                                                     completionHandler(data, nil);
                                                 }];
    [task resume];
    return task;
}

- (NSURL *)buildURLWithPath:(NSString *)path params:(NSDictionary *)params
{
    NSURLComponents * urlComponent = [NSURLComponents componentsWithString:path];
    if(params){
        NSMutableArray<NSURLQueryItem *> * queryItems = [NSMutableArray arrayWithCapacity:1];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:(NSString *)key value:(NSString *)obj]];
        }];
        [urlComponent setQueryItems:queryItems];
    }
    return urlComponent.URL;
}


- (void)dealloc
{
    if (self.session) {
        [self.session finishTasksAndInvalidate];
    }
}

@end
