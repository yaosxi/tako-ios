//
//  TableViewCell.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/9.
//  Copyright © 2015年 熊海涛. All rights reserved.
//

#import "TableViewCell.h"
#import "UIHelper.h"
#import "Constant.h"

@interface TableViewCell()

@end



NSMutableDictionary* workerDict = nil;

@implementation TableViewCell


-(UIBarButtonItem*)layoutButtomItem:(NSString*)title sel:(SEL)touchAction{
    UIColor* systemBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 60,30)];
    [XHTUIHelper addBorderonButton:bt cornerSize:6];
    bt.titleLabel.font = [UIFont systemFontOfSize: 13.0];

    [bt setTitleColor:systemBlue forState:UIControlStateNormal];
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setEnabled:YES];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:bt];
    [bt addTarget:self action:touchAction forControlEvents:UIControlEventTouchDown];
    
    return item;
}


-(void)showDetail{
    NSLog(@"will show detail");
}

-(void)feedback{
    NSLog(@"will show feedback");
}


-(void)deleteApp{
    NSLog(@"will delete app");
}

- (void)awakeFromNib {

    // button圆角化
    [XHTUIHelper addBorderonButton:self.button cornerSize:5];
    self.appImage.layer.cornerRadius = 12;
    // tableView设置为不可点击
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
//    NSMutableArray *myToolBarItems = [NSMutableArray array];
//   
//    // 间距
//    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    [myToolBarItems addObject:[self layoutButtomItem:@"详情 " sel:@selector(showDetail)] ];
//    [myToolBarItems addObject:emptyItem];
//    [myToolBarItems addObject:[self layoutButtomItem:@"反馈" sel:@selector(feedback)]];
//    [myToolBarItems addObject:emptyItem];
//    [myToolBarItems addObject:[self layoutButtomItem:@"删除" sel:@selector(deleteApp)]];
//    

    // 隐藏下载栏
    [self.btnCancel setHidden:YES];
    [self.progressControl setTintColor:[XHTUIHelper systemColor]];
    [self.progressControl setHidden:YES];
    [self.textDownload setHidden:YES];
    
    self.downloadSpeed.text = @"";
    [self.coverButton addTarget:self action:@selector(clickDownload:) forControlEvents:UIControlEventTouchDown];
//    [self.button addTarget:self action:@selector(clickDownload:) forControlEvents:UIControlEventTouchDown];
    [self.btnCancel addTarget:self action:@selector(stopDownload:) forControlEvents:UIControlEventTouchDown];
    
    self.separatorInset = UIEdgeInsetsZero;
    if (IOS_VERSION>=8.0) {
        self.layoutMargins = UIEdgeInsetsZero;
    }

}




- (void)freeButton:(UIButton*)bt
{
    bt.enabled=YES;
}


-(void) clickDownload:(id)sender{
    
    UIButton* bt = (UIButton*)sender;
    if (!bt.enabled) {
        return;
    }
    bt.enabled=NO;
    
    // 防止重复点击
    [self performSelector:@selector(freeButton:)withObject:sender afterDelay:0.5f];

    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:self forKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 发送事件
    NSNotification *notification =[NSNotification notificationWithName:CLICK_DOWNLOAD_BUTTON_NOTIFICATION object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    NSLog(@"finish cell clickDownload");
}

// 停止下载
-(void) stopDownload:(id)sender{
    
    // 获取到button对应的cell
//    TableViewCell *cell = (TableViewCell*)[[self.button superview] superview];
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:self forKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 发送事件
    NSNotification *notification =[NSNotification notificationWithName:CLICK_DOWNLOAD_CANCEL_BUTTON_NOTIFICATION object:nil userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
