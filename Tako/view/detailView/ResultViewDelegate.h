//
//  ResultViewController.h
//  Tako
//
//  Created by 熊海涛 on 16/4/7.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewDelegate : NSObject  <UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic)    UITableView* tableView;
@property (strong,nonatomic) NSMutableArray* resultList;
@end
