
#import "WeixinTimelineActivity.h"

@implementation WeixinTimelineActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = WXSceneTimeline;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [[[UIDevice currentDevice] systemVersion] intValue] >= 8 ? [UIImage imageNamed:@"icon_timeline-8.png"] : [UIImage imageNamed:@"icon_timeline.png"];
}

// 设置底部标题
- (NSString *)activityTitle
{
    return NSLocalizedString(@"微信朋友圈", nil);
}


@end
