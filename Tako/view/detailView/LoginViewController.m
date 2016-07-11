//
//  LoginViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 16/2/25.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "LoginViewController.h"
#import "TestViewController.h"
#import "MineViewController.h"
#import "Constant.h"
#import "UIHelper.h"
#import "validation.h"
#import "Server.h"
#import "MBProgressHUD.h"


@interface LoginViewController ()<UITextFieldDelegate>{
    MBProgressHUD* hub;
    int errorCode;
    UITapGestureRecognizer* tapGesture;
}
@property (weak, nonatomic) IBOutlet UINavigationBar *navigateBar;

@property (weak, nonatomic) IBOutlet UILabel *errorMsg;

@property (copy,nonatomic) NSString* authUserName;
@property (weak, nonatomic) UIImageView *authUserIcon;

@end

@implementation LoginViewController

#pragma mark view生命周期

//-(void)Actiondo:(id)sender{
//    NSLog(@"hh");
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [XHTUIHelper addBorderonButton:self.loginBt cornerSize:8];
    [self.userNameTxt setDelegate:self];
    [self.userPwd setDelegate:self];
    self.userNameTxt.tag=0;
    self.userPwd.tag=1;
    self.userNameTxt.borderStyle = UITextBorderStyleNone;
    self.userPwd.borderStyle = UITextBorderStyleNone;
    self.userPwd .secureTextEntry = YES; // 掩码

    self.navigateBar.barTintColor = [XHTUIHelper navigateColor];

    self.errorMsg.text=@"";
    [self.errorMsg setHidden:YES];
    errorCode = LOGIN_OK;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    //将触摸事件添加到当前view,view消失时再remove掉
    [self.view addGestureRecognizer:tapGesture];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:nil];

    
    [XHTUIHelper addRightViewforText:self.userNameTxt image:@"ic_mail.png"];
    [XHTUIHelper addRightViewforText:self.userPwd image:@"ic_pwd.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark view的其他私有方法

-(IBAction) signin:(id)sender{
    
    [self keyboardHide];
    // 删除原来的用户信息
    [XHTUIHelper removeLoginCookie];
    
    [self.errorMsg setHidden:YES];
    
    if(self.loginBt.selected) return;
    
    self.loginBt.selected = YES;
    
    NSString *userAccount = self.userNameTxt.text;
    NSString *password = self.userPwd.text;
    
    // kingsoft邮箱无需后缀
    if (![XHTUIHelper isString:userAccount ContainsString:@"@"]) {
         userAccount = [NSString stringWithFormat:@"%@@kingsoft.com",userAccount];
    }
    
    // 输入校验
    XHtValidation *validate=[[XHtValidation alloc] init];
    [validate Required:userAccount FieldName:@"账号:"];
    if(![validate isValid] || [userAccount isEqualToString:@"@kingsoft.com"]){
        [self authFinish];
        [self.emailLineimage setBackgroundColor:[UIColor redColor]];
        [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        self.errorMsg.text = @"请输入邮箱地址";
        [self.errorMsg setHidden:NO];
        errorCode=ACCOUNT_EMPTY;
        return;
    }
    [validate Email:userAccount FieldName:@"账号:"];
    if(![validate isValid]){
        [self authFinish];
        self.errorMsg.text = @"邮箱地址不合法";
        [self.emailLineimage setBackgroundColor:[UIColor redColor]];
        [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        [self.errorMsg setHidden:NO];
        errorCode=ACCOUNT_ILLEGAL;
        return;
    }
    [validate Required:password FieldName:@"密码:"];
    if(![validate isValid]){
        [self authFinish];
        [self.passwordLineimage setBackgroundColor:[UIColor redColor]];
        [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        self.errorMsg.text = @"请输入密码";
        [self.errorMsg setHidden:NO];
        errorCode=PASSWORD_EMPTY;
        return;
    }
    [validate MaxLength:50 textField:password FieldName:@"密码:"];
    if(![validate isValid]){
        [self authFinish];
        [self.passwordLineimage setBackgroundColor:[UIColor redColor]];
        [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        self.errorMsg.text = @"密码长度不能超过50";
        [self.errorMsg setHidden:NO];
        errorCode=PASSWORD_ILLEGAL;
        return;
    }
    
   
    [self showIndicator];
    
    if (![XHTUIHelper isConnectionAvailable]){
        [XHTUIHelper tipNoNetwork];
        [self authFinish];
        return;
    }
    
    // note: ios8 this should be "QOS_CLASS_USER_INTERACTIVE"
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        int authResult = [self authwithUserName:userAccount password:password];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(authResult == LOGIN_OK){
                NSLog(@"登陆成功。");
                errorCode=LOGIN_OK;
                [self.errorMsg setHidden:YES];
                // 记录用户信息
                [XHTUIHelper writeNSUserDefaultsWithKey:USER_ACCOUNT_KEY withValue:userAccount];
                [XHTUIHelper writeNSUserDefaultsWithKey:USER_NAME_KEY withValue:self.authUserName];
                [XHTUIHelper writeNSUserDefaultsWithKey:LOGIN_KEY withValue:LOGIN_SUCCESS_KEY];
                [XHTUIHelper addNewAccount:userAccount];
                
                if ([XHTUIHelper isAppLoadBefore]) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self presentViewController:[XHTUIHelper initTabbar] animated:YES completion:nil];
                }
                
            }else if(authResult == ACCOUNT_ILLEGAL ){
                NSLog(@"登陆失败。");
                [self authFinish];
                [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
                [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
                self.errorMsg.text = @"账号或密码错误";
                [self.errorMsg setHidden:NO];
                errorCode=AUTH_FAILED;
            }else{
                [self authFinish];
                self.errorMsg.text = @"";//其他错误，网络异常
            }

        });
        
    });
   }



- (void)authFinish{
//    [self.activityIndicator stopAnimating];
    [hub hideAnimated:YES];
    self.loginBt.selected = NO;
    self.loginBt.backgroundColor = [UIColor clearColor];
}


-(int)authwithUserName:(NSString*)userName password:(NSString*)password{
    TakoUser* user = [TakoServer authEmail:userName password:password];
    
    // 登陆异常
    if (user==nil|| [user.retCode isEqualToString:@"-99"]) {
        return ACCOUNT_ILLEGAL;
    }else if ([user.retCode isEqualToString:@"-1"]){
        return NETWORK_ERROR;
    }
    
    // 登陆成功
    self.authUserName=user.nickName;
    [XHTUIHelper writeNSUserDefaultsWithKey:USER_ID_KEY withObject:user.userId];
//    [XHTUIHelper writeNSUserDefaultsWithKey:USER_TOKEN_KEY withObject:user.userToken];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSLog(@"before login....");
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }
    [XHTUIHelper saveLoginCookie];
    [XHTUIHelper updateLoginCookie];
    
    cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSLog(@"after login....");
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }
    self.authUserIcon=nil;
    return LOGIN_OK;
}

