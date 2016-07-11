//
//  DownloadTableViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 16/3/5.
//  Copyright © 2016年 熊海涛. All rights reserved.
//


#import "TestViewController.h"
#import "TableViewCell.h"
#import "MineViewController.h"
#import "LoginViewController.h"
#import "UIHelper.h"
#import "App.h"
#import "DownloadWorker.h"
#import "Constant.h"
#import "Server.h"
#import "MJRefresh.h"
#import "DownloadQueue.h"
#import "UIImageView+WebCache.h"
#import "DownloadViewController.h"
#import "DownloadTableViewController.h"
#import "SharedInstallManager.h"
#import "InstallingModel.h"
#import "DownloadTableViewController.h"
#import "RKDropdownAlert.h"

@interface DownloadTableViewController ()<XHtDownLoadDelegate,SWTableViewCellDelegate,UIAlertViewDelegate>{
    Boolean isLanOk;
}
@property (nonatomic,strong) NSTimer* timer;
@end



@implementation DownloadTableViewController

-(void)prepare{
    if(self.downLoadQueue == nil){
        self.downLoadQueue = dispatch_queue_create("tako.download.Queue", DISPATCH_QUEUE_SERIAL);
    }
}

#pragma mark 点击事件

// 接收到cell的下载按钮点击事件
-(void)receiveClickDownloadNotification:(NSNotification*)notice{
    NSLog(@"receive click download button event...");
    
    // 创建串行队列
    if (self.downLoadQueue==nil) {
        self.downLoadQueue = dispatch_queue_create("tako.download.Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    // 处理
    if([self.currentApp.password isEqualToString:@"true"] && [XHTUIHelper isEmpty:self.currentApp.downloadPassword]){
        [self showPasswordConfirm:@"您需要输入下载密码。"];
    }else{
        [self downloadApp];
    }
}


// 接收到cell的取消按钮点击事件
-(void)receiveCancelDownloadNotification:(NSNotification*)notice{
    NSLog(@"receive cancel download button event...");
    
    if (IOS_VERSION>=8.0) {
        // 处理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认要取消下载任务？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"您即将取消本次下载...");
            [self cancelDownloadAction];
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        //    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
        //    });
    }else{
        // 处理
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认取消下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1;
        [alertView show];
    }
    
}


-(BOOL)isNetworkGPRS{
    NSString* netWork = [XHTUIHelper networkTypeFromStatusBar];
    if ([netWork isEqualToString:@"2G"] || [netWork isEqualToString:@"3G"]||[netWork isEqualToString:@"4G"]||[netWork isEqualToString:@"5G"]) {
        return YES;
    }
    return NO;
}

-(void)showNetworkConfirm{
    NSLog(@"提示用户是否继续...");
    
    if(IOS_VERSION>=8.0){
        // 弹出确认取消下载提示框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络不是wifi,是否继续?"  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"您取消了本次下载...");
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"继续下载...");
            [self confirmDownload];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络不是wifi,是否继续?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStyleDefault;
        alertView.tag=3;
        [alertView show];
    }
}

// 检查密码是否有效（解决二次安装时，应用密码已更新）
-(BOOL)isPasswordValid{
    
    //   从服务端获取最新的密码信息,并更新内存和持久化的app信息，serverApp.password为实际的下载密码
    TakoApp* serverApp = [TakoServer fetchAppPasswordInfo:self.currentApp.appid];
    if (serverApp) {
        self.currentApp.password=serverApp.password;
    }else{
        return NO;// 找不到app的信息，refactor: 应处理为系统错误。
    }
    
    AppHis* appHis = [[AppHisDao share] fetchAppWithVersionId:self.currentApp.versionId];
    appHis.password=serverApp.password;
    [[AppHisDao share] save];
    
    // 若需要密码，则进行密码校验
    if ([self.currentApp.password isEqualToString:@"true"]) {
        return [TakoServer isPasswordValid:self.currentApp.appid password:self.currentApp.downloadPassword];
    }else{
        return YES;
    }
    
}

# pragma mark 状态分发switch-case
-(void)downloadApp{
    
    // 先检查网络
    if (![XHTUIHelper isConnectionAvailable]){
        [XHTUIHelper tipNoNetwork];
        return;
    }
    
    switch (self.currentApp.status) {
            
        case INITED:
            
            // 实时检查下载密码
            if ([self isPasswordValid]) {
                
                // 实时检查当前网络，非wifi则提醒用户
                if ([self isNetworkGPRS]) {
                    [self showNetworkConfirm];
                    return;
                }else{
                    [self startDownload];
                }
            }else{
                self.currentApp.downloadPassword=nil;
                [self showPasswordConfirm:@"您需要输入下载密码。"];
                return;
            }
            
            break;
        case DOWNLOADED:
            
            // 提前检查内网服务是否可用，若不可用直接返回。
            if (![TakoServer fetchAppPasswordInfo:self.currentApp.appid]) {
                return;
            }
            // 实时检查下载密码
            if ([self isPasswordValid]) {
                [self beginInstall:self.currentApp cell:self.currentCell];
            }else{
                [self showPasswordConfirm:@"您需要输入下载密码。"];
                return;
            }
            break;
        case DOWNLOADED_FAILED:
            [self continueDownload];
            break;
        case STARTED:
            [self pauseDownload];
            break;
        case PAUSED:
            
            // 实时检查当前网络，非wifi则提醒用户
            if ([self isNetworkGPRS]) {
                [self showNetworkConfirm];
                return;
            }else{
                [self continueDownload];
            }
            break;
            //        case INSTALL_FAILED:
            //            [self beginInstall];
            //            break;
        case TOBE_UPDATE:
            [self startDownload];
            break;
            
        default:
            break;
    }
    
    // 等待串行队列执行完再更新ui
    dispatch_async(self.downLoadQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateApp:self.currentApp cell:self.currentCell status:self.currentApp.status];
        });
    });
    
}



