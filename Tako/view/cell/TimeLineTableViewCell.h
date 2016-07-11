//
//  TimeLineTableViewCell.h
//  Tako
//
//  Created by 熊海涛 on 16/3/29.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *lineImage;
@property (weak, nonatomic) IBOutlet UILabel *releaseTime;
@property (weak, nonatomic) IBOutlet UILabel *appSize;
@property (weak, nonatomic) IBOutlet UILabel *versionName;
@property (weak, nonatomic) IBOutlet UILabel *appDesc;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@end