-(void)showIndicator{
    self.loginBt.selected = YES;
    self.loginBt.backgroundColor = [XHTUIHelper systemColor];
    hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(IBAction) signup:(id)sender{
    NSLog(@"will do register...");
}


#pragma mark textField回调

// 当输入框获得焦点时，改变下拉框演示。
- (void)textFieldDidBeginEditing:(UITextField *)textField{
   
    if (textField.tag == 0) {
        [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        [self.passwordLineimage setBackgroundColor:[UIColor grayColor]];
    }else if (textField.tag == 1) {
        [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
        [self.emailLineimage setBackgroundColor:[UIColor grayColor]];
    }
}

// 实时校验输入
- (void)textFieldChanged:(UITextField*) field{
    
    if (errorCode==ACCOUNT_EMPTY && ![self.userNameTxt.text isEqualToString:@""]) {
        self.errorMsg.text=@"";
        [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
    }
    else if (errorCode==PASSWORD_EMPTY && ![self.userPwd.text isEqualToString:@""]) {
        self.errorMsg.text=@"";
        [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
    }
    else if ( (errorCode==ACCOUNT_ILLEGAL)&&[self.userNameTxt.text isEqualToString:@""] ) {
        self.errorMsg.text=@"";
        [self.emailLineimage setBackgroundColor:[XHTUIHelper systemColor]];
    }
    else if ((errorCode==PASSWORD_ILLEGAL)&&[self.userPwd.text isEqualToString:@""]){
        self.errorMsg.text=@"";
        [self.passwordLineimage setBackgroundColor:[XHTUIHelper systemColor]];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_LOGIN];
}

-(void)keyboardHide{
    [self.userPwd resignFirstResponder];
    [self.userNameTxt resignFirstResponder];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_LOGIN];
    [self.view removeGestureRecognizer:tapGesture];
}


@end