// 根据app的执行状态动态更新cell和数据源
-(void)updateApp:(TakoApp*)app cell:(TableViewCell*)cell status:(enum APPSTATUS)status{
    if (cell==nil) {
        return;
    }
    app.status = status;
    switch (status) {
        case INITED:
            //            NSLog(@"app is in init status...");
            app.progress=@"0%";
            [cell.progressControl setProgress:0];
            [self hideProgressUI:YES cell:cell];
            [cell.button setTitle:@"下载" forState:UIControlStateNormal];
            [cell.button setBackgroundColor:[UIColor clearColor]];
            cell.button.layer.borderColor=[XHTUIHelper systemColor].CGColor;
            [cell.button setTitleColor:[XHTUIHelper systemColor] forState:UIControlStateNormal];
            
            break;
        case STARTED:
            NSLog(@"app is in start status...");
            [cell.button setTitle:@"暂停" forState:UIControlStateNormal];
            [self hideProgressUI:NO cell:cell];
            [cell.btnCancel setHidden:YES];//下载过程中，不允许取消
            [cell.button setBackgroundColor:[UIColor clearColor]];
            cell.button.layer.borderColor=[XHTUIHelper systemColor].CGColor;
            [cell.button setTitleColor:[XHTUIHelper systemColor] forState:UIControlStateNormal];
            
            break;
        case PAUSED:
            NSLog(@"app is in pause status...");
            [cell.button setTitle:@"继续" forState:UIControlStateNormal];
            [self hideProgressUI:NO cell:cell];
            [cell.downloadSpeed setHidden:YES];
            [cell.button setBackgroundColor:[UIColor clearColor]];
            cell.button.layer.borderColor=[XHTUIHelper systemColor].CGColor;
            [cell.button setTitleColor:[XHTUIHelper systemColor] forState:UIControlStateNormal];
            
            break;
        case DOWNLOADED:
            NSLog(@"app is in downloaded status...");
//            app.progress=@"100%";
            app.progress=@"0%";
            [cell.progressControl setProgress:0];
            [cell.button setTitle:@"安装" forState:UIControlStateNormal];
            [cell.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cell.button.layer.borderColor=[UIColor clearColor].CGColor;
            [cell.button setBackgroundColor:[UIColor colorWithRed:0.0f green:205/255.f blue:0/255.f alpha:1]];
            cell.appVersion.text = [NSString stringWithFormat:@"版本：%@", app.versionname];
            [self hideProgressUI:YES cell:cell];
            break;
        case DOWNLOADED_FAILED:
            NSLog(@"app is in downloaded failed status...");
            app.progress=@"0%";
            [cell.button setTitle:@"重试" forState:UIControlStateNormal];
            cell.textDownload.text = @"";
            cell.downloadSpeed.text = @"2 KB/s";
            [cell.progressControl setProgress:0];
            [self hideProgressUI:YES cell:cell];
            [cell.button setBackgroundColor:[UIColor clearColor]];
            cell.button.layer.borderColor=[XHTUIHelper systemColor].CGColor;
            [cell.button setTitleColor:[XHTUIHelper systemColor] forState:UIControlStateNormal];
            
            break;
            //        case INSTALLING:
            //            NSLog(@"app is in installing status...");
            //            [cell.button setTitle:@"安装中" forState:UIControlStateNormal];
            //            [self hideProgressUI:YES cell:cell];
            //            break;
            //        case INSTALLED:
            //            NSLog(@"app is in installed status...");
            //            [cell.button setTitle:@"已安装" forState:UIControlStateNormal];
            //            [XHTUIHelper disableDownloadButton:cell.button];
            //            [self hideProgressUI:YES cell:cell];
            //            break;
            //        case INSTALL_FAILED:
            //            NSLog(@"app is in installed failed status...");
            //            [cell.button setTitle:@"安装失败" forState:UIControlStateNormal];
            //            [self hideProgressUI:YES cell:cell];
            //            [XHTUIHelper disableDownloadButton:cell.button];
            //            break;
        case TOBE_UPDATE:
            NSLog(@"app is in to-be-update status...");
            [cell.button setTitle:@"更新" forState:UIControlStateNormal];
            cell.appVersion.text = [NSString stringWithFormat:@"%@ -> %@",app.versionname,app.serverVersion];
            [self hideProgressUI:YES cell:cell];
            [cell.button setBackgroundColor:[UIColor clearColor]];
            cell.button.layer.borderColor=[XHTUIHelper systemColor].CGColor;
            [cell.button setTitleColor:[XHTUIHelper systemColor] forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
}


#pragma mark super类的其他私有方法

-(void)showPasswordConfirm:(NSString*)msg{
    
    if(IOS_VERSION>=8.0){
        // 弹出确认取消下载提示框
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"您取消了本次下载...");
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"密码已输入...");
            UITextField *password = alertController.textFields.firstObject;
            [self confirmPassword:password.text];
            
        }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"请输入下载密码";
            textField.secureTextEntry = YES; // 暂时不做掩码，以便可输入中文
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alertView.tag=2;
        [alertView show];
    }
}


