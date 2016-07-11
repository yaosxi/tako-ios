//
//  DownloadViewController.h
//  HelloTako
//
//  Created by 熊海涛 on 16/3/4.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadTableViewController.h"
//
//@protocol DownloadEventDelegate <NSObject>
//
//// 包含三种情况：手动取消，下载完成，未下载完时强制删除
//-(void)downloadFinishAppversion:(NSString*)versionId;
//
//@end

@interface DownloadViewController : DownloadTableViewController
@property (weak, nonatomic) IBOutlet UITableView *tableview;
//@property (weak,nonatomic) id<DownloadEventDelegate> delegate;
@end
