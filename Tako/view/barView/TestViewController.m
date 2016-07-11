//
//  FirstViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/9.
//  Copyright © 2015年 熊海涛. All rights reserved.
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
#import "DownloadQueue.h"
#import "UIImageView+WebCache.h"
#import "DownloadViewController.h"
#import "SWTableViewCell.h"
#import "AppHisDao.h"
#import "AppDetailViewController.h"
#import "SVPullToRefresh.h"
#import "SearchViewController.h"
#import "WZLBadgeImport.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

@interface TestViewController ()<UITableViewDataSource,UITableViewDelegate,XHtDownLoadDelegate,SWTableViewCellDelegate,UISearchBarDelegate,QRCodeReaderDelegate>{
    UITapGestureRecognizer *tapGestureRecognizer;
}
@property (nonatomic,weak)UISearchBar *searchBar;
@property (nonatomic,strong)UIBarButtonItem *downloadBarItem;

@end


@implementation TestViewController



#pragma mark view生命周期


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![XHTUIHelper isConnectionAvailable]){
        [XHTUIHelper tipNoNetwork];
        return;
    }
    
    //将触摸事件添加到当前view,view消失时再remove掉
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [self.navigationController.navigationBar addGestureRecognizer:tapGestureRecognizer];
    
    if ([self.listData count]==0) {
        [self resetAndReloadServerData];// inside , table view will reload.
        return;
    }

    // 读取下载情况，更新状态。
    for(int i=0;i<[self.listData count];i++){
        TakoApp* app = (TakoApp*)[self.listData objectAtIndex:i];
        NSLog(@"app name is:%@,count is:%d",app.appname,i);
//        AppHis* appHis = [[AppHisDao share] fetchAppWithVersionId:app.versionId];
        AppHis* latestHis = [[AppHisDao share] fetchLatestAppWithAppId:app.appid];

        // 下载历史被清空后时，需要处理此情况。
        if (latestHis==nil ||([latestHis.versionId isEqualToString:app.versionId] && latestHis.status > INITED)) {
            app.status = INITED;
        }
        
        // 单版本
        if ([latestHis.versionId isEqualToString:app.versionId]) {
            app = [self updateApp:app withHis:latestHis];
        }
        
        // 多版本下载处理
        if (![latestHis.versionId isEqualToString:app.versionId] && [latestHis.status intValue] == DOWNLOADED) {
            app.status = TOBE_UPDATE;
            app.isNeedUpdate =YES;
            app.serverVersionId = app.versionId;
            if (!app.serverVersion) {
                app.serverVersion = app.versionname;
            }
            app.versionname = latestHis.versionname;
        }
    }
    
    [self.tableview reloadData];
}

-(void)refreshAppFromHis{
    // 读取下载情况，更新状态。
    for(int i=0;i<[self.listData count];i++){
        TakoApp* app = (TakoApp*)[self.listData objectAtIndex:i];
        NSLog(@"app name is:%@,count is:%d",app.appname,i);
        AppHis* appHis = [[AppHisDao share] fetchAppWithVersionId:app.versionId];
        if (appHis==nil && app.status > INITED) {
            app.status = INITED;
        }
        app = [self updateApp:app withHis:appHis];
    }
    [self.tableview reloadData];
}

// todo: view整个上移了
-(void)clearviewData{
    NSLog(@"will clear data");
    self.listData = [NSMutableArray new];
    self.cursor = @"0";
    self.currentCell=nil;
    self.currentApp=nil;
    //    self.view = nil;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.searchBar resignFirstResponder];
}


