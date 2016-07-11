//
//  MyMenuViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/4.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "MyMenuViewController.h"
#import "DownloadViewController.h"

@interface MyMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation MyMenuViewController


// 隐藏导航栏，是logo图片铺满
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 背景色，全透明
    self.headerView.backgroundColor  = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.footerView.backgroundColor  = [UIColor clearColor];
    
//    self.headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];

    
    
    // 修改back按钮的标题
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style :UIBarButtonItemStyleBordered target:nil action: nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


-(void)showSttting{
    NSLog(@"will show setting view");
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* identifier = @"UITableViewCell" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;// 禁止选中时高亮

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"菜单%ld",(long)indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:[[DownloadViewController alloc] init] animated:YES];
}

@end
