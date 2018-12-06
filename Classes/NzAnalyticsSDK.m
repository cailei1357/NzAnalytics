//
//  NzAnalyticsSDK.m
//  NzAnalytics
//
//  Created by FY on 2018/10/16.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzAnalyticsSDK.h"
#import <UIKit/UIKit.h>
#import "NzAnalyticsIntegration.h"
#import "UIViewController+NzAutoTrack.h"
#import "UIApplication+NzAutoTrack.h"
#import "NzAnalyticsUtils.h"
#import "NzAnalyticsViewAutoTrackProtocol.h"
#import "NzFileStorage.h"

NSString * const kFileStorageContext = @"com.linkflowtech.analytics.storage.context";

static NzAnalyticsSDK * sharedInstance = nil;

@interface NzAnalyticsSDK()

@property(nonatomic, strong) NzAnalyticsIntegration * integration;
@property(nonatomic, strong) NzFileStorage * storage;
@property(nonatomic, assign) UIBackgroundTaskIdentifier backgroundFlushTask;

@end


@implementation NzAnalyticsSDK

+ (void)setupWithConfiguration: (NzAnalyticsConfiguration *)configuration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NzLog(@"setup nz analytics SDK configuration: token [%@] endponit [%@]", configuration.writeKey, configuration.endpoint);
        sharedInstance = [[NzAnalyticsSDK alloc] initWithConfiguration:configuration];
    });
}

+ (instancetype)shared
{
    return sharedInstance;
}

- (instancetype)initWithConfiguration: (NzAnalyticsConfiguration *)configuration
{
    if (self = [self init]) {
        self.configuration = configuration;
        self.version = @"1.0.0";
        self.storage = [[NzFileStorage alloc] init];
        [self loadContext];
        self.integration = [[NzAnalyticsIntegration alloc] initWithSDK:self];
        
        NzLog(@"observe app state change");
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                                  UIApplicationDidFinishLaunchingNotification,
                                  UIApplicationWillEnterForegroundNotification,
                                  UIApplicationWillTerminateNotification,
                                  UIApplicationWillResignActiveNotification,
                                  UIApplicationDidBecomeActiveNotification ]) {
            [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:nil];
        }
        
        if(self.configuration.trackViewScreen) {
            [UIViewController nz_swizzleViewDidAppear];
        }
        
        if(self.configuration.trackAppClick) {
            [UIApplication nz_swizzleSendActionToFromForEvent];
        }
    }
    return self;
}
    
- (void)handleAppStateNotification: (NSNotification *)notificaiton
{
    // TODO
    NSLog(@"handleAppStateNotification name %@", notificaiton.name);
    if ([notificaiton.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self.nzContext appLaunch];
        [self enterAppEvent:NO];
        [self.integration startFlushTimer];
    } else if ([notificaiton.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self.nzContext appLaunch];
        [self enterAppEvent:YES];
        [self.integration startFlushTimer];
    } else if ([notificaiton.name isEqualToString:UIApplicationWillTerminateNotification] ||
               [notificaiton.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self exitAppEvent];
        [self.integration stopFlushTimer];
        if ([notificaiton.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
            [self beginEventFlushTask];
        }
    }
    [self persistContext];
}

- (void)enterAppEvent:(BOOL)fromBackground
{
    if ([self.nzContext.firstLaunch isEqualToString:@"YES"]) {
        // 激活事件
        NzEvent * event = [[NzEvent alloc] init];
        event.event = @"UDC__APP_ACTIVATE";
        [self trackEvent:event];
    }
    
    if (self.configuration.trackAppLifecycleEvents == YES) {
        NzEvent * event = [[NzEvent alloc] init];
        event.event = @"UDC__APP_SHOW";
        event.attr1 = fromBackground == YES? @"YES": @"NO";
        event.attr2 = self.nzContext.firstLaunchToday;
        event.attr3 = self.nzContext.firstLaunch;
        [self trackEvent:event];
    }
}

- (void)exitAppEvent
{
    if (self.configuration.trackAppLifecycleEvents == YES) {
        NzEvent * event = [[NzEvent alloc] init];
        event.event = @"UDC__APP_HIDE";
        event.attr1 = self.nzContext.firstLaunchToday;
        NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:self.nzContext.launchDateTime];
        event.attr4 = [NSString stringWithFormat:@"%d", (int)timeDiff];
        [self trackEvent:event];
    }
}

- (void)identify:(NzIdentity *)identity
{
    [self.integration identify:identity];
}

- (void)trackEvent:(NzEvent *)event
{
    [self.integration track:event];
}


/**
 *  用于单UIViewController中UIView的变化，无法autotrack
 **/

- (void)trackScreenView: (UIView *)view
{
    UIViewController * currentVC = [NzAnalyticsUtils topViewController];
    [self trackScreenView:view topViewController:currentVC withContent:nil];
}

- (void)trackScreenView: (UIView *)view withContent: (NSString *)content
{
    UIViewController * currentVC = [NzAnalyticsUtils topViewController];
    [self trackScreenView:view topViewController:currentVC withContent:content];
}

- (void)trackScreenView: (UIView *)view topViewController:(UIViewController *)topViewController withContent:(NSString *)content
{
    NzEvent *event = [[NzEvent alloc] init];
    event.event = @"UDC__APP_PAGE_SHOW";
    event.attr1 = [self.nzContext firstLaunchToday];
    event.attr2 = NSStringFromClass([topViewController class]);
    event.attr3 = nil;
    event.attr4 = content ? content : [topViewController nz_elementContent];
    [self trackEvent:event];
}

- (void)persistContext
{
    NSDictionary * contextDict = [self.nzContext toDictionary];
    [self.storage setDictionary:contextDict forKey:kFileStorageContext];
}

- (void)loadContext
{
    NSDictionary * contextDict = [self.storage dictionaryForKey:kFileStorageContext];
    if (contextDict) {
        self.nzContext  = [[NzContext alloc] initWithDict:contextDict];
    } else {
        self.nzContext = [[NzContext alloc] init];
    }
}

-(void)beginEventFlushTask
{
    self.backgroundFlushTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NzLog(@"end enter background flush task");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundFlushTask];
        self.backgroundFlushTask = UIBackgroundTaskInvalid;
    }];
    
    NzLog(@"begin enter background flush task");
    [self.integration flush];
}
@end
