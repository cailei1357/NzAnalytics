//
//  NzFileStorage.h
//  NzAnalytics
//
//  Created by FY on 2018/10/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NzFileStorage : NSObject

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithFolder:(NSURL *_Nonnull)folderURL;
- (NSURL *_Nonnull)urlForKey:(NSString *_Nonnull)key;

+ (NSURL *_Nullable)applicationSupportDirectoryURL;

- (void)removeKey:(NSString *_Nonnull)key;
- (void)resetAll;

- (void)setData:(NSData *_Nonnull)data forKey:(NSString *_Nonnull)key;
- (NSData *_Nullable)dataForKey:(NSString *_Nonnull)key;

- (void)setDictionary:(NSDictionary *_Nonnull)dictionary forKey:(NSString *_Nonnull)key;
- (NSDictionary *_Nullable)dictionaryForKey:(NSString *_Nonnull)key;

- (void)setArray:(NSArray *_Nonnull)array forKey:(NSString *_Nonnull)key;
- (NSArray *_Nullable)arrayForKey:(NSString *_Nonnull)key;

- (void)setString:(NSString *_Nonnull)string forKey:(NSString *_Nonnull)key;
- (NSString *_Nullable)stringForKey:(NSString *_Nonnull)key;

@end

NS_ASSUME_NONNULL_END
