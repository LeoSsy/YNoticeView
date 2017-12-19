//
//  YNoticeView.m
//  YNoticeView
//
//  Created by shusy on 2017/12/18.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "YNoticeView.h"
#import "YNoticeModel.h"

@interface YTimerProxy : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer* timer;
@end

@implementation YTimerProxy

- (id)forwardingTargetForSelector:(SEL)aSelector;{
    return self.target;
}

- (IMP)methodForSelector:(SEL)aSelector {
    return [NSObject instanceMethodForSelector:self.selector];
}

- (void) fire:(NSTimer *)timer {
    if(self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:timer.userInfo afterDelay:0.0f];
#pragma clang diagnostic pop
    } else {
        [self.timer invalidate];
    }
}
@end

#define YTimeInterval 0.005

@interface YNoticeView()
@property(nonatomic,strong)UIImageView *iconImageV;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UILabel *titleL;
@property(nonatomic,strong)UIButton *closeBtn;
@property(nonatomic,strong)NSTimer *timer;       //定时器
@property(nonatomic,assign)CGFloat timeInterval; //多久执行一次
@property(nonatomic,assign)NSInteger count; // 常量 用于辅助每次移动的偏移量
@property(nonatomic,assign)NSInteger currentNum; //记录当前显示的文字下标
@property(nonatomic,strong)NSArray *titles; /** 标题数组*/
@property(nonatomic,strong)void(^titleClicked)(NSString *link);//标题点击的回调
@property(nonatomic,strong)NSString *link;//当前显示标题的链接
@property(nonatomic,assign)BOOL isMoved;//当前标题是否移动完成消失在左侧了
@end

@implementation YNoticeView

- (NSTimer *)timer {
    YTimerProxy* timerTarget = [[YTimerProxy alloc] init];
    if (!_timer) {
        timerTarget.target = self;
        timerTarget.selector = @selector(showTextAnimation);
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:timerTarget selector:@selector(showTextAnimation) userInfo:nil repeats:YES];
        timerTarget.timer = timer;
        [[NSRunLoop currentRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
        return timerTarget.timer;
    }
    return timerTarget.timer;
}

- (instancetype)initWithFrame:(CGRect)frame noticeIcon:(NSString*)noticeIcon titles:(NSArray*)titles titleClicked:(void(^)(NSString* link)) titleClicked {
    self = [super initWithFrame:frame];
    self.backgroundColor =  [UIColor colorWithRed:254/255.0 green:252/255.0 blue:237/255.0 alpha:1.0];
    self.titleClicked = titleClicked;
    self.titles = titles;
    self.count = 1;
    self.currentNum = 0;
    self.timeInterval = YTimeInterval;
    _iconImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:noticeIcon]];
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconImageV];
    
    _contentView = [[UIView alloc] init];
    _contentView.clipsToBounds = YES;
    [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick)]];
    [self addSubview:_contentView];
    
    _titleL = [[UILabel alloc] init];
    _titleL.text = @"测试公告";
    _titleL.font = [UIFont systemFontOfSize:14];
    _titleL.textColor = [UIColor blackColor];
    [_contentView addSubview:_titleL];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"close_x"] forState:UIControlStateNormal];
    [closeBtn setAdjustsImageWhenHighlighted:NO];
    [self addSubview:closeBtn];
    self.closeBtn = closeBtn;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat margin = 5;
    CGFloat btnWh = height - margin;
    CGFloat iconW = self.iconImageV.image.size.width;
    CGFloat iconH = self.iconImageV.image.size.height;
    CGFloat iconY = (height - iconH)*0.5;
    _iconImageV.frame = CGRectMake(0, iconY, iconW, iconH);
    CGFloat contentX = CGRectGetMaxX(_iconImageV.frame)+margin;
    _contentView.frame = CGRectMake(contentX, 0, width-btnWh-contentX, height);
    _titleL.frame =CGRectMake(width, 0, width, height);
    _closeBtn.frame = CGRectMake(width-btnWh, (height-btnWh)*0.5, btnWh, btnWh);
}

- (void)setNoticeIcon:(NSString *)noticeIcon {
    _noticeIcon = noticeIcon;
    _iconImageV.image = [UIImage imageNamed:noticeIcon];
}

- (void)setFreshTitles:(NSArray *)freshTitles {
    if (freshTitles == nil || freshTitles.count ==0) {return;}
    _freshTitles = freshTitles;
    if (!self.isMoved) { //如果当前标题正在移动中则不需要这个时候设置新标题 放到下一次设置
        return;
    }else{
        [self resentTitles];
    }
}

/**
 重置标题
 */
- (void)resentTitles{
    //先停止定时器
    [self.timer invalidate];
    self.timer = nil;
    //重置状态
    self.count = 1;
    self.currentNum = 0;
    _titles = [_freshTitles copy];
    _freshTitles = nil;
    //重新开启定时器
    [self.timer fire];
}

/**
 开始运行
 */
- (void)startMove{
    if (self.titles == nil || self.titles.count == 0) { return;}
    //开始运行
    [self.timer fire];
}

/**
 显示文本从左向右移动动画
 */
- (void)showTextAnimation{
    //计算标题的宽度
    self.isMoved = false;
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.frame.size.height;
    //获取标题
    NSString *title = @"";
    id titleM  = self.titles[self.currentNum];
    if ([titleM isKindOfClass:[YNoticeModel class]]) {
        YNoticeModel *titM = (YNoticeModel*)titleM;
        title = titM.title;
        _iconImageV.image = [UIImage imageNamed:titM.icon];
        self.link = titM.link;
    }else{
        title = (NSString*)titleM;
    }
    self.titleL.text = title;
    //计算标题宽度
    CGFloat titleOldW = [self textWidth:self.contentView.frame.size.height];
    CGFloat titleW = titleOldW;
    if (titleW <  width) {
        titleW = width;
    }
    self.titleL.frame = CGRectMake(width-0.1*_count, 0, titleW, height);
    _count++;
    //判断是否显示完一条标题 同时 如果标题太短特殊处理
    if (0.1*_count > (titleOldW < width ? titleW+width*0.5:titleW+width) ) {
        self.isMoved = true;
        if (self.freshTitles) {
            [self resentTitles];
            return;
        }
        self.titleL.frame = CGRectMake(width, 0, width, height);
        _count = 1;
        self.currentNum++;
        if (self.currentNum > self.titles.count -1) {
            self.currentNum = 0;
        }
    }
}

- (CGFloat)textWidth:(CGFloat)contentW {
    return [self.titleL.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.titleL.font.pointSize]} context:nil].size.width;
}

#pragma mark event
/** 标题点击了*/
- (void)titleClick {
    if (self.link==nil) { return;}
    if (self.titleClicked) {
        self.titleClicked(self.link);
    }
}

- (void)closeBtnClick{
    [self.timer invalidate];
    [self removeFromSuperview];
}

@end
