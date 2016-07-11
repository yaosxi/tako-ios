

#import <UIKit/UIKit.h>
#import "WXApi.h"


// 基类：供微信聊天和微信朋友圈activity调用

@interface WeixinActivityBase : UIActivity {
    NSString *title;
    UIImage *image;
    NSURL *url;
    enum WXScene scene;
}

- (void)setThumbImage:(SendMessageToWXReq *)req;

@end
