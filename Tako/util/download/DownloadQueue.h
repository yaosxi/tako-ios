
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DownloadWorker.h"
#import "Constant.h"


@interface XHtDownLoadQueue : NSObject<XHtDownLoadDelegate>

+ (instancetype)share;

/* （为支持多view同步更新，delegate暂时禁用，请监听以下事件来获取进度
 #define XHT_DOWNLOAD_PROGERSS_NOTIFICATION
 #define XHT_DOWNLOAD_FINISH_NOTIFICATION
*/
- (void)add:(NSString*)url versionid:(NSString*)versionid tag:(NSString*)tag delegate:(id<XHtDownLoadDelegate>)delegate;

// 暂停所有线程
-(void)pauseAll;

// 暂停
- (void)pause:(NSString*)tag ;

// 停止（下次将从0开始下载）
- (void)stop:(NSString*)tag ;

@end