-(void)beginInstall:(TakoApp*)app cell:(TableViewCell*)cell{
    
    // fix: 多版本下载时，产生两次下载监听。只需响应一个
    if (app.versionId==nil && app.serverVersionId==nil) {
        return;
    }
    
    // 开启线程监控。
    //    [[SharedInstallManager shareInstWithdelegate:self] run];
    NSString* itermServiceUrl;
    NSString* testFile;
    
    
    // 是否需要密码
    if (![self.currentApp.password isEqualToString:@"true"]) {
        app.downloadPassword=@"-1";//-1不检查密码
    }
    
    // 如果app是更新状态，需要使用serverVersionid来获取url
    if (app.serverVersionId) {
        itermServiceUrl = [TakoServer fetchItermUrl:app.serverVersionId password:app.downloadPassword];
        testFile = [NSString stringWithFormat:@"%@.ipa",app.serverVersionId];
        
    }else{
        itermServiceUrl = [TakoServer fetchItermUrl:app.versionId password:app.downloadPassword];
        testFile = [NSString stringWithFormat:@"%@.ipa",app.versionId];
    }
    
    // 网络异常，无法获取url
    if(itermServiceUrl==nil){
        return;
    }
    
    NSLog(@"will install,iterm url is:%@",itermServiceUrl);
    
    // md5计算太耗时,提示用户。
    MBProgressHUD* hud = [XHTUIHelper modalAlertIn:self.view withText:@"正在校验文件..."];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int retCode = [XHTUIHelper isDevicefileValid:testFile md5:app.md5];
        NSString* testUrl = [NSString stringWithFormat:@"%@:%d/%@",[XHTUIHelper localIPAddress],HTTP_SERVER_PORT,testFile];
        NSLog(@"file is downloaded ,will install...try the test url in browse:%@",testUrl);
        
        if (retCode == 0 ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itermServiceUrl]];
            //            [XHTUIHelper tipWithText:@"安装已启动,可在桌面查看安装进度~" time:3];
            
            // 监控下载进度
            // [[SharedInstallManager shareInstWithdelegate:self] run];
            
        }else{
            
            NSString* msg = @"";
            if (retCode == 1) {
                msg = @"安装文件无效，请重新下载~";
            }else if (retCode == 2){
                msg = @"安装文件已损坏，请重新下载~";
                // 清除之前的下载记录
                [XHTUIHelper removeDevicefile:[NSString stringWithFormat:@"%@.ipa",app.versionId]];
                [[AppHisDao share] removeAppWithVersionId:app.versionId];
            }
            
            [self updateApp:app cell:cell status:DOWNLOADED_FAILED];
            TakoApp* tempApp = [TakoApp new];
            tempApp.currentlength = @"0";
            tempApp.totallength = @"0";
            tempApp.status = DOWNLOADED_FAILED;
            [[AppHisDao share] updateApp:tempApp];
            [XHTUIHelper alertWithNoChoice:msg view:self];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
    
    
}

