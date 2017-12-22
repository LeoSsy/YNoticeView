//
//  YNoticeView.m
//  YNoticeView
//
//  Created by shusy on 2017/12/18.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "YNoticeView.h"
#import "YNoticeModel.h"
#import "UILabel+Y.h"

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

//动画间隔时间
#define YTimeInterval 0.005
@interface YNoticeView()
@property(nonatomic,strong)UIImageView *iconImageV;//左侧的公告图标
@property(nonatomic,strong)UIView *contentView;   //内容视图
@property(nonatomic,strong)UIView *titleView;      //标题视图
@property(nonatomic,assign)CGFloat totalW;        //总标题宽度
@property(nonatomic,strong)UIButton *closeBtn;   //关闭按钮
@property(nonatomic,strong)NSTimer *timer;       //定时器
@property(nonatomic,assign)NSInteger count; // 常量 用于辅助每次移动的偏移量
@property(nonatomic,strong)NSArray *titles; /** 标题数组*/
@property(nonatomic,strong)void(^titleClicked)(NSString *link);//标题点击的回调
@property(nonatomic,strong)void(^closeClicked)(void);//关闭按钮点击的回调
@property(nonatomic,assign)BOOL isMoved;//当前标题是否移动完成消失在左侧了
@property(nonatomic,assign)BOOL isShowCloseBtn;//是否显示右侧的关闭按钮
@property(nonatomic,strong)YTimerProxy* timerTarget;//是否显示右侧的关闭按钮
@end

@implementation YNoticeView

- (NSTimer *)timer {
    if (!_timer) {
        YTimerProxy* timerTarget = [[YTimerProxy alloc] init];
        self.timerTarget = timerTarget;
        timerTarget.target = self;
        timerTarget.selector = @selector(showTextAnimation);
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:timerTarget selector:@selector(showTextAnimation) userInfo:nil repeats:YES];
        timerTarget.timer = timer;
        [[NSRunLoop currentRunLoop] addTimer: timer forMode:NSDefaultRunLoopMode];
        _timer =    timerTarget.timer;
    }
    return self.timerTarget.timer;
}

- (instancetype)initWithFrame:(CGRect)frame noticeIcon:(NSString*)noticeIcon titles:(NSArray*)titles titleClicked:(void(^)(NSString* link)) titleClicked {
    self = [super initWithFrame:frame];
    self.isShowCloseBtn = false;
    [self setupWithNoticeIcon:noticeIcon titles:titles titleClicked:titleClicked closeClicked:nil];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame noticeIcon:(NSString*)noticeIcon titles:(NSArray*)titles titleClicked:(void(^)(NSString* link)) titleClicked closeClicked:(void(^)(void)) closeClicked{
    self = [super initWithFrame:frame];
    self.isShowCloseBtn = true;
    [self setupWithNoticeIcon:noticeIcon titles:titles titleClicked:titleClicked closeClicked:closeClicked];
    return self;
}

- (void)setupWithNoticeIcon:(NSString*)noticeIcon titles:(NSArray*)titles titleClicked:(void(^)(NSString* link)) titleClicked closeClicked:(void(^)(void)) closeClicked{
    self.backgroundColor =  [UIColor colorWithRed:254/255.0 green:252/255.0 blue:237/255.0 alpha:1.0];
    self.titleClicked = titleClicked;
    self.closeClicked = closeClicked;
    self.titles = titles;
    self.count = 1;
    self.timeInterval = YTimeInterval;
    _iconImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:noticeIcon]];
    _iconImageV.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconImageV];
    
    _contentView = [[UIView alloc] init];
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    
    _titleView = [[UIView alloc] init];
    [_contentView addSubview:_titleView];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"close_x"] forState:UIControlStateNormal];
    [closeBtn setAdjustsImageWhenHighlighted:NO];
    [self addSubview:closeBtn];
    self.closeBtn = closeBtn;
    [self createLabel];
}

/**
 根据标题数量创建label
 */
- (void)createLabel {
    if (self.titles.count == 0) { return;}
    for (int i = 0 ; i< self.titles.count ; i++) {
        UILabel * titleL = [[UILabel alloc] init];
        titleL.text = [self titleFrom:i label:titleL];
        [self.titleView addSubview:titleL];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.titles.count == 0 || titleColor == nil) { return;}
    for (int i = 0 ; i< self.titleView.subviews.count ; i++) {
        UILabel * titleL = self.titleView.subviews[i];
        titleL.textColor = titleColor;
    }
}

