//
//  UIView+NzAutoTrack.h
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/14.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NzAnalyticsViewAutoTrackProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface UIView (NzAutoTrack)<NzAnalyticsViewAutoTrackProtocol>
@property(nonatomic, copy) NSString * nzAutoTrackContent;
@property(nonatomic, assign) BOOL nzAutoTrackIgnore;
-(NSString *)nz_elementContent;
@end

@interface UIControl (NzAutoTrack) <NzAnalyticsViewAutoTrackProtocol>
-(NSString *)nz_elementContent;
@end

@interface UIButton (NzAutoTrack)<NzAnalyticsViewAutoTrackProtocol>
-(NSString *)nz_elementContent;
@end

@interface UILabel (NzAutoTrack)<NzAnalyticsViewAutoTrackProtocol>
-(NSString *)nz_elementContent;
@end

@interface UITextView (NzAutoTrack)<NzAnalyticsViewAutoTrackProtocol>
-(NSString *)nz_elementContent;
@end
NS_ASSUME_NONNULL_END