- (void)viewDidLoad {
    
    [XHTUIHelper writeNSUserDefaultsWithKey:IS_LOAD_BAR_VIEW_KEY withObject:@"1"];
    
    [super viewDidLoad];
    self.tableview.separatorColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:1];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    //    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    
    // 增加手势切换页面
    //    [self addTabBarswipeGesture];
    
    // 增加搜索框
    [self addSearchBar];
    self.title = @"测试";
    //    self.title = @"我参与的测试";
    self.navigationController.tabBarItem.title = @"测试";
    
    [XHTUIHelper formatNavigateColor:self.navigationController.navigationBar];// 将导航栏设置为蓝色
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];// 默认为蓝色，此处更改为白色以适应push出来的子view导航栏的文字颜色。
    
    // 隐藏tableview中多余的单元格线条
    [XHTUIHelper setExtraCellLineHidden:self.tableview];
    
    // 表格的源数据
    self.listData =[NSMutableArray new];
    
    // 添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClickDownloadNotification:) name:CLICK_DOWNLOAD_BUTTON_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCancelDownloadNotification:) name:CLICK_DOWNLOAD_CANCEL_BUTTON_NOTIFICATION object:nil];
    
    // 退出登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearviewData) name:USER_LOGOUT_NOTIFICATION object:nil];
    
    
    // 添加下载进度监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownloadProgressNotification:) name:XHT_DOWNLOAD_PROGERSS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownloadFinishNotification:) name:XHT_DOWNLOAD_FINISH_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goLogin) name:SESSION_ILLEGAL_NOTIFICATION object:nil];
    
    
    // 增加导航栏的下载管理页面入口
    UIButton* button = [XHTUIHelper navButtonWithImage:@"download"];
    [button addTarget:self action:@selector(showDownloadManageView)
     forControlEvents:UIControlEventTouchUpInside];
    self.downloadBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.downloadBarItem.badgeBgColor = [UIColor colorWithRed:1 green:(float)102/255 blue:(float)102/255 alpha:1];
    
    [self.navigationItem setRightBarButtonItem:self.downloadBarItem ];
    
    NSMutableArray* leftButtons = [NSMutableArray new];
#ifdef IS_SIDE_MENU_ENABLE
    // 增加menu口
    UIButton* menuButton = [XHTUIHelper navButtonWithImage:nil];
    [menuButton setTitle:@"≡" forState:UIControlStateNormal];
    menuButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [menuButton addTarget:self action:@selector(showMenuView)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    [leftButtons addObject:item2];
//    [self.navigationItem setLeftBarButtonItem:item2];
#endif

#ifdef IS_SCAN_ENABLE
    // 增加scan口
    UIButton* scanButton = [XHTUIHelper navButtonWithImage:@"scan_logo"];
    [scanButton addTarget:self action:@selector(showScanView)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    [leftButtons addObject:item3];
#endif
    [self.navigationItem setLeftBarButtonItems:leftButtons];

    
    // 未登录时不显示tableview
    [self.tableview setHidden:![XHTUIHelper isLogined]];
    
    // 隐藏tableview中多余的单元格线条
    [XHTUIHelper setExtraCellLineHidden:self.tableview];
    
    // 注册cell
    [self.tableview registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:@"TableViewCell"];
    
    // 注册 "加载更多"
    self.tableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 注册 "下拉刷新"
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(resetAndReloadServerData)];
    
    // 设置文字
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];

    // 设置刷新控件
    self.tableview.mj_header = header;
    
}

#pragma mark cell上的点击事件

// 接收到cell的下载按钮点击事件
-(void)receiveClickDownloadNotification:(NSNotification*)notice{
    NSLog(@"enter test receiveClickDownloadNotification");
    
    // 定位到当前的cell
    TableViewCell* cell = (TableViewCell*)[notice.userInfo objectForKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 区别1：两次监听中，只有一个是合法的。
    BOOL isValid = cell.tag == CELL_FOR_TEST_PAGE_KEY;
    if (!isValid) {
        return;
    }
    
    // 区别2：两个controller的数据源维度不一样。
    TakoApp* app = nil;
    NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
    app = [self.listData objectAtIndex:indexPath.row];
    self.currentApp = app;
    self.currentCell = cell;
    
    [super receiveClickDownloadNotification:notice];
    
    NSLog(@"finish test receiveClickDownloadNotification");
}


// 接收到cell的取消按钮点击事件
-(void)receiveCancelDownloadNotification:(NSNotification*)notice{
    // 定位到当前的cell
    TableViewCell* cell = (TableViewCell*)[notice.userInfo objectForKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 区别1：两次监听中，只有一个是合法的。
    BOOL isValid = cell.tag == CELL_FOR_TEST_PAGE_KEY;
    if (!isValid) {
        return;
    }
    
    // 区别2：两个controller的数据源维度不一样。
    TakoApp* app = nil;
    NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
    app = [self.listData objectAtIndex:indexPath.row];
    
    self.currentApp = app;
    self.currentCell = cell;
    
    [super receiveCancelDownloadNotification:notice];
}



#pragma mark tableview的delegate


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}



//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TakoApp* app = (TakoApp*)[self.listData objectAtIndex:indexPath.row];
    
#ifdef IS_CELL_EXT_BUTTON_DISPLAY
    if (app.isClicked) {
        return 125;
    }
#endif
    if (app.isHidden) {
        return 0;
    }
    return 80;
}

