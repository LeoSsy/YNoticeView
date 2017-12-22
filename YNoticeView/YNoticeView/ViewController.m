//
//  ViewController.m
//  YNoticeView
//
//  Created by shusy on 2017/12/18.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import "ViewController.h"
#import "YNoticeView.h"
#import "YNoticeModel.h"
@interface ViewController ()
@property(nonatomic,strong)YNoticeView *noticeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //"sddsjf从 v 的送饭的是方式对方的送方式发送发第三sddsjf从 v 的送饭的是方式对方的送方式发送发第三sddsjf从 v 的送饭的是方式对方的送方式发送发第三sddsjf从 v 的送饭的是方式对方的送方式发送发第三sddsjf从 v 的送饭的是方式对方的送方式发送发第三 888
   _noticeView = [[YNoticeView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 40) noticeIcon:@"notice" titles:@[@" 888",@"2222sddsjf从 v 的送饭的是方式对方的送方"] titleClicked:^(NSString *link) {
                NSLog(@"linklinklink%@",link);
     }];
    [self.view addSubview:_noticeView];
    _noticeView.titleColor = [UIColor redColor];
    _noticeView.titleMargin = 10;
    _noticeView.titleFontSize = 18;
//    _noticeView.timeInterval = 0.001;
    [_noticeView startMove];

}

- (IBAction)refreshTitle {
    
    NSMutableArray *icons = [NSMutableArray array];
    for (int i = 1 ; i< 19 ; i++) {
        [icons addObject:[NSString stringWithFormat:@"%d",i]];
    }
    NSMutableArray *models = [NSMutableArray array];
    for (int i = 0 ; i< 5; i++) {
        YNoticeModel *model = [[YNoticeModel alloc] init];
        model.title = @"sddsjf从 v 的送 888";
        model.link = @"http://www.baidu.com";
        model.icon = icons[arc4random_uniform(17)];
        [models addObject:model];
    }
    _noticeView.freshTitles = models;
}

@end