// 启动下载
-(void)startDownload{
    NSLog(@"will start download...");
    
    // 若存在内网下载地址，需要在downloadQueue中测试内网url
    [self getDownloadUrl];
    
    // 等待 downloadQueue 上一个任务执行完成
    dispatch_async(self.downLoadQueue, ^{
        
        if (self.currentApp.downloadUrl == nil) {
            DDLogError(@"下载链接无效，无法下载...");
            
            // 下载无法继续进行，更新下载状态
            dispatch_async(dispatch_get_main_queue(), ^{
                AppHis* tempHis = [[AppHisDao share] fetchAppWithVersionId:self.currentApp.versionId];
                if (tempHis==nil) {
                    self.currentApp.status = INITED;// 若无下载记录，则状态写为初始化。
                }else{
                    self.currentApp.status = PAUSED;// 若有下载记录,状态写为暂停。
                }
                [self updateApp:self.currentApp cell:self.currentCell status:self.currentApp.status];
            });
            return ;
        }
        
        //    NSLog(@"start current thread is:%@",    [NSThread currentThread]);
        
        /* 添加到下载队列。注：
         1. 下载队列无界，可无限添加，但每次只能有2个（constant.h中可配置）活跃线程下载。允许重复添加（程序会自动识别）。
         2. 当某个应用暂停后，程序会保存当前进度。即使退出应用，下次进入时，仍可继续下。
         3. 参数tag说明: tag 为每个下载记录的唯一标识。
         */
        TakoApp* app = [TakoApp new];
        app.appid = self.currentApp.appid;
        app.appname = self.currentApp.appname;
        
        // 若是更新，则需要重设versionid
        if (self.currentApp.status == TOBE_UPDATE) {
            app.versionId = self.currentApp.serverVersionId;
            app.versionname = self.currentApp.serverVersion;
            [XHTUIHelper removeDevicefile:[NSString stringWithFormat:@"%@.ipa",self.currentApp.versionId]];// 删除旧版本的安装包
        }else{
            app.versionId = self.currentApp.versionId;
            app.versionname = self.currentApp.versionname;
        }
        
        app.logourl = self.currentApp.logourl;
        app.md5 = self.currentApp.md5;
        app.status = STARTED;
        app.password = self.currentApp.password;
        app.downloadPassword = self.currentApp.downloadPassword;
        app.packagename = self.currentApp.packagename;
        app.isDownloadSuccess = NO;
        app.size = self.currentApp.size;
        app.lanhost = self.currentApp.lanhost;
        app.lanurl = self.currentApp.lanurl;
        app.currentlength = @"0";
        app.totallength = @"0";
        app.releasetime = self.currentApp.releasetime;
        
        [[AppHisDao share] createApp:app]; // 保存下载信息，refactor:可抽为service
        
        
        //    AppHis* aa = [[AppHisDao share] fetchAppWithAppId:app.appid];
        //    NSString* n =  aa.appname;// 调试用
        //    NSLog(@"调试信息:  app is ：%@",aa);
        
        self.currentApp.status=STARTED;
        
        // 必须主线程执行，否则viewcontroller接收不到进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [[XHtDownLoadQueue share] add:self.currentApp.downloadUrl versionid:app.versionId tag:self.currentApp.versionId delegate:self];
        });
    });
}