// 点击单元格，可显示扩展按钮。暂时关闭该页面。如需激活该方法，需要修改cell中设置。
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    TakoApp* app = (TakoApp*)[self.listData objectAtIndex:indexPath.row];
    for (TakoApp* temp in self.listData) {
        if (temp != app) {
            temp.isClicked = NO;
        }
    }
    app.isClicked = !app.isClicked;
    
    // 关闭键盘
    [self.searchBar resignFirstResponder];
    
#ifdef IS_APP_DETAIL_DISPLAY
    AppDetailViewController* detailVC= [[AppDetailViewController alloc] init];
    detailVC.app = app;
    [self.navigationController pushViewController:detailVC animated:YES];
#endif
    // animate the cell change
    [tableView beginUpdates];
    [tableView endUpdates];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }

    
    // 数据绑定
    TakoApp* app = (TakoApp*)[self.listData objectAtIndex:indexPath.row];
    // [cell.button setHidden:NO];
    cell.appName.text=app.appname;
    cell.appVersion.text = [NSString stringWithFormat:@"版本：%@_%@", app.versionname, app.buildnumber];
    cell.otherInfo.text = [NSString stringWithFormat:@"%@  %@",app.releasetime,app.size];
    
    [cell.appImage sd_setImageWithURL:[NSURL URLWithString:app.logourl]
                     placeholderImage:[UIImage imageNamed:@"ic_defaultapp"]];
    
    [super updateApp:app cell:cell status:app.status];
    [super updateProgress:app cell:cell];
    
    
    // 标记当前cell
    cell.tag = CELL_FOR_TEST_PAGE_KEY;
    
    // 添加扩展按钮
    //    cell.delegate = self;
    //    cell.rightUtilityButtons = [self rightButtons];
    
#ifdef DEBUG
    //    NSLog(@"Cell recursive description:\n\n%@\n\n", [cell performSelector:@selector(recursiveDescription)]);
#endif
    
    return cell;
}

//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    TableViewCell* newcell = (TableViewCell*)cell;
//    bool ishiddend = newcell.button.hidden;
//    NSLog(@"cell is:%@",newcell.button);
//}



#pragma mark  download的回调
// 下载结束回调
-(void)downloadFinish:(BOOL)isSuccess msg:(NSString*)msg tag:(NSString *)tag{
//    NSLog(@"收到回调通知：文件下载完成。");
    
    TableViewCell* cell = nil;
    TakoApp* app = nil;
    
    // 找到对应的cell,app
    for (int i=0; i<[self.listData count]; i++) {
       TakoApp* tempApp = (TakoApp*)[self.listData objectAtIndex:i];
        if ([tempApp.versionId isEqualToString:tag]) {
            app = tempApp;
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            cell = [self.tableview cellForRowAtIndexPath:path];
            break;
        }
    }
    
    // fix: 多版本下载时，app信息需要重新获取，不能从当前的listData中遍历。
    if(app==nil){
        AppHis* tempHis = [[AppHisDao share] fetchAppWithVersionId:tag];
        app = [TakoApp new];
        app.versionId = tempHis.versionId;
        app.appid = tempHis.appid;
        app.md5 = tempHis.md5;
        app.downloadPassword = tempHis.downloadPassword;
    }
    
    if (isSuccess) {
        [super updateApp:app cell:cell status:DOWNLOADED];
        [super beginInstall:app cell:cell];
        
        // 更新version显示
        if (app.serverVersion) {
            app.versionname = app.serverVersion;
        }
        cell.appVersion.text = [NSString stringWithFormat:@"版本：%@_%@", app.versionname, app.buildnumber];
        
    }else {
        [XHTUIHelper alertWithNoChoice:[NSString stringWithFormat:@"%@",msg] view:[XHTUIHelper getCurrentVC]];
        AppHis* tempHis = [[AppHisDao share] fetchAppWithVersionId:tag];
        if (tempHis==nil) {
        [super updateApp:app cell:cell status:INITED];// 下载失败时，若无下载记录，则状态写为初始化。
        }else{
        [super updateApp:app cell:cell status:PAUSED];// 下载失败时，状态写为暂停。
        }
        
    }
}


