//
//  AppContentViewController.m
//  Tako
//
//  Created by 熊海涛 on 16/4/28.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "AppContentViewController.h"
#import "DeviceUtil.h"
#import "UIHelper.h"

@interface AppContentViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewButtomConstaint;

@end

@implementation AppContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.appDesc.editable = NO;
    self.appDesc.showsVerticalScrollIndicator = YES;
    self.appDesc.scrollEnabled = YES;
    self.appDesc.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    // 4s
    if(SCREEN_HEIGHT == 568.0f){
        self.textViewButtomConstaint.constant = 100;
    }
    // 5s
    else if(SCREEN_HEIGHT == 480.0f){
        self.textViewButtomConstaint.constant = 150;
    }
}


@end
