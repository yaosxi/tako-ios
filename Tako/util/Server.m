//
//  UIHelper.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/11.
//  Copyright © 2015年 熊海涛. All rights reserved.
//


#import "Server.h"
#import "App.h"
#import "Constant.h"
#import "UIHelper.h"
#import "MBProgressHUD.h"
#import "AppVersion.h"
#import "TalkingData.h"
#import "DataEvent.h"

#define LOGIN_EMAIL_KEY @"email"
#define LOGIN_PASSWORD_KEY @"password"
#define COMMON_RET_KEY @"ret"
#define COMMON_DATA_KEY @"data"
#define LOGIN_USERID_KEY @"userid"
#define LOGIN_USERTOKEN_KEY @"token"
#define LOGIN_USERNICKNAME_KEY @"nickname"

@implementation TakoServer

+(BOOL)isValidLogin{
    BOOL result = YES;
    NSString* url = nil;
    
    url = [NSString stringWithFormat:@"/checklogin"];
    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSLog(@"before login....");
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        NSLog(@"%@", cookie);
//    }
//    
    NSData* returnData = [self postWithDict:nil url:url];
    if (returnData==nil) {
        return result;
    }
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! http error...");
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    result = [resultCode longValue] == 0;
    if (!result) {
        NSLog(@"token过期。");
        [XHTUIHelper removeLoginCookie];// 删除已过期的cookie
    }
    return result;
}

+(int)isNewVersion{
    NSString* oldbuildid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //oldbuildid = @"800";
    TakoVersion* version = [TakoServer fetchVersion];
    if (version.buildNumber==nil) {
        return 500;
    }
    NSLog(@"old build id is:%@,new build id is:%@",oldbuildid,version.buildNumber);
    if ([oldbuildid intValue]<[version.buildNumber intValue]) {
        if (version.forceUpgrade == YES) {
            NSLog(@"发现新版本，将提示用户更新...强制更新");
            return 2;
        } else {
            NSLog(@"发现新版本，将提示用户更新...");
            return 1;
        }
    }
    
    return 0;
}

+(NSMutableArray*)searchApp:(NSString*) searchText{
    return nil;
}

+(TakoVersion*)fetchVersion{
    TakoVersion* version = [TakoVersion new];
    NSString*  url = @"/tako/upgrade/latest?platform=1";
    [self getWithUrl:url];
    NSData* returnData = [self getWithUrl:url];
    if (returnData==nil) {
        DDLogError(@"error!!! fetch http error...");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_NAME label:DATA_TAG_FAILED];
        return nil;
    }
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! fetch version error...");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_NAME label:DATA_TAG_FAILED];
        return nil;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] == 0) {
        NSLog(@"fetch version success....");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_NAME label:DATA_TAG_SUCCESS];
        NSDictionary* data = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
        version.forceUpgrade = [[data objectForKey:@"forceupgrade"] boolValue];
        NSDictionary* package =[data objectForKey:@"package"];
        NSString* versionName = [package objectForKey:@"version"];
        NSString* buildNumber = [package objectForKey:@"buildnumber"];
        version.versionName = versionName;
        version.buildNumber = buildNumber;
    }
    
    return version;
}

+(NSMutableArray*)fetchAppVersions:(NSString*)appid cursor:(NSString*)cursor{
    NSMutableArray* result = [NSMutableArray new];
    
    NSString* url = [NSString stringWithFormat:@"/getappversions?appid=%@&cursor=%@&count=%@&pid=%@",appid,cursor,TAKO_SERVER_VERSION_FETCH_SIZE,@"1"];
    NSData* returnData = [self getWithUrl:url];
    if (returnData==nil) {
        return result;
    }
    
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);// 量太大,暂时不log
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!!  apps fetch error...");
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] == 0) {
        NSLog(@"fetch success....");
        NSDictionary* dataDict = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
        
        NSArray* appVersions = [dataDict objectForKey:@"appversions"];
        if ([appVersions isKindOfClass:[NSNull class]]) {
            NSLog(@"no new data...");
            return result;
        }
        for (int i=0; i<[appVersions count]; i++) {
            NSDictionary* temp = (NSDictionary*)[appVersions objectAtIndex:i];
            TakoAppVersion* app =  [[TakoAppVersion new] initWithDictionary:temp];
            [result addObject:app];
        }
    }
    
    return result;
}



