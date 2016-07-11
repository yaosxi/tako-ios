//
//  VersionViewController.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/10.
//  Copyright © 2015年 熊海涛. All rights reserved.
//

#import "VersionViewController.h"
#import "UIHelper.h"
#import "Constant.h"

@interface VersionViewController ()

@end

@implementation VersionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
   self.title = @"关于";
   NSString* versionid =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
   NSString* buildid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.version.text = [NSString stringWithFormat:@"Tako %@(build %@)",versionid,buildid];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction) gotoParentView:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [TalkingData trackPageBegin:DATA_PAGE_ABOUT];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TalkingData trackPageEnd:DATA_PAGE_ABOUT];
}


@end
