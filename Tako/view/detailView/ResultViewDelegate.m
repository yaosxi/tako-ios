//
//  ResultViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/7.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "ResultViewDelegate.h"
#import "UIHelper.h"
#import "TableViewCell.h"
#import "App.h"
#import "UIImageView+WebCache.h"

@interface ResultViewDelegate()

@end

@implementation ResultViewDelegate


#pragma mark tableview的delegate

/*cell高度*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 80;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.resultList count];
}



// 点击单元格，可显示扩展按钮。暂时关闭该页面。如需激活该方法，需要修改cell中设置。
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    NSLog(@"clicked index is:%@",indexPath);
    
    // 清空原来的数据显示新数据
//    [self showSearchResult];
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 强制cell分割线左移
    [XHTUIHelper forceCellToLeft:cell];
    
    
    // 数据绑定
    TakoApp* app = (TakoApp*)[self.resultList objectAtIndex:indexPath.row];
    // [cell.button setHidden:NO];
    cell.appName.text=app.appname;
    cell.appVersion.text = app.versionname;
    cell.otherInfo.text = [NSString stringWithFormat:@"%@  %@",app.releasetime,app.size];
    
    [cell.appImage sd_setImageWithURL:[NSURL URLWithString:app.logourl]
                     placeholderImage:[UIImage imageNamed:@"ic_defaultapp"]];

    // todo : 根据下载状态，修改cell的样式
    
    
//    [super updateApp:app cell:cell status:app.status];
//    [super updateProgress:app cell:cell];
    
//    // 标记当前cell
//    cell.tag = CELL_FOR_TEST_PAGE_KEY;
    
    return cell;
    
}


@end
