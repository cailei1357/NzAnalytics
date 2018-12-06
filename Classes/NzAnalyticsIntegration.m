//
//  NzAnalyticsIntegration.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NzAnalyticsIntegration.h"
#import "NzFileStorage.h"
#import "NzHttpClient.h"
#import "NzAnalyticsUtils.h"
#import "NzReachability.h"
#import "NzIdentity.h"
#import "NzEvent.h"
#import "const.h"

NSString * const kFileStorageIdentity = @"com.linkflowtech.analytics.storage.identity";
NSString * const kFileStorageEvent = @"com.linkflowtech.analytics.storage.event";

NSString * const kPathEvents = @"api/track/mobile/batch_events";
NSString * const kPathIdentify = @"api/track/mobile/identify";

@interface NzAnalyticsIntegration ()

@property(nonatomic, strong) NzAnalyticsSDK * sdk;
@property(nonatomic, strong) NzFileStorage * storage;
@property(nonatomic, strong) NSURLSessionTask * requestTask;
@property(nonatomic, strong) NSTimer * flushTimer;
@property(nonatomic, strong) dispatch_queue_t serialQueue;
@property(nonatomic, strong) NSMutableArray * eventsQueue;
@property(nonatomic, strong) NzAnalyticsConfiguration * configuration;
@property(nonatomic, strong) NzIdentity * cacheIdentity;
@property(nonatomic, strong) NzHttpClient * httpClient;
@property(nonatomic, strong) NzReachability * reachability;

@end

@implementation NzAnalyticsIntegration

- (instancetype)initWithSDK:(NzAnalyticsSDK *) sdk
{
    if (self = [self init]) {
        self.sdk = sdk;
        self.configuration = sdk.configuration;
        
        NzLogShow(self.configuration.debugMode);
        self.storage = [[NzFileStorage alloc] init];
        self.serialQueue = dispatch_queue_create("com.linkflowtech.analytics.queue.integration", DISPATCH_QUEUE_SERIAL);
        
        NSArray * storedEvents = [self.storage arrayForKey:kFileStorageEvent];
        self.eventsQueue = [NSMutableArray arrayWithCapacity:self.configuration.maxQueueSize];
        if (storedEvents) {
            [self.eventsQueue addObjectsFromArray:storedEvents];
        }
        
        NSDictionary * storedIdentity = [self.storage dictionaryForKey:kFileStorageIdentity];
        self.cacheIdentity = [[NzIdentity alloc] initWithDict:storedIdentity];
        
        self.httpClient = [[NzHttpClient alloc] initWithBaseUrl:self.configuration.endpoint];
        
        
        //        self.reachability = [Reachability reachabilityWithHostName:[NSString stringWithFormat:@"%@/reachability", self.configuration.endpoint]];
        self.reachability = [NzReachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [self startFlushTimer];
    }
    return self;
}

- (void)identify:(NzIdentity *)identity
{
    NzLog(@"identify");
    if (!identity.externalId) {
        NzLog(@"ERROR: identify without externalId");
        return;
    }
    
    if (self.cacheIdentity.externalId != nil && [self.cacheIdentity.externalId isEqualToString:identity.externalId] == NO) {
        // externalId 改变了
        NzLog(@"externalId is changed from [%@] to [%@]", self.cacheIdentity.externalId, identity.externalId);
        self.cacheIdentity = identity;
        self.cacheIdentity.lfapp_uuid = [self generateUUID];
        [self cleanEventQueue];
        
    } else if (self.cacheIdentity.externalId  == nil) {
        // 第一次设置externalId
        NzLog(@"externalId is set to [%@]", identity.externalId);
        identity.lfapp_uuid = self.cacheIdentity.lfapp_uuid;
        self.cacheIdentity = identity;
        if (self.cacheIdentity.lfapp_uuid == nil) {
            self.cacheIdentity.lfapp_uuid = [self generateUUID];
        }
        
        [self.eventsQueue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary * event = (NSMutableDictionary *)obj;
            [event setValue:self.cacheIdentity.lfapp_uuid forKey:@"lfapp_uuid"];
            [event setValue:self.cacheIdentity.externalId forKey:@"externalId"];
        }];
        
        [self persistEvents];
    }
    
    [self persistIdentity];
    
    [self flushIdentity];
    [self startFlushTimer];
}

