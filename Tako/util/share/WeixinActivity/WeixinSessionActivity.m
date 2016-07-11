

#import "WeixinSessionActivity.h"

@implementation WeixinSessionActivity

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"icon_session-8.png"] : [UIImage imageNamed:@"icon_session.png"];
}

// 设置底部标题
- (NSString *)activityTitle
{
    return NSLocalizedString(@"微信聊天", nil);
}

@end
