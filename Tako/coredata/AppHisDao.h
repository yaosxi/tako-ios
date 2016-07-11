
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AppHis+CoreDataProperties.h"
#import "App.h"

// 当前db方式：coredata

@interface AppHisDao : NSObject

// 单例
+(AppHisDao*) share;

// apphis中为nil或为0的字段，不更新
-(BOOL)updateApp:(TakoApp*)apphis;

// apphis中为nil的字段，不插入
-(BOOL)createApp:(TakoApp*)apphis;

// 返回一个app
//-(AppHis*)fetchAppWithAppId:(NSString*)appid;

// 返回一个app,按versionId查询
-(AppHis*)fetchAppWithVersionId:(NSString*)versionId;

// 返回最近一次下载的app
-(AppHis*)fetchLatestAppWithAppId:(NSString*)appid;

// 返回所有app
-(NSArray*)fetchAllApp;

// 删除一个app
-(void)removeAppWithVersionId:(NSString*)versionId;

// 删除所有app
-(void)removeAllApp;

// 强制保存
-(void)save;

@end

/*例：
// 删除所有
[[AppHisDao share] removeAllApp];

// 插入
TakoApp* appHis = [TakoApp new];
appHis.appid = @"123";
appHis.appname = @"app123";
appHis.downloadPassword = @"12345";
[[AppHisDao share] createApp:appHis];
NSLog(@"app create finish");


// 查询
AppHis* appHis2 = [[AppHisDao share] fetchAppWithAppId:appHis.appid];
NSLog(@"fetch finish...appid is:%@,appname is:%@",appHis2.appid,appHis2.appname);
NSLog(@"app is:%@",appHis2);

// 更新
TakoApp* appHis3 = [TakoApp new];
appHis3.appid = @"123";
appHis3.appname = @"456";
[[AppHisDao share] updateApp:appHis3];
NSLog(@"app update finish");

// 再查下
AppHis* appHis4 = [[AppHisDao share] fetchAppWithAppId:appHis3.appid];
NSLog(@"fetch finish...appid is:%@,appname is:%@",appHis4.appid,appHis4.appname);
NSLog(@"app is:%@",appHis4);
*/