- (void)track:(NzEvent *)event
{
    NzLog(@"track:");
    event.lfapp_uuid = self.cacheIdentity.lfapp_uuid;
    event.externalId = self.cacheIdentity.externalId;
    [self fulfillEventStaticAttributes:event];
    if (!event.eventDate) {
        event.eventDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
        if (event.items) {
            [event.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NzEvent * subEvent = (NzEvent *)obj;
                subEvent.eventDate = event.eventDate;
            }];
        }
    }
    if ([self.eventsQueue count] >= self.configuration.maxQueueSize - 1) {
        NzLog(@"remove top 100 events from queue");
        [self.eventsQueue removeObjectsInRange:NSMakeRange(0, 100)];
    }
    [self.eventsQueue addObject:[event toDictionary]];
    [self persistEvents];
    [self flushEvents:NO];
}

- (NSString *)generateUUID
{
    return [[NSUUID UUID] UUIDString];
}

- (void) startFlushTimer
{
    if (self.flushTimer == nil) {
        self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:self.configuration.flushInterval
                                                           target:self
                                                         selector:@selector(flush)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void) stopFlushTimer
{
    if (self.flushTimer) {
        [self.flushTimer invalidate];
        self.flushTimer = nil;
    }
}

- (BOOL) verifyNetworkPolicy
{
    //    NotReachable = 0,
    //    ReachableViaWiFi,
    //    ReachableViaWWAN
    if (self.reachability.currentReachabilityStatus == NzReachableViaWiFi) {
        return YES;
    } else if (self.reachability.currentReachabilityStatus == NzReachableViaWWAN && self.configuration.networkPolicy == kNetworkPolicyReachable) {
        return YES;
    } else {
        return NO;
    }
}

- (void) flush
{
    [self flushIdentity];
    [self flushEvents: YES];
}

- (void) flushEvents:(BOOL)force
{
    if (force == NO && [self.eventsQueue count] < self.configuration.flushBulkSize) {
        NzLog(@"events size [%d] does not reach flushBulkSize [%d]", [self.eventsQueue count], self.configuration.flushBulkSize);
        return;
    }
    
    nz_dispatch_async(self.serialQueue, ^{
        NzLog(@"flush events serial queue");
        
        if ([self verifyNetworkPolicy] == NO) {
            // 不满足发送的网络策略
            NzLog(@"network policy is not matched");
            return;
        }
        
        if (self.requestTask != nil) {
            NzLog(@"session task is running");
            // 已经有请求在发送
            return;
        }
        
        if ([self.eventsQueue count] == 0) {
            // 没有数据需要发送
            NzLog(@"no events to sent");
            return;
        }
        
        NSArray * eventsData;
        NSMutableDictionary * sendData = [NSMutableDictionary dictionaryWithCapacity:3];
        BOOL continueToSend = NO;
        if ([self.eventsQueue count] >= self.configuration.flushBulkSize) {
            eventsData = [self.eventsQueue subarrayWithRange:NSMakeRange(0, self.configuration.flushBulkSize - 1)];
            continueToSend = YES;
        } else {
            eventsData = [NSArray arrayWithArray:self.eventsQueue];
        }
        [sendData setValue:eventsData forKey:@"eventList"];
        if (self.cacheIdentity.lfapp_uuid == nil) {
            self.cacheIdentity.lfapp_uuid = [self generateUUID];
        }
        [sendData setValue:self.cacheIdentity.lfapp_uuid forKey:@"lfapp_uuid"];
        
        if (self.cacheIdentity.externalId != nil) {
            [sendData setValue:self.cacheIdentity.externalId forKey:@"externalId"];
        }
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        self.requestTask = [self.httpClient post:sendData
                                            path:kPathEvents
                                          params:[self commonQueryParams]
                               completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
                                   if (error) {
                                       NzLog(@"flushEvents failed, error code [%d]", error.code);
                                       if (error.code == kErrorDomainIntegrationBizCode) {
                                           // 业务数据问题，抛弃数据
                                           [self.eventsQueue removeObjectsInArray:eventsData];
                                           [self persistEvents];
                                       }
                                   } else {
                                       NzLog(@"flushEvents success");
                                       [self.eventsQueue removeObjectsInArray:eventsData];
                                       [self persistEvents];
                                   }
                                   self.requestTask = nil;
                                   dispatch_semaphore_signal(sema);
                               }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

- (void) flushIdentity
{
    nz_dispatch_async(self.serialQueue, ^{
        NzLog(@"flush identity serial queue");
        if ([self verifyNetworkPolicy] == NO) {
            // 不满足发送的网络策略
            return;
        }
        
        if (self.requestTask != nil) {
            // 已经有请求在发送
            return;
        }
        
        if (self.cacheIdentity.contactId != nil) {
            // 无需发送identify
            NSLog(@"identified, contactId [%@]", self.cacheIdentity.contactId);
            return;
        }
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        self.requestTask = [self.httpClient post: [self.cacheIdentity toDictionary]
                                            path: kPathIdentify
                                          params: [self commonQueryParams]
                               completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
                                   if (error == nil){
                                       NzLog(@"flush identify success");
                                       NSDictionary * resDict = [NSJSONSerialization
                                                                 JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableLeaves
                                                                 error:nil];
                                       self.cacheIdentity.contactId = [resDict objectForKey:@"contactId"];
                                       [self persistIdentity];
                                   } else {
                                       NzLog(@"flush identify failed");
                                   }
                                   self.requestTask = nil;
                                   dispatch_semaphore_signal(sema);
                               }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

- (void)persistIdentity
{
    NzLog(@"persist identity");
    [self.storage setDictionary:[self.cacheIdentity toDictionary] forKey:kFileStorageIdentity];
}

- (void)persistEvents
{
    NzLog(@"persist events with count: %d", [self.eventsQueue count]);
    [self.storage setArray:self.eventsQueue forKey:kFileStorageEvent];
}

- (void)fulfillEventStaticAttributes: (NzEvent *)event
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    //    event.locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    event.sdkVersion = self.sdk.version;
    event.sdkType = @"iOS SDK";
    event.platform = @"iOS";
    //    event.ipAddress;
    event.screenWidth = [NSNumber numberWithDouble:[[UIScreen mainScreen] bounds].size.width];
    event.screenHeight = [NSNumber numberWithDouble:[[UIScreen mainScreen] bounds].size.height];
    event.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    event.os = @"iOS";
    event.osVersion = [currentDevice systemVersion];
    event.networkType = [self getNetworkStates];
    event.manufacturer = @"APPLE";
    event.deviceModel = [currentDevice model];
    event.debugMode = [NSNumber numberWithBool:self.configuration.debugMode];
    event.bundleKey = [[NSBundle mainBundle] bundleIdentifier];
}

- (void)cleanEventQueue
{
    NzLog(@"clean events queue");
    [self.eventsQueue removeAllObjects];
    [self persistEvents];
}

- (NSString *)getNetworkStates
{
    NzNetworkStatus status = [self.reachability currentReachabilityStatus];
    
    if (status == NzReachableViaWiFi) {
        return @"WIFI";
    } else if (status == NzReachableViaWWAN) {
        return @"WWAN";
    } else {
        return @"OFFLINE";
    }
}

- (NSMutableDictionary *)commonQueryParams
{
    return [NSMutableDictionary dictionaryWithObjects:@[self.configuration.writeKey] forKeys:@[@"token"]];
}

- (void)dealloc
{
    [self.flushTimer invalidate];
}
@end
