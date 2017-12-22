# YNoticeView

 自定义的公告视图。

示例程序：

###### 默认 YNoticeView 类显示效果如下

![MacDown Screenshot](./noticeview.gif)


使用方式：

#### 1.直接调用显示方法

```objc
    _noticeView = [[YNoticeView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 40) noticeIcon:@"notice" titles:@[@" 123",@"2222sddsjf从 v 的送饭的是方式对方的送方"] titleClicked:^(NSString *link) {
    NSLog(@"linklinklink%@",link);
    }];
    [self.view addSubview:_noticeView];
    _noticeView.titleColor = [UIColor redColor];
    _noticeView.titleMargin = 10;
    _noticeView.titleFontSize = 18;
    //    _noticeView.timeInterval = 0.001;
    [_noticeView startMove];
```
#### 2.更改标题
``` objc
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

```

如果你在使用中遇到了什么问题，或者希望扩展其他功能，可以直接跟我联系。

更多功能敬请期待！ 