+(NSString*)fetchItermUrl:(NSString*)versionId password:(NSString*)password {
    
    NSString* result = nil;
    NSMutableDictionary* paramDict = [NSMutableDictionary new];
    [paramDict setObject:versionId forKey:@"id"];
    [paramDict setObject:@"true" forKey:@"local"];
    
    if (password!=nil && ![password isEqualToString:@"-1"]) {
        [paramDict setObject:password forKey:@"password"];
    }
    
    NSData* returnData = [self postFormDataWithDict:paramDict url:@"/app/version/url"];
    
    if (returnData==nil) {
        [TalkingData trackEvent:DATA_EVENT_GET_ITERM_URL label:DATA_TAG_FAILED];
        return result;
    }
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! fetch iterm url error...");
        [TalkingData trackEvent:DATA_EVENT_GET_ITERM_URL label:DATA_TAG_FAILED];
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] == 0) {
        NSLog(@"fetch iterm url success....");
        [TalkingData trackEvent:DATA_EVENT_GET_ITERM_URL label:DATA_TAG_SUCCESS];
        result = (NSString*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
    }
    
    return result;
    
}


+(TakoApp*)fetchAppPasswordInfo:(NSString*)appid{
    NSString* url = [NSString stringWithFormat:@"/app/%@",appid];
    TakoApp* result = nil;
    NSData* returnData = [self getWithUrl:url];
    if (returnData==nil) {
        return result;
    }
    
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! app info fetch error...");
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] == 0) {
        NSLog(@"fetch success....");
        NSDictionary* dataDict = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
        
        NSDictionary* appDict = [dataDict objectForKey:@"app"];
        NSString* password = [appDict objectForKey:@"password"];
        
        result =[TakoApp new];
        if ([password isEqualToString:@""]) {
            result.password=@"false";
        }else{
            result.password=@"true";
        }
    }
    return result;
}

+(TakoApp*)fetchAppWithid:(NSString*)appid{
    NSString* url = [NSString stringWithFormat:@"/app/%@",appid];
    TakoApp* result = nil;
    NSData* returnData = [self getWithUrl:url];
    if (returnData==nil) {
        return result;
    }
    
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! app info fetch error...");
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] == 0) {
        NSLog(@"fetch success....");
        NSDictionary* dataDict = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
        
        NSDictionary* appDict = [dataDict objectForKey:@"app"];
        result =  [[TakoApp new] initWithDictionary:appDict];
    }
    return result;
}

+(NSMutableArray*)fetchApp:(NSString*)cursor{
    
    NSMutableArray* result = [NSMutableArray new];
    
    NSString* url = [NSString stringWithFormat:@"/gettaskapps?cursor=%@&count=%@&pid=%@",cursor,TAKO_SERVER_APP_FETCH_SIZE,@"1"];
    NSData* returnData = [self getWithUrl:url];
    if (returnData==nil) {
        [TalkingData trackEvent:DATA_EVENT_GET_APP_LIST label:DATA_TAG_FAILED];
        return result;
    }
    
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"http response is ...%@",retjson);// 量太大,暂时不log
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!!  apps fetch error...");
        [TalkingData trackEvent:DATA_EVENT_GET_APP_LIST label:DATA_TAG_FAILED];
        return result;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    
//    // 用户过期，需重新登录。
//    if ([resultCode longValue] == 24) {
//        NSLog(@"login token expired , need login again...");
//        TakoApp* inValidApp = [TakoApp new];
//        inValidApp.appid = LOGIN_INVALID_KEY;
//        [result addObject:inValidApp];
//        return result;
//    }
     if ([resultCode longValue] == 0) {
        NSLog(@"fetch success....");
        [TalkingData trackEvent:DATA_EVENT_GET_APP_LIST label:DATA_TAG_SUCCESS];
        NSDictionary* dataDict = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
        
        NSArray* apps = [dataDict objectForKey:@"apps"];
        for (int i=0; i<[apps count]; i++) {
            NSDictionary* temp = (NSDictionary*)[apps objectAtIndex:i];
            TakoApp* app =  [[TakoApp new] initWithDictionary:temp];
            [result addObject:app];
        }
    }
    return result;
}



