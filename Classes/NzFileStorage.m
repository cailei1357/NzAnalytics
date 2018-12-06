//
//  NzFileStorage.m
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import "NzFileStorage.h"


@interface NzFileStorage ()

@property (nonatomic, strong, nonnull) NSURL *folderURL;

@end

@implementation NzFileStorage

- (instancetype)init
{
    return [self initWithFolder:[NzFileStorage applicationSupportDirectoryURL]];
}

- (instancetype)initWithFolder:(NSURL *)folderURL
{
    if (self = [super init]) {
        _folderURL = folderURL;
        [self createDirectoryAtURLIfNeeded:folderURL];
        return self;
    }
    return nil;
}

- (void)removeKey:(NSString *)key
{
    NSURL *url = [self urlForKey:key];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
}

- (void)resetAll
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.folderURL error:&error];
    [self createDirectoryAtURLIfNeeded:self.folderURL];
}

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    NSURL *url = [self urlForKey:key];
    [data writeToURL:url atomically:YES];
    
    NSError *error = nil;
    [url setResourceValue:@YES
                   forKey:NSURLIsExcludedFromBackupKey
                    error:&error];
}

- (NSData *)dataForKey:(NSString *)key
{
    NSURL *url = [self urlForKey:key];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return nil;
    }
    return data;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [self plistForKey:key];
}

- (void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    [self setPlist:dictionary forKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [self plistForKey:key];
}

- (void)setArray:(NSArray *)array forKey:(NSString *)key
{
    [self setPlist:array forKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self plistForKey:key];
}

- (void)setString:(NSString *)string forKey:(NSString *)key
{
    [self setPlist:string forKey:key];
}

+ (NSURL *)applicationSupportDirectoryURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *supportPath = [paths firstObject];
    return [NSURL fileURLWithPath:supportPath];
}

- (NSURL *)urlForKey:(NSString *)key
{
    return [self.folderURL URLByAppendingPathComponent:key];
}

#pragma mark - Helpers

- (id _Nullable)plistForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    return data ? [self plistFromData:data] : nil;
}

- (void)setPlist:(id _Nonnull)plist forKey:(NSString *)key
{
    NSData *data = [self dataFromPlist:plist];
    if (data) {
        [self setData:data forKey:key];
    }
}

- (NSData *_Nullable)dataFromPlist:(nonnull id)plist
{
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                              format:NSPropertyListXMLFormat_v1_0
                                                             options:0
                                                               error:&error];
    return data;
}

- (id _Nullable)plistFromData:(NSData *_Nonnull)data
{
    NSError *error = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data
                                                         options:0
                                                          format:nil
                                                           error:&error];
    return plist;
}

- (void)createDirectoryAtURLIfNeeded:(NSURL *)url
{
    NSLog(@"check if create directory at url [%@]", url.path);
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path
                                              isDirectory:NULL]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:url.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
}

@end