// 继续下载
-(void)continueDownload{
    
    [self getDownloadUrl];
    
    
    // 等待 downloadQueue 上一个任务执行完成
    dispatch_async(self.downLoadQueue, ^{
        //        NSLog(@"continue current thread is:%@",   [NSThread currentThread]);
        if (self.currentApp.downloadUrl == nil) {
            DDLogError(@"下载链接无效，无法下载...");
            return ;
        }
        
        NSLog(@"will continue download...");
        self.currentApp.status = STARTED;
        
        /* 添加到下载队列。注：
         1. 下载队列无界，可无限添加，但每次只能有1个（constant.h中可配置梳理）活跃线程下载。允许重复添加（程序会自动识别）。
         2. 当某个应用暂停后，程序会保存当前进度。即使退出应用，下次进入时，仍可继续下。
         3. 参数tag说明: tag 为每个下载记录的唯一标识。
         */
        
        // 必须主线程执行，否则viewcontroller接收不到进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [[XHtDownLoadQueue share] add:self.currentApp.downloadUrl versionid:self.currentApp.versionId tag:self.currentApp.versionId delegate:self];
        });});
}



// 暂停下载
-(void)pauseDownload{
    NSLog(@"will pause download...");
    self.currentApp.status = PAUSED;
    [[XHtDownLoadQueue share] pause:self.currentApp.versionId];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}




// 通过bundleid找到对应的index
-(NSInteger)cellIndexWithbundleId:(NSString*)bundleId{
    NSMutableArray* apps = self.listData;
    TakoApp* updateApp = nil;
    for (TakoApp* app in apps) {
        if ([app.bundleid isEqualToString:bundleId]) {
            // updateApp 逻辑上不可能为空
            updateApp = app;
            break;
        }
    }
    if (updateApp == nil) {
        // 原来就存在无法安装的应用，忽略。
        return -1;
    }
    
    return (NSInteger)[apps indexOfObject:updateApp];
}



// 是否隐藏下载进度控件
-(void)hideProgressUI:(BOOL)isHide cell:(TableViewCell*)cell{
    [cell.btnCancel setHidden:isHide];
    [cell.progressControl setHidden:isHide];
    [cell.textDownload setHidden:isHide];
    [cell.appVersion setHidden:!isHide];
    [cell.otherInfo setHidden:!isHide];
    [cell.downloadSpeed setHidden:isHide];
}



#pragma mark 安装进度监听
//-(void) finishInstall:(NSArray*)models{}
//-(void) failedInstall:(NSArray*)models{}
//-(void) currentInstallProgress:(NSArray*)models{}
//-(void) newInstall:(NSArray*)models{}


# pragma mark 纯供子类调用的下载回调

// 下载结束回调
-(void)downloadFinish:(BOOL)isSuccess msg:(NSString*)msg tag:(NSString *)tag{
    NSLog(@"empty ...subclass will implement");
}


// 下载进度回调
-(void)downloadingWithTotal:(long long)totalSize complete:(long long)finishSize speed:(NSString *)speed tag:(NSString *)tag{
    NSLog(@"empty ...subclass will implement...");
}

-(void)receiveDownloadProgressNotification:(NSNotification*)notice{
    
    // 解析notification参数
    NSString* totalSize = (NSString*)[notice.userInfo objectForKey:@"totalSize"];
    long long totalSizeLong = [totalSize longLongValue];
    NSString* finishSize = (NSString*)[notice.userInfo objectForKey:@"finishSize"];
    long long finishSizeLong = [finishSize longLongValue];
    NSString* tag = (NSString*)[notice.userInfo objectForKey:@"tag"];
    NSString* speed = (NSString*)[notice.userInfo objectForKey:@"speed"];
    
    // 处理
    [self downloadingWithTotal:totalSizeLong complete:finishSizeLong speed:speed tag:tag];
}


-(void)receiveDownloadFinishNotification:(NSNotification*)notice{
    
    // 解析notification参数
    NSString* isSuccess = (NSString*)[notice.userInfo objectForKey:@"isSuccess"];
    BOOL isSuccessBool = [isSuccess isEqualToString:@"1"]?YES:NO;
    NSString* msg = (NSString*)[notice.userInfo objectForKey:@"msg"];
    NSString* tag = (NSString*)[notice.userInfo objectForKey:@"tag"];
    
    // 处理
    [self downloadFinish:isSuccessBool msg:msg tag:tag];
}



#pragma mark 滑动回调 Swipe Delegate


- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"More button pressed");
            //            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            //            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"delete button pressed...");
            //            // Delete button was pressed
            //            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            //
            //            [_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
            //            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
#ifdef IS_EXT_BUTTON_DISPLAY
            return YES;
#else
            return NO;
#endif
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
#ifdef IS_EXT_BUTTON_DISPLAY
            return YES;
#else
            return NO;
#endif
            break;
        default:
            break;
    }
    
    return YES;
}


//
//- (NSArray *)rightButtons
//{
//    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                title:@"更多"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"删除"];
//
//    return rightUtilityButtons;
//}


-(void)updateProgress:(TakoApp*)app cell:(TableViewCell*)cell{
    
    if ([app.currentlength longLongValue]==0 || [app.currentlength longLongValue]==0) {
        cell.progressControl.progress = 0;
        cell.textDownload.text =@"等待中...";
    }else{
        cell.progressControl.progress = (float)(float)[app.currentlength longLongValue]/(float)[app.totallength longLongValue];
        NSString* finishStr = [XHTUIHelper formatByteCount:[app.currentlength longLongValue]];
        NSString* totalStr = [XHTUIHelper formatByteCount:[app.totallength longLongValue]];
        NSString* percent = [NSString stringWithFormat:@"%@/%@",finishStr,totalStr];
        cell.textDownload.text = percent;
    }
    
}

-(void)migrateItemIfneed{
    NSLog(@"empty implement...");
}



-(void)getDownloadUrl{
    
    
    // 下载前，先检查密码
    if ([self.currentApp.password isEqualToString:@"true"]) {
        BOOL isValid = [TakoServer isPasswordValid:self.currentApp.appid password:self.currentApp.downloadPassword];
        if (!isValid) {
            [XHTUIHelper tipWithText:@"下载密码错误，请重试!" time:2];
            self.currentApp.downloadPassword=nil;
            self.currentApp.downloadUrl=nil;
            return;
        }
    }else{
        self.currentApp.downloadPassword=nil;//若不需要密码，则情况原来的下载密码。
    }
    
    // 外网下载
    if ([self.currentApp isLanInValidurl:self.currentApp.lanurl host:self.currentApp.lanhost ]) {
        NSString* result = [TakoServer fetchDownloadUrl:self.currentApp.versionId password:self.currentApp.downloadPassword];
        
        // 检查结果,若出错，清空password和url，以便触发下次重输入
        if ([result isEqualToString:HTTP_CODE_REPONSE_NULL]) {
            self.currentApp.downloadPassword=nil;
            self.currentApp.downloadUrl=nil;
            return;
        }else if([result isEqualToString:HTTP_CODE_WRONG_NETWORK]){
            [XHTUIHelper tipWithText:@"只支持内网下载，请尝试切换网络!" time:2];
            self.currentApp.downloadUrl=nil;
            return;
        }else if ([result isEqualToString:HTTP_CODE_WRONG_PASSWORD]){
            [XHTUIHelper tipWithText:@"下载密码错误，请重试!" time:2];
            self.currentApp.downloadPassword=nil;
            self.currentApp.downloadUrl=nil;
            return;
        }else{
            self.currentApp.downloadUrl = result;
        }
        
    }
    
    
    // 内网下载
    else{
        
        // 调整： 2016_05_06 服务端可能不再返回lanhost
        NSString* url=nil;
        if([self.currentApp.lanurl hasPrefix:@"http"]){
            url = [NSString stringWithFormat:@"%@",self.currentApp.lanurl];
        }else{
            url = [NSString stringWithFormat:@"http://%@/%@",self.currentApp.lanhost,self.currentApp.lanurl];
        }
        
        
        // 测试内网可用
        MBProgressHUD* hud = [XHTUIHelper modalAlertIn:self.view withText:@""];
        isLanOk = NO;
        
        dispatch_async(self.downLoadQueue, ^{
            
            NSLog(@"test url current thread is:%@",    [NSThread currentThread]);
            int lanHttpStatusCode = [TakoServer testDownloadUrl:url];
            isLanOk = lanHttpStatusCode==200;
            NSString* newUrl = nil;
            if (!isLanOk) {
                NSLog(@"内网不可用，使用外网下载地址...");
                NSString* result = [TakoServer fetchDownloadUrl:self.currentApp.versionId password:self.currentApp.downloadPassword];
                
                // 检查结果,若出错，清空password和url，以便触发下次重输入
                if ([result isEqualToString:HTTP_CODE_REPONSE_NULL]) {
                    
                    // 内外网下载地址均失效
                    if (lanHttpStatusCode==404) {
                        [XHTUIHelper tipWithText:@"下载链接已失效~" time:2];
                    }
                    self.currentApp.downloadPassword=nil;
                    self.currentApp.downloadUrl=nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                    return;
                }else if([result isEqualToString:HTTP_CODE_WRONG_NETWORK]){
                    [XHTUIHelper tipWithText:@"只支持内网下载，请尝试切换网络!" time:2];
                    self.currentApp.downloadUrl=nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                    return;
                }else if ([result isEqualToString:HTTP_CODE_WRONG_PASSWORD]){
                    [XHTUIHelper tipWithText:@"下载密码错误，请重试!" time:2];
                    self.currentApp.downloadPassword=nil;
                    self.currentApp.downloadUrl=nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                    return;
                }else{
                    newUrl = result;
                }
                
            }else{
                newUrl = url;
                // 隐藏，不提示。
                [XHTUIHelper tipWithText:@"启用内网下载~" time:2];
            }
            
            // newUrl获取为空，说明密码错误。
            if (newUrl==nil && [self.currentApp.downloadPassword length]>0) {
                [XHTUIHelper tipWithText:@"下载密码错误，请重试!" time:2];// todo
            }else if ([XHTUIHelper isEmpty:newUrl]){
                [XHTUIHelper tipWithText:@"获取下载链接失败,请重试!" time:2];// todo
            }
            
            if(newUrl){
                if (!isLanOk) {
                    NSLog(@"内网不可用，使用外网下载地址...");
                    // 隐藏，不提示。
                    //                        [XHTUIHelper tipWithText:@"内网不可用，将使用外网下载~"];
                }
                self.currentApp.downloadUrl = newUrl;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
        });
        
        
    }
}
//}


-(void)showDownloadManageView{
    NSLog(@"will go to download manage page");
    [self.navigationController pushViewController:[[DownloadViewController alloc] init] animated:NO];
}

#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //    NSLog(@"index is:%ld",(long)buttonIndex);
    if (alertView.tag == 1 && buttonIndex ==1) {
        [self cancelDownloadAction];
    }
    else if ( alertView.tag ==2 && buttonIndex==1) {
        UITextField *tf=[alertView textFieldAtIndex:0];
        [self confirmPassword:tf.text];
    }else if (alertView.tag ==3 && buttonIndex==1){
        [self confirmDownload];
    }else if (alertView.tag ==3 && buttonIndex==1){
        NSLog(@"用户取消了下载");
    }
}