// 下载进度回调
-(void)downloadingWithTotal:(long long)totalSize complete:(long long)finishSize speed:(NSString *)speed tag:(NSString *)tag{
    
    float prg = (float)finishSize/totalSize;
    NSString* finishStr = [XHTUIHelper formatByteCount:finishSize];
    NSString* totalStr = [XHTUIHelper formatByteCount:totalSize];
    NSString* percent = [NSString stringWithFormat:@"%@/%@",finishStr,totalStr];
    
    
    TableViewCell* cell = nil;
    TakoApp* app = nil;
    
    // 找到对应的cell
    for (int i=0; i<[self.listData count]; i++) {
        app = (TakoApp*)[self.listData objectAtIndex:i];
        if ([app.versionId isEqualToString:tag]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            cell = [self.tableview cellForRowAtIndexPath:path];
            break;
        }
    }
    
    // 更新cell
    [cell.progressControl setProgress:prg];
    cell.textDownload.text = percent;
    cell.downloadSpeed.text = speed;
    
    // 更新app
    app.currentlength = [XHTUIHelper stringWithLong:finishSize];;
    app.totallength = [XHTUIHelper stringWithLong:totalSize];;
    app.progress = percent;
    app.progressValue = prg;
    
}


#pragma mark view的其他私有方法
-(void)resetAndReloadServerData{
    
    self.cursor = @"0";
    // 从server端拉取数据
    NSArray* newdata = [self fetchDataFromServer];
    [self.tableview.mj_footer endRefreshing];
    [self.tableview.mj_header endRefreshing];
    
    // 没有数据之间返回。
    if ([newdata count]==0) {
        [self.tableview reloadData];
        return;
    }
    // 检查历史下载记录
    for(int i=0;i<[newdata count];i++){
        TakoApp* app = (TakoApp*)[newdata objectAtIndex:i];
        
        
        AppHis* latestHis = [[AppHisDao share] fetchLatestAppWithAppId:app.appid];
        
        
        if (latestHis==nil) {
            continue;
        }
        
        // 单版本下载处理
        if ([latestHis.versionId isEqualToString:app.versionId]) {
            app = [self updateApp:app withHis:latestHis];
        }
        
        // 多版本下载处理
        if (![latestHis.versionId isEqualToString:app.versionId] && [latestHis.status intValue] == DOWNLOADED) {
            app.status = TOBE_UPDATE;
            app.isNeedUpdate =YES;
            app.serverVersionId = app.versionId;
            if (!app.serverVersion) {
                app.serverVersion = app.versionname;
            }
            app.versionname = latestHis.versionname;
        }
    }
    
    self.listData = [NSMutableArray arrayWithArray:newdata];
    [self.tableview reloadData];
    self.cursor = [NSString stringWithFormat:@"%lu",(unsigned long)[self.listData count]];
}


