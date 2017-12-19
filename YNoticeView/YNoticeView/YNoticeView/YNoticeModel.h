//
//  YNoticeLabel.h
//  YNoticeView
//
//  Created by shusy on 2017/12/18.
//  Copyright © 2017年 杭州爱卿科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface YNoticeModel : NSObject
/**公告icon */
@property(nonatomic,strong)NSString *icon;
/**显示文本 */
@property(nonatomic,strong)NSString *title;
/**点击跳转链接 */
@property(nonatomic,strong)NSString *link;
@end
