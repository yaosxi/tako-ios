//
//  LoginViewController.h
//  HelloTako
//
//  Created by 熊海涛 on 16/2/25.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTAutocompleteManager.h"
#import "HTAutocompleteTextField.h"

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *userNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *userPwd;
@property (weak, nonatomic) IBOutlet UIButton *loginBt;
@property (weak, nonatomic) IBOutlet UIButton *backBt;
@property (weak, nonatomic) IBOutlet UIImageView *emailLineimage;
@property (weak, nonatomic) IBOutlet UIImageView *passwordLineimage;

@end
