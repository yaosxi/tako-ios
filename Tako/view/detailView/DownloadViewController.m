//
//  DownloadViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 16/3/4.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "DownloadViewController.h"
#import "TableViewCell.h"
#import "UIHelper.h"
#import "Constant.h"
#import "Server.h"
#import "UIImageView+WebCache.h"
#import "DownloadQueue.h"
#import "TestViewController.h"

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate,XHtDownLoadDelegate,SWTableViewCellDelegate>
@property(strong,nonatomic)  NSMutableArray* sectionTitleArray;
@property(retain,nonatomic)  UIBarButtonItem *editButton ;
@property(retain,nonatomic)  UIBarButtonItem *space ;
@property(retain,nonatomic)  UIBarButtonItem *selectAllButton ;
@property(retain,nonatomic)  UIBarButtonItem *deleteButton ;
@property (nonatomic) BOOL isAllSelected ;
@property (nonatomic) BOOL isInEditMode ;
@end

#define PNG_SELECTED @"selected_button"
#define PNG_DESELECT @"select_button"

@implementation DownloadViewController

#pragma mark view生命周期

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 显示tab栏
    [self.tabBarController.tabBar setHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // 隐藏tab栏
    [self.tabBarController.tabBar setHidden:YES];
    
    [self reloadViewData];
    
    if ([self.navigationItem.rightBarButtonItems count]==5) {
        NSLog(@"半退出状态，不更新");
        return;
    }
    
    // 没有数据不显示“编辑按钮”
    NSArray* items;
    if([(NSArray*)[self.listData objectAtIndex:0] count]==0 && [(NSArray*)[self.listData objectAtIndex:1] count]==0){
        items = [NSArray arrayWithObjects:self.space, nil];
        self.navigationItem.rightBarButtonItems = items;
    }else{
        items = [NSArray arrayWithObjects:self.editButton, nil];
        self.navigationItem.rightBarButtonItems = items;
    }
    [self sortByStatus];
    [self.tableview reloadData];
}

-(void)editApp{
    NSLog(@"edit app");

    
    if ([self.editButton.title isEqualToString:@"编辑"]) {
        self.isInEditMode = YES;
        self.editButton.title = @"完成";
        
        // 允许编辑
        NSArray* items = [NSArray arrayWithObjects:self.editButton,self.space,self.deleteButton,self.space,self.selectAllButton, nil];
        self.navigationItem.rightBarButtonItems = items;
        self.title = @"";
    }else{
        self.isInEditMode = NO;
        self.editButton.title = @"编辑";
        NSArray* items = [NSArray arrayWithObjects:self.editButton,nil];
        self.navigationItem.rightBarButtonItems = items;
        
        // 清空所有标记位
        for (int i = 0; i<[self.sectionTitleArray count]; i++) {
            for (TakoApp* app in [self.listData objectAtIndex:i]) {
                app.isSelected = NO;
            }
        }
        self.title = @"下载管理";
        
    }
    [self.tableview reloadData];
    
}

-(void)selectAllApp{
    NSLog(@"select all app");
    self.isAllSelected = !self.isAllSelected;
    for (int i = 0; i<[self.sectionTitleArray count]; i++) {
        for (TakoApp* app in [self.listData objectAtIndex:i]) {
            app.isSelected = self.isAllSelected;
        }
    }
    
    [self.tableview reloadData];
}


