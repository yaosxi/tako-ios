
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 下载回调协议
@protocol XHtDownLoadDelegate <NSObject>

-(void)downloadingWithTotal:(long long)totalSize complete:(long long)finishSize speed:(NSString*)speed tag:(NSString*)tag;
-(void)downloadFinish:(BOOL)isSuccess msg:(NSString*)msg tag:(NSString*)tag;

@end



@interface DownloadWorker : NSObject

@property (nonatomic) BOOL isFree;

// 请求标示，即versionid
@property (nonatomic, copy) NSString  *tag;

@property (nonatomic, copy) NSString  *versionid;

@property (nonatomic, copy) NSString  *versionname;

@property (nonatomic, copy) NSString  *password;

@property(nonatomic, strong)id<XHtDownLoadDelegate> delegate;


- (void)startWithUrl:(NSURL*) url versionid:(NSString*)versionid tag:(NSString*)tag delegate:(id<XHtDownLoadDelegate>)delegate ;

// 暂停
- (void)pause:(NSString*)tag;

// 停止（下次将重新下载）
- (void)stop:(NSString*)tag;

@end