+(NSString*)fetchDownloadUrl:(NSString*)versionId password:(NSString*)password{
    NSString* result=nil;
    NSData* response=nil;
    
    NSMutableDictionary* paramDict = [NSMutableDictionary new];
    
    if (password==nil || [password isEqualToString:@"-1"]) {
        NSLog(@"无需下载密码。");
        
        [paramDict setObject:versionId forKey:@"id"];
        response= [self postFormDataWithDict:paramDict url:@"/app/version/download/url"];
    }else{
        NSLog(@"需要下载密码。");
        
        [paramDict setObject:versionId forKey:@"id"];
        [paramDict setObject:password forKey:@"password"];
        response= [self postFormDataWithDict:paramDict url:@"/app/version/download/url"];
    }
    
    NSLog(@"param is:%@",paramDict);
    // 处理http结果
    if(response == nil){
        DDLogError(@"error!!!  downloadurl fetch error...");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_URL label:DATA_TAG_FAILED];
        return HTTP_CODE_REPONSE_NULL;
    }
    
    NSString* retjson = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"http error...");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_URL label:DATA_TAG_FAILED];
        return HTTP_CODE_REPONSE_NULL;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if([resultCode longLongValue]!=0){
        NSLog(@"http failed...");
        [TalkingData trackEvent:DATA_EVENT_GET_VERSION_URL label:DATA_TAG_FAILED];
        return HTTP_CODE_WRONG_PASSWORD;
    }
    result = (NSString*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
    if ([resultCode longLongValue]==0 && [result isEqualToString:@""]) {
        return HTTP_CODE_WRONG_NETWORK;
    }
    [TalkingData trackEvent:DATA_EVENT_GET_VERSION_URL label:DATA_TAG_SUCCESS];
    return result;
}

// 模拟数据
+(NSMutableArray*)mockApps{
    NSMutableArray* result = [NSMutableArray new];
    for (int i=0;i<5;i++) {
        TakoApp* app = [TakoApp new];
        app.appname=[NSString stringWithFormat:@"app%d",i+1];
        app.versionname=[NSString stringWithFormat:@"%d.%d.%d",i+1,i+1,i+1];
        app.releasetime=@"2015-11-09";
        app.appid=[NSString stringWithFormat:@"appid%d",i];
        [result addObject:app];
    }
    return result;
}

+(TakoUser*)authEmail:(NSString*)email password:(NSString*)password{

    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:email forKey:LOGIN_EMAIL_KEY];
    [dict setObject:password forKey:LOGIN_PASSWORD_KEY];
    NSData* retData = [self postWithDict:dict url:@"/login"];
    
    // 解析结果
    if(retData == nil){
        DDLogError(@"http error...");
        [TalkingData trackEvent:DATA_EVENT_VERIFY_EMAIL label:DATA_TAG_FAILED];
        TakoUser* user = [TakoUser new];
        user.retCode = @"-1";
        return user;
    }else{
        NSString* retjson = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
//        NSLog(@"http response is ...%@",retjson);// 敏感信息,暂时不log
        
        if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
            NSLog(@"网络异常，登陆失败...");
            [TalkingData trackEvent:DATA_EVENT_VERIFY_EMAIL label:DATA_TAG_FAILED];
            TakoUser* user = [TakoUser new];
            user.retCode = @"-1";
            return user;
        }
        
        NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
        if ([resultCode longValue] == 0) {
            NSLog(@"auth success....");
            [TalkingData trackEvent:DATA_EVENT_VERIFY_EMAIL label:DATA_TAG_SUCCESS];
            NSDictionary* data = (NSDictionary*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_DATA_KEY];
            
            TakoUser* user = [TakoUser new];
            if([data objectForKey:LOGIN_USERID_KEY]!=nil){
                user.userId = (NSString*)[data objectForKey:LOGIN_USERID_KEY];
            }
            if([data objectForKey:LOGIN_USERTOKEN_KEY]!=nil){
                user.userToken = (NSString*)[data objectForKey:LOGIN_USERTOKEN_KEY];
                // 存储token
                [XHTUIHelper writeNSUserDefaultsWithKey:USER_TOKEN_KEY withObject:user.userToken];
            }
            if([data objectForKey:LOGIN_USERNICKNAME_KEY]!=nil){
                user.nickName = (NSString*)[data objectForKey:LOGIN_USERNICKNAME_KEY];
            }
                user.retCode = @"0";
            return user;
        }else{
            TakoUser* user = [TakoUser new];
            user.retCode = @"-99";
            return  user;
        }
    }
    
    return nil;
}



+(NSData*)postWithDict:(NSDictionary*)dict url:(NSString*)methodUrl{
    
    
    NSData* bodyData = nil;
    if (dict) {
        bodyData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    }
    NSString* serverUrl = [NSString stringWithFormat:@"%@%@",[XHTUIHelper takoHost],methodUrl];
    NSURL* url = [[NSURL alloc] initWithString:serverUrl];
    NSLog(@"url is %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TAKO_SERVER_TIME_OUT];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (bodyData) {
        [request setHTTPBody:bodyData];
        //        NSLog(@"setHTTPBody data = %@",[[NSString alloc]initWithData:bodyData encoding:NSUTF8StringEncoding]);
    }
    
    NSURLResponse *response = nil;

    NSError* error = nil;
    NSData* retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"CODE :%lD",(long)httpResponse.statusCode);
    if ((long)httpResponse.statusCode!=200) {
        [XHTUIHelper tipWithText:@"系统错误，请稍候重试~" time:3];
    }else{
       [self checkHttpResult:retData];
    }
    
    
    return retData;
}


