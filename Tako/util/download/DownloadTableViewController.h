//
//  DownloadTableViewController.h
//  HelloTako
//
//  Created by 熊海涛 on 16/3/5.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import "App.h"
#import "Constant.h"
#import "AppHisDao.h"
#import "MJRefresh.h"

/* 
 说明：
 tableviewcell复用后，“测试”和”下载管理“页面的大量方法重复，为复用部分代码，新增此类。该类将被两个viewcontroller继承：
 TestViewController  和  DownloadViewController
 */

@interface DownloadTableViewController : UIViewController

@property UIRefreshControl* refreshControl;
@property NSString* cursor;
@property TableViewCell* currentCell;
@property TakoApp* currentApp;
@property (strong, nonatomic)NSMutableArray* listData;

@property (nonatomic,strong) dispatch_queue_t downLoadQueue;// 后台异步线程

// 被复用的接口
-(void)showPasswordConfirm:(NSString*)msg;
-(void)receiveClickDownloadNotification:(NSNotification*)notice;
-(void)receiveCancelDownloadNotification:(NSNotification*)notice;
-(void)downloadApp;
-(void)hideProgressUI:(BOOL)isShow cell:(TableViewCell*)cell;
-(void)updateApp:(TakoApp*)app cell:(TableViewCell*)cell status:(enum APPSTATUS)status;
-(void)updateProgress:(TakoApp*)app cell:(TableViewCell*)cell;
-(void)showDownloadManageView;
-(void)getDownloadUrl;
-(BOOL)isPasswordValid;

// 下载回调
-(void)beginInstall:(TakoApp*)app cell:(TableViewCell*)cell;
-(void)receiveDownloadProgressNotification:(NSNotification*)notice;
-(void)receiveDownloadFinishNotification:(NSNotification*)notice;

// 供download用的接口
-(void)migrateItemIfneed;

-(void)prepare;

//- (NSArray *)rightButtons;

@end