-(void)deleteApp{
    NSLog(@"delete app");
    
    NSMutableArray* newListData = [[NSMutableArray alloc] initWithObjects:[NSMutableArray new],[NSMutableArray new], nil];
   
    int leftAppCount = 0;
    int selectedAppCount = 0;
    // 删除选中的app安装包
        for (int i = 0; i<[self.sectionTitleArray count]; i++) {
            for (TakoApp* app in [self.listData objectAtIndex:i]) {
                NSMutableArray* newSectionData = [NSMutableArray arrayWithArray:[self.listData objectAtIndex:i]];
                if (app.isSelected) {
                    NSLog(@"will remove file,app name is:%@",app.appname);
                    [XHTUIHelper removeDevicefile:[NSString stringWithFormat:@"%@.ipa",app.versionId]];
                    [[AppHisDao share] removeAppWithVersionId:app.versionId];
                    [[XHtDownLoadQueue share] stop:app.versionId];
                    [newSectionData removeObject:app];
                    selectedAppCount = selectedAppCount +1;
                }else{
                    leftAppCount = leftAppCount +1;
                    [[newListData objectAtIndex:i] addObject:app];
                }
            }
        }
    self.listData = newListData;
    [self.tableview reloadData];
    [self refreshTableTitle];
    
    if (leftAppCount ==0) {
        // 修改数组长度
        NSArray* items = [NSArray arrayWithObjects:self.editButton,nil];
        self.navigationItem.rightBarButtonItems = items;
    }
    
    if (selectedAppCount == 0) {
        [XHTUIHelper alertWithNoChoice:@"没有选中的应用~" view:self];
    }else{
//        [XHTUIHelper alertWithNoChoice:@"应用已删除~" view:self]; //无需提示
        NSNotification *notification =[NSNotification notificationWithName:APP_DELETE_NOTIFICATION object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
}



- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.isAllSelected = NO;
    self.isInEditMode = NO;
    self.title = @"下载管理";

    self.navigationController.navigationBar.hidden = NO;
    
    // 编辑/完成
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑"
                                                       style:UIBarButtonItemStylePlain target:self action:@selector(editApp)];
    

    self.space = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                  style:UIBarButtonItemStyleDone target:nil action:nil];
    
    self.selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"全选"
                                                            style:UIBarButtonItemStylePlain target:self action:@selector(selectAllApp)];
    
    
    self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"删除"
                                                         style:UIBarButtonItemStylePlain target:self action:@selector(deleteApp)];
    
    NSArray* items = [NSArray arrayWithObjects:self.editButton, nil];
    self.navigationItem.rightBarButtonItems = items;

    
    // 隐藏tableview中多余的单元格线条
    [XHTUIHelper setExtraCellLineHidden:self.tableview];
    
    // 添加按钮点击监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClickDownloadNotification:) name:CLICK_DOWNLOAD_BUTTON_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCancelDownloadNotification:) name:CLICK_DOWNLOAD_CANCEL_BUTTON_NOTIFICATION object:nil];
    
    // 添加下载进度监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownloadProgressNotification:) name:XHT_DOWNLOAD_PROGERSS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDownloadFinishNotification:) name:XHT_DOWNLOAD_FINISH_NOTIFICATION object:nil];
    
    [self reloadViewData];
    
}

#pragma mark tableview的delegate

//section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitleArray objectAtIndex:section];
}


// 改变行的高度,todo: 为何自定义的cell本身未生效？
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    TableViewCell *cell = [self.tableview cellForRowAtIndexPath:indexPath];
//    [self showCheckbox:YES image:@"selected_button" cell:cell];
//}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}


// section数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionTitleArray count];
}

// section中的cell数目
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.listData count] == 0 || [self.listData objectAtIndex:section] ==nil) {
        return 0;
    }
    return [[self.listData objectAtIndex:section] count];
}