- (void)loadMoreData
{
    // 从server端拉取数据
    NSArray* newdata = [self fetchDataFromServer];
    
    // 没有新数据提示
    if ([newdata count]==0) {
        [self.tableview.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    
    // fix: 检查是否为无网络下的重复数据.
    TakoApp* tempApp = (TakoApp*)[newdata objectAtIndex:0];
    if ([self.listData count]>0) {
        for (TakoApp* app in self.listData) {
            if ([app.versionId isEqualToString:tempApp.versionId]) {
                [self.tableview.mj_footer endRefreshingWithNoMoreData];
                return;
            }
        }
    }
   
    // 检查历史下载记录
    for(int i=0;i<[newdata count];i++){
        TakoApp* app = (TakoApp*)[newdata objectAtIndex:i];
        
        AppHis* appHis = [[AppHisDao share] fetchAppWithVersionId:app.versionId];
        if (appHis==nil) {
            continue;
        }
        app = [self updateApp:app withHis:appHis];
    }
    
    [self.listData addObjectsFromArray:newdata];
    
    [self.tableview reloadData];
    [self.tableview.mj_footer endRefreshing];
    
    // 更新游标
    self.cursor = [NSString stringWithFormat:@"%lu",(unsigned long)[self.listData count]];
}


-(NSMutableArray*)fetchDataFromServer{
    if (self.cursor==nil) {
        self.cursor=@"0";
    }
    
    if (![XHTUIHelper isConnectionAvailable]){
        [XHTUIHelper tipNoNetwork];
        return [NSMutableArray new];
    }
    
    NSMutableArray* data = [TakoServer fetchApp:self.cursor];
    return data;
}






// 根据历史信息，部分字段需要回填app
-(TakoApp*) updateApp:(TakoApp*)app withHis:(AppHis*)appHis{
    
    // 下载历史被清空后时，需要处理此情况。
    if (appHis==nil || ( [appHis.versionId isEqualToString:app.versionId] && app.status > INITED)) {
        app.status = INITED;
        return app;
    }
    
    if(!appHis){
        return app;
    }
    
    int status = [appHis.status intValue];
    NSLog(@"app name:%@,app bundle id:%@",app.appname,app.bundleid);
    // 如果已经下载成功了，且发现新版本，则更新app的状态
    if ([appHis.isDownloadSuccess boolValue]) {
        
        BOOL isNewVersion = ![app.versionId isEqualToString:appHis.versionId] ;
        
        // 若不是新版本，再判断下serversionId的字段
        if (!isNewVersion) {
            isNewVersion = app.serverVersionId!=nil && ![app.serverVersionId isEqualToString:appHis.versionId];
        }
        
        
        if (isNewVersion) {
            app.status = TOBE_UPDATE;
            app.isNeedUpdate =YES;
            app.serverVersionId = app.versionId;
            app.serverVersion = app.versionname;
            app.isDownloadSuccess = YES;
        }else{
            app.status = status;
            app.isDownloadSuccess = YES;
        }
        
    }
    
    // 已下载 或 安装失败
    else if (status == DOWNLOADED || status == INITED) {
        app.status = status;
    }
    
    // 尚未下载完
    else if(status == STARTED || status == PAUSED){
        app.status = status;
        float currentL = [appHis.currentlength floatValue];
        float totalL = [appHis.totallength floatValue];
        
        
        // 正常情况下不存在，除非应用调试阶段强制退出。
        if (totalL == 0 || currentL == 0) {
            app.progressValue = 0;
            // 有一种情况，已安装，进度立即清零。此时无需关注该警告。
            DDLogWarn(@"warning!!! 原始进度可能丢失，需要重新下载.");
        }else{
            app.progressValue = (float)currentL/totalL;
        }
        
        
        NSString* finishStr = [XHTUIHelper formatByteCount:currentL];
        NSString* totalStr = [XHTUIHelper formatByteCount:totalL];
        NSString* percent = [NSString stringWithFormat:@"%@/%@",finishStr,totalStr];
        app.currentlength = appHis.currentlength;
        app.totallength = appHis.totallength;
        app.progress = percent;
    }
    
    
    
    // 未更新前，需要使用,版本id和版本name。
    app.versionId = appHis.versionId;
    app.versionname = appHis.versionname;
    
    // 若密码又在后台取消了，则不能读取老密码。
    if ([app.password isEqualToString:@"true"]) {
        app.downloadPassword = appHis.downloadPassword;
    }
    
    
    return app;
}


-(BOOL)updateApp:(TakoApp*)app withDownloadPage:(NSArray*)listdata{
    BOOL isExist = NO;
    NSArray* temp = [listdata objectAtIndex:1];
    for (int i=0; i<[temp count]; i++) {
        TakoApp* tempApp = [temp objectAtIndex:i];
        if ([app.versionId isEqualToString:tempApp.versionId]) {
            app = tempApp;
            isExist = YES;
            break;
        }
    }
    return isExist;
}

// 返回NO，可以解决SWSwipeTableCell两侧的扩展按钮，整体出现的问题。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// 允许滑动
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPat{
    NSLog(@"ok");
}

-(void)viewWillUnload{
    NSLog(@"test view will unload...");
}

-(void)viewDidUnload{
    NSLog(@"test view did unload...");
}


// clear live object
- (void)dealloc
{
    //    [[AppHisDao share] save];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// 增加搜索框
-(void)addSearchBar{
    
    CGRect frame = CGRectMake(0, 0, 200, 28);
    UIView *titleView = [[UIView alloc] initWithFrame:frame];//allocate titleView
    UIColor *color =  self.navigationController.navigationBar.backgroundColor;//背景色保持一致
    [titleView setBackgroundColor:color];//
    
    
    
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.backgroundImage = [UIImage new];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.frame = frame;
    searchBar.backgroundColor = color;
    [searchBar.layer setBorderColor:[UIColor grayColor].CGColor];//设置边框为白色
    [searchBar.layer setBorderWidth:0.5];
    searchBar.layer.cornerRadius = 5;
    searchBar.layer.masksToBounds = YES;
    searchBar.placeholder  = @"过滤列表中应用";
    searchBar.keyboardType = UIKeyboardAppearanceDefault;
    searchBar.tintColor = [UIColor blackColor];// 设置输入时光标的颜色
    
    [titleView addSubview:searchBar];
    self.searchBar = searchBar;
    self.navigationItem.titleView = titleView;
}

#pragma mark searchbar-delegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
#ifdef IS_ADVANCE_SEARCH_ENABLE
    SearchViewController* searchVc = [[SearchViewController alloc] init];
    [searchVc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:searchVc animated:YES completion:nil];
#endif
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"search text is %@",searchText);
    int showCount = 0;
    int hideCount = 0;
    for (TakoApp* app in self.listData) {
        if ([searchText isEqualToString:@""]) {
            app.isHidden = NO;
            showCount++;
        }else {
            
            if ([XHTUIHelper isString:app.appname ContainsString:searchText]) {
                app.isHidden = NO;
                showCount++;
                NSLog(@"appName is:%@",app.appname);
            }else{
                app.isHidden = YES;
                hideCount++;
            }}
    }
    [self.tableview reloadData];
}




-(void)showMenuView{
    NSLog(@"will show main menu...");
    id rootVc =[[UIApplication sharedApplication].windows objectAtIndex:1].rootViewController;
    NSLog(@"root viewcontroller is:%@",rootVc);
    [rootVc presentMenuViewController];
    
}


-(void)setShowNewDownload:(BOOL)isShow{
    if (isShow) {
        [self.downloadBarItem showBadgeWithStyle:WBadgeStyleNew value:0 animationType:WBadgeAnimTypeShake];
    }else{
        [self.downloadBarItem clearBadge];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_TEST];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_TEST];
    [self.navigationController.navigationBar removeGestureRecognizer:tapGestureRecognizer];
}

-(void)showScanView{
    if (![QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        NSLog(@"Reader not supported by the current device");
        [XHTUIHelper alertWithNoChoice:@"请先在[设置-Tako]中允许Tako访问相机~" view:nil];
    }else{
        static QRCodeReaderViewController *vc = nil;
        QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
}

#pragma mark scan Delegate

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    
    // todo: change to UIAlertView
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"扫描结束" message:result preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"取消");
}

-(void)goLogin{
   [self presentViewController:[LoginViewController new] animated:NO completion:nil];
}

@end