-(void)confirmDownload{
    if (self.currentApp.status == INITED) {
        [self startDownload];
    }else if (self.currentApp.status == PAUSED){
        [self continueDownload];
    }
    
    // 等待串行队列执行完再更新ui
    dispatch_async(self.downLoadQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateApp:self.currentApp cell:self.currentCell status:self.currentApp.status];
        });
        
    });
}

-(void)confirmPassword:(NSString*)password{
    
    self.currentApp.downloadPassword = password;//缓存密码
    if ([XHTUIHelper isEmpty:password]||[[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 ||![self isPasswordValid] ) {
        NSLog(@"下载密码无效。");
        [self showPasswordConfirm:@"密码错误，请重新输入!"];
        self.currentApp.downloadPassword = nil;//密码错误，清空密码
        return;
    }
    
    
    [self downloadApp];
}

-(void)cancelDownloadAction{
    // 恢复下载按钮的文本显示
    TableViewCell *cell = self.currentCell;
    [cell.button setTitle:@"下载" forState:UIControlStateNormal];
    
    // 隐藏下载栏
    [self hideProgressUI:YES cell:cell];
    [cell.progressControl setProgress:0];
    if (self.currentApp.isNeedUpdate) {
        self.currentApp.status = TOBE_UPDATE;
    }else{
        self.currentApp.status = INITED;
    }
    [self updateApp:self.currentApp cell:self.currentCell status:self.currentApp.status];
    self.currentApp.progress = @"0%";
    self.currentApp.progressValue=0;
    [self migrateItemIfneed];
    // 停止下载器
    [[XHtDownLoadQueue share] stop:self.currentApp.versionId];
    [[AppHisDao share] removeAppWithVersionId:self.currentApp.versionId];
}


@end