//
//  TableViewCell.h
//  HelloTako
//
//  Created by 熊海涛 on 15/12/9.
//  Copyright © 2015年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "SWTableViewCell.h"

// 暂时不使用cell的滑动扩展安装
//@interface TableViewCell :SWTableViewCell
// to-fix: 若不继承SWTableViewCell，或出现过滤列表时，字幕重复的bug.
@interface TableViewCell :  SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UILabel *appVersion;
@property (weak, nonatomic) IBOutlet UILabel *otherInfo;
@property (weak, nonatomic) IBOutlet UIImageView *appImage;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressControl;
@property (weak, nonatomic) IBOutlet UILabel *textDownload;
@property (weak, nonatomic) IBOutlet UILabel *downloadSpeed;
@property (weak, nonatomic) IBOutlet UIButton *coverButton;

@end
