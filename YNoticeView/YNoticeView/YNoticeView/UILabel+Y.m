//
//  UILabel+Y.m
//  YNoticeView
//
//  Created by shusy on 2017/12/22.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "UILabel+Y.h"
#import <objc/runtime.h>

const char YLabelModeKey = '\0';

@implementation UILabel (Y)

- (void)setMode:(id)mode {
    if (mode != self.mode) {
        objc_setAssociatedObject(self, &YLabelModeKey, mode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id)mode {
    return objc_getAssociatedObject(self, &YLabelModeKey);
}

@end