// 加载单元格
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    
    
    
    TakoApp* app = [(NSArray*)[self.listData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.appName.text = app.appname;
    cell.appVersion.text = [NSString stringWithFormat:@"版本：%@", app.versionname];
    cell.otherInfo.text = [NSString stringWithFormat:@"%@  %@",app.releasetime,app.size];
    
    [cell.appImage sd_setImageWithURL:[NSURL URLWithString:app.logourl]
                     placeholderImage:[UIImage imageNamed:@"ic_defaultapp"]];
    
    
    [super updateApp:app cell:cell status:app.status];
    [super updateProgress:app cell:cell];
    // fix: 解决二次安装时，未下载状态即为100%
    if (app.status==DOWNLOADED) {
        [cell.progressControl setProgress:0];
    }
    
    
    // 标记当前cell
    cell.tag = CELL_FOR_DOWNLOAD_MANAGE_PAGE_KEY;
    
    // 添加扩展按钮
//    cell.delegate = self;
//    cell.rightUtilityButtons = [self rightButtons];
    
    // 是否处于编辑模式
    if (self.isInEditMode) {
        [self showCheckbox:YES cell:cell app:app];
    }else{
        [self showCheckbox:NO cell:cell app:app];
    }
    
    return cell;
}

// 增加间距，否则，无下载次数时section会重叠。
-(UIView*)tableView:(UITableView*)tableView
viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// 返回NO，可以解决两侧的扩展按钮，整体出现的问题。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark 点击事件

// 接收到cell的下载按钮点击事件, 调用父类方法处理。
-(void)receiveClickDownloadNotification:(NSNotification*)notice{
    
    // 定位到当前的cell
    TableViewCell* cell = (TableViewCell*)[notice.userInfo objectForKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 区别1：两次监听中，只有一个是合法的。
    BOOL isValid = cell.tag == CELL_FOR_DOWNLOAD_MANAGE_PAGE_KEY;
    if (!isValid) {
        return;
    }
    
    // 区别2：两个controller的数据源维度不一样。
    TakoApp* app = nil;
    NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
    app = [[self.listData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    self.currentApp = app;
    self.currentCell = cell;
    
//    enum APPSTATUS beforeStatus = self.currentApp.status;
    [super receiveClickDownloadNotification:notice];
    enum APPSTATUS afterStatus = self.currentApp.status;

    if (afterStatus == STARTED && indexPath.section == 0) {
        // 如果从已下载中重下载，需要重新迁移
        [self migrateItemIfneed];
    }
//    [self sortByStatus]; //体验效果不友好，暂时不做排序。
}


// 接收到cell的取消按钮点击事件, 调用父类方法处理。
-(void)receiveCancelDownloadNotification:(NSNotification*)notice{
    
    
    // 定位到当前的cell
    TableViewCell* cell = (TableViewCell*)[notice.userInfo objectForKey:CELL_INDEX_NOTIFICATION_KEY];
    
    // 区别1：两次监听中，只有一个是合法的。
    BOOL isValid = cell.tag == CELL_FOR_DOWNLOAD_MANAGE_PAGE_KEY;
    if (!isValid) {
        return;
    }
    
    // 区别2：两个controller的数据源维度不一样。
    TakoApp* app = nil;
    NSIndexPath* indexPath = [self.tableview indexPathForCell:cell];
    app = [[self.listData objectAtIndex:1] objectAtIndex:indexPath.row];
    
    self.currentApp = app;
    self.currentCell = cell;
    
    [super receiveCancelDownloadNotification:notice];
    
    
}

#pragma mark view的其他私有方法

// 更新下载数量
-(void)refreshTableTitle{
    NSMutableArray* downloadingList = [self.listData objectAtIndex:1];
    NSMutableArray* downloadedList = [self.listData objectAtIndex:0];
    
    // 设置section title
    NSString* title1 = [NSString stringWithFormat:@"已完成(%lu)",(unsigned long)[downloadedList count]];
    NSString* title2 = [NSString stringWithFormat:@"下载中(%lu)",(unsigned long)[downloadingList count]];
    
    [self.sectionTitleArray replaceObjectAtIndex:0 withObject:title1];
    [self.sectionTitleArray replaceObjectAtIndex:1 withObject:title2];
}

// 更新已下载状态数
-(void)migrateItemIfneed{
    NSMutableArray* downloadingList = [self.listData objectAtIndex:1];
    NSMutableArray* newDowloadingList = [NSMutableArray arrayWithArray:downloadingList];
    
    NSMutableArray* downloadedList = [self.listData objectAtIndex:0];
    NSMutableArray* newDowloadedList = [NSMutableArray arrayWithArray:downloadedList];

    if (downloadingList != nil) {
        for (int i=0; i<[downloadingList count]; i++) {
            TakoApp* temp = [downloadingList objectAtIndex:i];
            if (temp.status == DOWNLOADED) {
                [newDowloadedList addObject:temp];
                [newDowloadingList removeObject:temp];
            }
            if (temp.status == INITED) {
                [newDowloadingList removeObject:temp];
            }
        }
    }
    
    if (downloadedList != nil) {
        for (int i=0; i<[downloadedList count]; i++) {
            TakoApp* temp = [downloadedList objectAtIndex:i];
            if (temp.status != DOWNLOADED) {
                [newDowloadingList addObject:temp];
                [newDowloadedList removeObject:temp];
            }
        }
    }
    
    
  
    [self.listData replaceObjectAtIndex:0 withObject:newDowloadedList];
    [self.listData replaceObjectAtIndex:1 withObject:newDowloadingList];
    

    [self refreshTableTitle];
    [self.tableview reloadData];
}


#pragma mark  下载回调

// 下载结束回调
-(void)downloadFinish:(BOOL)isSuccess msg:(NSString*)msg tag:(NSString *)tag{
//    NSLog(@"收到回调通知：文件下载完成。");
    
    TableViewCell* cell = nil;
    TakoApp* app = nil;
    
    // 只遍历第二个section
    NSArray* cellList = [self.listData objectAtIndex:1];
    
    // 找到对应的cell,app
    for (int i=0; i< [cellList count]; i++) {
        app = (TakoApp*)[cellList objectAtIndex:i];
        if ([app.versionId isEqualToString:tag]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
            cell = [self.tableview cellForRowAtIndexPath:path];
            break;
        }
    }
    
    if (isSuccess) {
        [super updateApp:app cell:cell status:DOWNLOADED];
        [super beginInstall:app cell:cell];
    }else {
        [XHTUIHelper alertWithNoChoice:[NSString stringWithFormat:@"%@",msg] view:[XHTUIHelper getCurrentVC]];
        [super updateApp:app cell:cell status:PAUSED];// 下载失败时，状态写为暂停。
    }
    [self migrateItemIfneed];
}


// 下载进度回调
-(void)downloadingWithTotal:(long long)totalSize complete:(long long)finishSize speed:(NSString *)speed tag:(NSString *)tag{
    
    float prg = (float)finishSize/totalSize;
    
//    NSLog(@"收到回调通知：当前进度为:%f,tag:%@",prg,tag);
    
    NSString* finishStr = [XHTUIHelper formatByteCount:finishSize];
    NSString* totalStr = [XHTUIHelper formatByteCount:totalSize];
    NSString* percent = [NSString stringWithFormat:@"%@/%@",finishStr,totalStr];
    
    TableViewCell* cell = nil;
    TakoApp* app = nil;
    
    // 只遍历第二个section
    NSArray* cellList = [self.listData objectAtIndex:1];
    
    // 找到对应的cell
    for (int i=0; i< [cellList count]; i++) {
        app = (TakoApp*)[cellList objectAtIndex:i];
        if ([app.versionId isEqualToString:tag]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
            cell = [self.tableview cellForRowAtIndexPath:path];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新cell
        [cell.progressControl setProgress:prg];
        cell.textDownload.text = percent;
        cell.downloadSpeed.text = speed;
    });
    
    
    // 更新app
    app.currentlength = [XHTUIHelper stringWithLong:finishSize];;
    app.totallength = [XHTUIHelper stringWithLong:totalSize];;
    app.progress = percent;
    app.progressValue = prg;

}

// 重载数据
-(void)reloadViewData{
    
    // 加载 listData
    self.listData = [NSMutableArray new];
    NSMutableArray* downloadedList = [NSMutableArray new];
    NSMutableArray* downloadingList = [NSMutableArray new];
    self.sectionTitleArray = [NSMutableArray new];
    
    
    NSArray* appHisList = [[AppHisDao share] fetchAllApp];
    
    // 没有历史下载记录，返回。
    if (appHisList==nil) {
        self.sectionTitleArray = [[NSMutableArray alloc]initWithObjects:@"已完成(0)",@"下载中(0)",nil];
        [self.listData addObject:downloadedList];
        [self.listData addObject:downloadingList];
        return;
    }
    
    
    // 存在历史下载记录，归类
    for (AppHis* his in appHisList) {
//        NSLog(@"his is:%@",his);
        TakoApp* app = [TakoApp new];
        [app setValuesForKeysWithDictionary:[XHTUIHelper getObjectData:his]];
        
        if ([his.status intValue] == STARTED || [his.status intValue] == PAUSED) {
            [downloadingList addObject:app];
        }else if([his.status intValue] >= DOWNLOADED){
            [downloadedList addObject:app];
        }
    }
    
    [self.listData addObject:downloadedList];
    [self.listData addObject:downloadingList];
    
    
    // 设置section title
    NSString* title1 = [NSString stringWithFormat:@"已完成(%lu)",(unsigned long)[downloadedList count]];
    NSString* title2 = [NSString stringWithFormat:@"下载中(%lu)",(unsigned long)[downloadingList count]];
    [self.sectionTitleArray addObject:title1];
    [self.sectionTitleArray addObject:title2];
    
}

// 显示复选框
-(void)showCheckbox:(BOOL)isShow cell:(TableViewCell*)cell app:(TakoApp*)app{
    if (isShow) {
        NSString* imageName = app.isSelected?PNG_SELECTED:PNG_DESELECT;
        UIButton *checkboxButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 8, 25, 25)];
        [checkboxButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [checkboxButton addTarget:self action:@selector(clickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = checkboxButton;
        [cell.button setHidden:YES];
        [cell.coverButton setHidden:YES];// 隐藏按钮也hide
    }else{
        cell.accessoryView = nil;
        //        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.button setHidden:NO];
        [cell.coverButton setHidden:NO];// 隐藏按钮也show
    }
    
}

-(void)clickCheckBox:(id)sender{
    NSLog(@"button clicked...");
    UIButton* bt = (UIButton*)sender;
    
    TableViewCell* cell = (TableViewCell*)[bt superview];

  

    int section = (int)[self.tableview indexPathForCell:cell].section;
    int row = (int)[self.tableview indexPathForCell:cell].row;

    // fix: ios7.0 越狱 需要两层superView嵌套
    if ([[self.listData objectAtIndex:section] count]==0) {
        cell = (TableViewCell*)[(UIView*)[bt superview] superview];
        section = (int)[self.tableview indexPathForCell:cell].section;
        row = (int)[self.tableview indexPathForCell:cell].row;
    }
    
    TakoApp* currentApp = [[self.listData objectAtIndex:section] objectAtIndex:row];
    
    if (currentApp.isSelected) {
        [bt setImage:[UIImage imageNamed:PNG_DESELECT] forState:UIControlStateNormal];
    }else{
        [bt setImage:[UIImage imageNamed:PNG_SELECTED] forState:UIControlStateNormal];
    }
    currentApp.isSelected = !currentApp.isSelected;
}


// clear live object
- (void)dealloc
{
//    [[AppHisDao share] save];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// 优先展示下载状态的cell
-(void)sortByStatus{
    NSMutableArray* downloadinglist = [self.listData objectAtIndex:1];
    if ([downloadinglist count] == 0) {
        return;
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [downloadinglist sortUsingDescriptors:sortDescriptors];
    
    [self.listData replaceObjectAtIndex:1 withObject:downloadinglist];
    [self.tableview reloadData];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_DOWNLOAD];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_DOWNLOAD];

}

@end
