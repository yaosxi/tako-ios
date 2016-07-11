//
//  ConfigViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/27.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "ConfigViewController.h"
#import "UIHelper.h"
#import "Constant.h"

@interface ConfigViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray* sectionTitleArray;
    NSArray* listData;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    listData = [NSArray arrayWithObjects:@"文件校验", nil];
    
    // 设置分割线的颜色为浅灰色
    self.tableView.separatorColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:1];
    // 隐藏tableview中多余的单元格线条
    [XHTUIHelper setExtraCellLineHidden:self.tableView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    // 系统原生的cell
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.accessoryType =UITableViewCellAccessoryNone;
        cell.imageView.frame = CGRectMake(0,0,20,20);
        cell.imageView.image = [UIImage imageNamed:@"ic_verify"];
        cell.textLabel.text =  [listData objectAtIndex:indexPath.row];
        UISwitch *switchControl = [[UISwitch alloc]initWithFrame:CGRectMake(0, 8, 25, 20)];
        [switchControl addTarget:self action:@selector(swValueChanged:) forControlEvents:UIControlEventValueChanged];
        [switchControl setOn:![XHTUIHelper isMd5Closed]];
        cell.accessoryView = switchControl;
    }
    
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 强制cell分割线左移
    [XHTUIHelper forceCellToLeft:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return  listData.count;
}

-(void)swValueChanged:(UISwitch*) sender{
    NSLog(@"new switch value...");
    if (sender.isOn) {
        [XHTUIHelper writeNSUserDefaultsWithKey:IS_MD5_OPEN withObject:@"1"];
        NSLog(@"on");
    }else{
        [XHTUIHelper writeNSUserDefaultsWithKey:IS_MD5_OPEN withObject:@"0"];
        NSLog(@"off");}
}

@end
