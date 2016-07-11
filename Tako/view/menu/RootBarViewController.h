//
//  RootNavigateViewController.h
//  Tako
//
//  Created by 熊海涛 on 16/4/1.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface RootTabBarController : UITabBarController

@property(nonatomic,strong) REFrostedViewController* reVC;

- (void)showMenu;

@end