- (void)setTitleFontSize:(CGFloat)titleFontSize {
    _titleFontSize = titleFontSize;
    if (self.titles.count == 0 || titleFontSize == 0) { return;}
    for (int i = 0 ; i< self.titleView.subviews.count ; i++) {
        UILabel * titleL = self.titleView.subviews[i];
        titleL.font = [UIFont systemFontOfSize:titleFontSize];
        if (i==0) {
            [self setNeedsLayout];
        }
    }
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
    [self.timerTarget.timer setFireDate:[NSDate distantFuture]];
    [self.titleView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _titles = [_freshTitles copy];
    _freshTitles = nil;
    [self createLabel];
    [self setNeedsLayout]; //此处需要重新布局界面
    //重新开启定时器
    [self.timerTarget.timer setFireDate:[NSDate date]];
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
 获取指定下标位置的标题
 @param index 下标
 @return 标题
 */
- (NSString*)titleFrom:(NSInteger)index label:(UILabel*)label {
    //获取标题
    NSString *title = @"";
    id titleM  = self.titles[index];
    if ([titleM isKindOfClass:[YNoticeModel class]]) {
        YNoticeModel *titM = (YNoticeModel*)titleM;
        title = titM.title;
        _iconImageV.image = [UIImage imageNamed:titM.icon];
        label.mode = titM;
        label.textColor = titM.titleColor != nil ?  titM.titleColor : (self.titleColor != nil ? self.titleColor : [UIColor blackColor]);
    }else{
        label.textColor = self.titleColor != nil ? self.titleColor : [UIColor blackColor];
        title = (NSString*)titleM;
    }
    label.font = self.titleFontSize >0 ? [UIFont systemFontOfSize:self.titleFontSize]:[UIFont systemFontOfSize:14];
    return title;
}

/**
 显示文本从左向右移动动画
 */
- (void)showTextAnimation{
    //计算标题的宽度
    self.isMoved = false;
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.titleView.frame.size.height;
    self.titleView.frame = CGRectMake(width-0.1*_count, 0, self.totalW, height);
    _count++;
    //判断是否显示完一条标题 同时 如果标题太短特殊处理
    if (0.1*_count > self.totalW + width ) {
        self.titleView.hidden = YES;
        self.isMoved = true;
        self.titleView.frame = CGRectMake(0, 0, self.totalW, height);
        self.titleView.hidden = NO;
        _count = 1;
        if (self.freshTitles) {
            [self resentTitles];
            return;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.timerTarget.timer setFireDate:[NSDate distantFuture]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.timerTarget.timer setFireDate:[NSDate distantFuture]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.timerTarget.timer setFireDate:[NSDate date]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.timerTarget.timer setFireDate:[NSDate date]];
}

- (CGFloat)textWidth:(NSString*)title font:(CGFloat)font {
    return [title boundingRectWithSize:CGSizeMake(MAXFLOAT, self.titleView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size.width;
}

#pragma mark 布局界面
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat margin = 5;
    CGFloat btnWh = height - margin;
    if (!self.isShowCloseBtn) {
        btnWh = 0;
        self.closeBtn.hidden = YES;
    }
    CGFloat iconH = height - 5;
    CGFloat iconW = iconH;
    CGFloat iconY = (height - iconH)*0.5;
    CGFloat titleMargin = self.titleMargin >0?self.titleMargin : 40;
    _iconImageV.frame = CGRectMake(0, iconY, iconW, iconH);
    CGFloat contentX = CGRectGetMaxX(_iconImageV.frame)+margin;
    _contentView.frame = CGRectMake(contentX, 0, width-btnWh-contentX, height);
    _titleView.frame = _contentView.bounds;
    _closeBtn.frame = CGRectMake(width-btnWh, (height-btnWh)*0.5, btnWh, btnWh);
    //设置标题尺寸
    UILabel *tempL = nil;
    CGFloat totalW = 0;
    CGFloat titleH = self.titleView.frame.size.height;
    for (int i = 0 ; i< self.titleView.subviews.count ; i++) {
        UILabel * titleL = self.titleView.subviews[i];
        titleL.userInteractionEnabled = YES;
        [titleL addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLClicked:)]];
        CGFloat width = [self textWidth:titleL.text font:titleL.font.pointSize];
        if (tempL) {
            titleL.frame = CGRectMake(CGRectGetMaxX(tempL.frame)+titleMargin, 0, width, titleH);
            totalW += width+titleMargin;
        }else{
            titleL.frame = CGRectMake(0, 0, width, titleH);
            totalW += width;
        }
        tempL = titleL;
    }
    CGRect titleFrame = _titleView.frame;
    titleFrame.size.width = totalW;
    _titleView.frame = titleFrame;
    self.totalW = totalW;
}


#pragma mark event
- (void)titleLClicked:(UITapGestureRecognizer*)tap { /** 标题点击了*/
    UILabel *label = (UILabel*)tap.view;
    if (label.mode != nil) {
        YNoticeModel *titM = (YNoticeModel*)label.mode;
        if (self.titleClicked) {
            self.titleClicked(titM.link);
        }
    }else{
        if (self.titleClicked) {
            self.titleClicked(label.text);
        }
    }
}

- (void)closeBtnClick{
    [self.timer invalidate];
    [self removeFromSuperview];
    if (self.closeClicked) {
        self.closeClicked();
    }
}

@end
