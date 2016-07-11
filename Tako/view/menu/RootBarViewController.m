//
//  RootNavigateViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/1.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "RootBarViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"

@interface UITabBarController ()

//@property (strong, readwrite, nonatomic) MenuTableViewController *menuViewController;

@end

@implementation RootTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)showMenu
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.reVC.view endEditing:YES];
    
    // Present the view controller
    //
    [self.reVC presentMenuViewController];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.reVC.view endEditing:YES];
    
    // Present the view controller
    //
    [self.reVC panGestureRecognized:sender];
}

@end
