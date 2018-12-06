//
//  UIView+NzAutoTrack.m
//  NzAnalyticsDemo
//
//  Created by FY on 2018/11/14.
//  Copyright © 2018 FY. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+NzAutoTrack.h"

@implementation UIView (NzAutoTrack)

- (NSString *)nzAutoTrackContent {
    return objc_getAssociatedObject(self, @"nzAutoTrackContent");
}

- (void)setNzAutoTrackContent:(NSString *)nzAutoTrackContent {
    objc_setAssociatedObject(self, @"nzAutoTrackContent", nzAutoTrackContent, OBJC_ASSOCIATION_COPY);
}

- (BOOL)nzAutoTrackIgnore {
    NSNumber * boolNumber =objc_getAssociatedObject(self, @"nzAutoTrackIgnore");
    if (boolNumber != nil) {
        return [boolNumber boolValue];
    } else {
        return NO;
    }
}

- (void)setNzAutoTrackIgnore:(BOOL)nzAutoTrackIgnore {
    objc_setAssociatedObject(self, @"nzAutoTrackIgnore", [NSNumber numberWithBool:nzAutoTrackIgnore], OBJC_ASSOCIATION_ASSIGN);
}


-(NSString *)nz_elementContent
{
    return self.nzAutoTrackContent;
}
@end

@implementation UIControl (NzAutoTrack)
-(NSString *)nz_elementContent
{
    return self.nzAutoTrackContent;
}

@end

@implementation UIButton (NzAutoTrack)
-(NSString *)nz_elementContent
{
    NSString *content = self.nzAutoTrackContent;
    if (content) {
        return content;
    }
    content = self.currentAttributedTitle.string;
    if (content == nil || content.length == 0) {
        content = self.currentTitle;
    }
    return content;
}
@end

@implementation UILabel (NzAutoTrack)
-(NSString *)nz_elementContent
{
    NSString *content = self.nzAutoTrackContent;
    if (content) {
        return content;
    }
    content = self.attributedText.string;
    if (content == nil || content.length == 0) {
        content = self.text;
    }
    return content;
}
@end

@implementation UITextView (NzAutoTrack)
-(NSString *)nz_elementContent
{
    NSString *content = self.nzAutoTrackContent;
    if (content) {
        return content;
    }
    content =  self.attributedText.string;
    if (content == nil || content.length == 0) {
        content = self.text;
    }
    return content;
}
@end
