//
//  TimeLineTableViewCell.m
//  Tako
//
//  Created by 熊海涛 on 16/3/29.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "TimeLineTableViewCell.h"
#import "Constant.h"
#import "UIHelper.h"



@implementation TimeLineTableViewCell


- (void)awakeFromNib {
    // Initialization code

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [XHTUIHelper addBorderonButton:self.downloadButton cornerSize:4];
    [XHTUIHelper addBorderonButton:self.moreButton cornerSize:4];
    self.moreButton.layer.borderWidth = 0;

    // 自动换行
    self.releaseTime.lineBreakMode = NSLineBreakByWordWrapping;
    self.releaseTime.numberOfLines = 0;
    
    [self.downloadButton addTarget:self action:@selector(clickDownloadButton:) forControlEvents:UIControlEventTouchDown];
    [self.moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchDown];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (void)freeButton:(UIButton*)bt
{
    bt.enabled=YES;
}



-(void)clickDownloadButton:(UIButton*)button{
    
    UIButton* bt = (UIButton*)button;
    if (!bt.enabled) {
        return;
    }
    bt.enabled=NO;
    
    // 防止重复点击
    [self performSelector:@selector(freeButton:)withObject:button afterDelay:1.0f];
    
    NSLog(@"clicked...tag is:%ld",(long)button.tag);
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:self forKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 发送事件
    NSNotification *notification =[NSNotification notificationWithName:CLICK_DETAIL_DOWNLOAD_BUTTON_NOTIFICATION object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)clickMoreButton:(UIButton*)button{
    NSLog(@"clicked...tag is:%ld",(long)button.tag);
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:self forKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 发送事件
    NSNotification *notification =[NSNotification notificationWithName:CLICK_MORE_BUTTON_NOTIFICATION object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
