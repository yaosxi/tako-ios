//
//  ThirdViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/9.
//  Copyright © 2015年 熊海涛. All rights reserved.
//


#import "MineViewController.h"
#import "VersionViewController.h"
#import "LoginViewController.h"
#import "DownloadViewController.h"
#import "TestViewController.h"
#import "UIHelper.h"
#import "Constant.h"
#import "DownloadQueue.h"
#import "ConfigViewController.h"
#import "Server.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray* iconArray;
    NSArray* sectionTitleArray;
    NSArray* sectionTextArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;

@end


@implementation MineViewController

#pragma mark view生命周期

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([XHTUIHelper isLogined]) {
        self.userImage.image = [UIImage imageNamed:@"ic_user_head_logged"];
        self.userName.text = [XHTUIHelper readNSUserDefaultsObjectWithkey:USER_NAME_KEY];
        self.userAccount.text = [XHTUIHelper readNSUserDefaultsObjectWithkey:USER_ACCOUNT_KEY];
    }else{
        self.userImage.image = [UIImage imageNamed:@"ic_user_head_unlogged"];
        self.userName.text = @"";
        self.userAccount.text =@"";
    }
}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [XHTUIHelper formatNavigateColor:self.navigationController.navigationBar];// 将导航栏设置为蓝色
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];// 默认为蓝色，此处更改为白色以适应标题栏颜色。
    
    // 设置分割线的颜色为浅灰色
    self.tableView.separatorColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:1];
    
    self.tableView.scrollEnabled = NO;

//    [self addTabBarswipeGesture]; // 手势切换和menu的重复了，暂时屏蔽改功能
    
    // 强制tableview左移动
    [XHTUIHelper forceTableViewToLeft:self.tableView];
    
    self.title = @"我的";
    
    // 不允许和navigation的距离做自适应，参考：https://segmentfault.com/q/1010000000319086
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 隐藏tableview中多余的单元格线条
    [XHTUIHelper setExtraCellLineHidden:self.tableView];
    
    // 增加导航栏的下载管理页面入口
    UIButton* button = [XHTUIHelper navButtonWithImage:@"download"];
    [button addTarget:self action:@selector(showDownloadManageView)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
    
    // 初始化数据源
    sectionTitleArray = [NSArray arrayWithObjects:@"",nil];
    sectionTextArray =[NSArray arrayWithObjects:[NSArray arrayWithObjects:@"关于Tako",@"下载管理",@"设置",@"版本更新",@"退出登录",nil],nil];
    iconArray = [NSArray arrayWithObjects:@"ic_about",@"ic_dl",@"ic_config",@"ic_upgrade",@"ic_logout",nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLoginView:) name:SESSION_ILLEGAL_NOTIFICATION object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableview的delegate

//section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitleArray objectAtIndex:section];
}


// 改变行的高度,todo: 为何自定义的cell本身未生效？
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

// section数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionTitleArray count];
}

// section中的cell数目
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[sectionTextArray objectAtIndex:section] count];
}

// 加载单元格
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 系统原生的cell
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 3 || indexPath.row == 4) {
        cell.accessoryType =UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 4) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    cell.imageView.frame = CGRectMake(0,0,20,20);
    cell.imageView.image = [UIImage imageNamed:[iconArray objectAtIndex:indexPath.row]];
    cell.textLabel.text =sectionTextArray[indexPath.section][indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 强制cell分割线左移
    [XHTUIHelper forceCellToLeft:cell];
    
    
    return cell;
}

//// 单击一次即可，不允许deselect
//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPat{
////    [self tableView:tableView didSelectRowAtIndexPath:indexPat];// 相当于disable双击
//}



// 单元格选中时
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];

    
    if(indexPath.section==0 && indexPath.row==0){
        NSLog(@"即将进入“关于Tako”页面...");
        UIViewController* versionView = [[VersionViewController alloc] init];
        [self.navigationController pushViewController:versionView animated:YES];
        
    }
    
    else if(indexPath.section==0 && indexPath.row==1){
        NSLog(@"即将进入“下载管理”页面...");
        UIViewController* downloadView = [[DownloadViewController alloc] init];
        [self.navigationController pushViewController:downloadView animated:YES];
    }
    else if(indexPath.section==0 && indexPath.row==2){
        NSLog(@"即将进入“设置”页面...");
        [self.navigationController pushViewController:[ConfigViewController new] animated:YES];
    }
    else if(indexPath.section==0 && indexPath.row==3){
        BOOL isNetworkok = [XHTUIHelper isConnectionAvailable];
        if (!isNetworkok) {
            [XHTUIHelper tipNoNetwork];
            return;
        }
        
        int retCode = [TakoServer isNewVersion];
        if (retCode == 1) {
            NSLog(@"即将进入“版本更新”页面...");
            NSURL* url = [NSURL URLWithString:[XHTUIHelper takoAppUrl]];
            [TalkingData trackPageBegin:DATA_PAGE_UPGRADE];
            [[UIApplication sharedApplication] openURL:url];
            [TalkingData trackPageEnd:DATA_PAGE_UPGRADE];
        }else if(retCode==0){
            if (isNetworkok) {
             [XHTUIHelper alertWithNoChoice:@"当前已经是最新版本~" view:self];
            }
        }
    }
    else if(indexPath.section==0 && indexPath.row==4){
        NSLog(@"即将进入“退出登录”页面...");
        if (![XHTUIHelper isLogined]) {
            [XHTUIHelper alertWithNoChoice:@"您已登出." view:self];
            return;
        }
        
        if (IOS_VERSION>=8.0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认要退出登录？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"登出成功...");
                [self confirmLogout];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更UI
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }else{
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认要退出登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
       
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}



- (void)dealloc
{
//    [[AppHisDao share] save];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)showDownloadManageView{
    NSLog(@"will go to download manage page");
    [self.navigationController pushViewController:[[DownloadViewController alloc] init] animated:NO];
}

#pragma mark view的其他私有方法

// Method disabled: 暂时不允许返回。必须登录。
-(IBAction) gotoLoginView:(id)sender{
    [self presentViewController:[LoginViewController new] animated:YES completion:^{
        NSLog(@"enter login view");
    }];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_MINE];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_MINE];
}

#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self confirmLogout];
    }
}

-(void)confirmLogout{
    self.userName.text=@"";
    self.userAccount.text=@"";
    self.userImage.image = [UIImage imageNamed:@"ic_user_head_unlogged"];
    
    // 更新用户信息
    [XHTUIHelper writeNSUserDefaultsWithKey:LOGIN_KEY withObject:LOGIN_FAILED_KEY];
    [XHTUIHelper removeLoginCookie];
    
    // 删除cookie,删除原来testview中的账户的数据。
    // 发送事件
    NSNotification *notification =[NSNotification notificationWithName:USER_LOGOUT_NOTIFICATION object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    // 暂停所有任务
    [[XHtDownLoadQueue share] pauseAll];
    
    [self gotoLoginView:nil];
}
@end