+ (void)setFormDataRequest:(NSMutableURLRequest *)request fromData:(NSDictionary *)formdata{
    
    NSString *boundary = @"12436041281943726692693274280";
    
    //设置请求体中内容
    NSMutableString *bodyString = [[NSMutableString alloc]init];
    int count = (int)([[formdata allKeys] count]-1);
    for (int i=count; i>=0; i--) {
        
        NSString *key = [formdata allKeys][i];
        NSString *value = [formdata allValues][i];
        
        [bodyString appendFormat:@"-----------------------------%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",boundary,key,value];
    }
    
    [bodyString appendFormat:@"-----------------------------%@--\r\n", boundary];
    NSMutableData *bodyData = [[NSMutableData alloc]initWithLength:0];
    NSData *bodyStringData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:bodyStringData];
    
    NSString *contentLength = [NSString stringWithFormat:@"%ld",(long)[bodyData length]];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=---------------------------%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
    [request setHTTPMethod:@"POST"];
    
}


+(NSData*)postFormDataWithDict:(NSDictionary*)dict url:(NSString*)methodUrl{
    
    NSData* bodyData = nil;
    if (dict) {
       bodyData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    }
    NSString* serverUrl = [NSString stringWithFormat:@"%@%@",[XHTUIHelper takoHost],methodUrl];
    NSURL* url = [[NSURL alloc] initWithString:serverUrl];
    NSLog(@"url is %@", url);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TAKO_SERVER_TIME_OUT];
    [self setFormDataRequest:request fromData:dict];

    NSError* error = nil;
    NSData* retData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    [self checkHttpResult:retData];
    
    return retData;
}



+(NSData*) getWithUrl:(NSString*)methodUrl
{

//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSLog(@"before login....");
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        NSLog(@"%@", cookie);
//    }
    
    
    NSString* urlstr = [NSString stringWithFormat:@"%@%@",[XHTUIHelper takoHost],methodUrl];
    NSLog(@"url is:%@",urlstr);
    NSURL* url = [[NSURL alloc] initWithString:urlstr];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TAKO_SERVER_TIME_OUT];
    [request setHTTPMethod:@"GET"];
    NSLog(@"request is %@",request);
    NSURLResponse* response;
    NSData* returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

    if ((long)httpResponse.statusCode==500) {
        [XHTUIHelper tipWithText:@"系统错误，请稍候重试~" time:3];
    }else{
        [self checkHttpResult:returnData];
    }
    
    return returnData;
}

+(BOOL)isPasswordValid:(NSString*)appid password:(NSString*)password{

    NSMutableDictionary* paramDict = [NSMutableDictionary new];
    [paramDict setObject:appid forKey:@"id"];
    
    if (password!=nil && ![password isEqualToString:@"-1"]) {
        [paramDict setObject:password forKey:@"password"];
    }else{
        return NO;
    }
    
    NSData* returnData = [self postFormDataWithDict:paramDict url:@"/app/password/validate"];
    
    if (returnData==nil) {
        return NO;
    }
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"http response is ...%@",retjson);
    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
        DDLogError(@"error!!! password error...");
        return NO;
    }
    
    NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
    if ([resultCode longValue] != 0) {
        NSLog(@"password validate failed....");
        return NO;
    }
    return YES;

}

+(int) testDownloadUrl:(NSString*)url{
    
    NSURL* urlT = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:urlT cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TAKO_DOWNLOAD_URL_TEST_TIME_OUT];
    [request setHTTPMethod:@"HEAD"];
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
//    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//    NSLog(@"test result is:%@",retjson);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    NSLog(@" http response : %d",httpResponse.statusCode);

    if(httpResponse.statusCode==200){
        return 200;
    }else if (httpResponse.statusCode==404){
        NSLog(@"内网下载链接已失效~");
        return 404;
    }
    
    return 999;
}

+(void)checkHttpResult:(NSData*) returnData{
    // 解析结果
    NSString* retjson = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

    if([XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY]==nil){
//        NSLog(@"check http result :http response is ...%@",retjson);
        [XHTUIHelper tipWithText:@"系统错误，请稍候重试~" time:2];
    }else{
        NSNumber* resultCode = (NSNumber*)[XHTUIHelper objectWithJsonStr:retjson byKey:COMMON_RET_KEY];
        if ([resultCode intValue]==LOGIN_INVALID) {
            NSLog(@"session 超时~");
            [XHTUIHelper tipWithText:@"当前会话已过期，请重新登录~" time:3];
            // 发送事件
            NSNotification *notification =[NSNotification notificationWithName:SESSION_ILLEGAL_NOTIFICATION object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
}



@end
