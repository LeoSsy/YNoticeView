//
//  YNoticeView.h
//  YNoticeView
//
//  Created by shusy on 2017/12/18.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNoticeView : UIView
/**
 初始化方法
 @param frame frame
 @param noticeIcon 公告图标
 @param titles 标题数组 如果需要点击标题跳转 里面可以放我提供的YNoticeModel模型 否则 可以直接放字符串即可
 @return YNoticeView
 */
- (instancetype)initWithFrame:(CGRect)frame noticeIcon:(NSString*)noticeIcon titles:(NSArray*)titles titleClicked:(void(^)(NSString* link)) titleClicked;
/**公告图标*/
@property(nonatomic,strong)NSString *noticeIcon;
/** 标题数组*/
@property(nonatomic,strong)NSArray *freshTitles;
/**开始移动 */
- (void)startMove;
@end
