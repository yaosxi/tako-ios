

#import "WeixinActivityBase.h"

@implementation WeixinActivityBase

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // 需要安装微信
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"Warning!!!  wechat app have not been installed,can not perform share activity...");
        return NO;
    }
    
    // 需要支持wechat Api
    if (![WXApi isWXAppSupportApi]) {
        NSLog(@"Warning!!!  wechat api is not supported ,can not perform share activity...");
        return NO;
    }
    
    // 支持文本，图片，url链接
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class] ] || [activityItem isKindOfClass:[NSURL class]] || [activityItem isKindOfClass:[NSString class]]) {
            continue;
        }else{
            NSLog(@"Warning!!! no valid items found , can not perform share activity");
            return NO;
        }
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
    }
}

- (void)setThumbImage:(SendMessageToWXReq *)req
{
    if (image) {
        CGFloat width = 100.0f;
        CGFloat height = image.size.height * 100.0f / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [req.message setThumbImage:scaledImage];
    }
}

- (void)performActivity
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene;
//    req.bText = NO;
    req.message = WXMediaMessage.message;
    if (scene == WXSceneSession) {
        req.message.title = @"Tako";
        req.message.description = title;
    } else {
        req.message.title = title;
    }
    [self setThumbImage:req];
    if (url) {
        WXWebpageObject *webObject = WXWebpageObject.object;
        webObject.webpageUrl = [url absoluteString];
        req.message.mediaObject = webObject;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        req.message.mediaObject = imageObject;
    }
    [WXApi sendReq:req];
    [self activityDidFinish:YES];
}

@end
