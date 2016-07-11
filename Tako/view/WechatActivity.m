//
//  WechatActivity.m
//  Tako
//
//  Created by 熊海涛 on 16/3/30.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "WechatActivity.h"

@implementation WechatActivity

NSString *const UIActivityTypeZSCustomMine = @"ZSCustomActivityMine";

- (NSString *)activityType
{
    return UIActivityTypeZSCustomMine;
}

- (NSString *)activityTitle
{
    //国际化
    return NSLocalizedString(@"微信", @"");
}

- (nullable UIImage *)activityImage{
    return [UIImage imageNamed:@"logo.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    return YES;
}

+ (UIActivityCategory)activityCategory{
    return UIActivityCategoryShare;
}

- (void)performActivity{
[[UIApplication sharedApplication] openURL:<#(nonnull NSURL *)#>]
}
@end
