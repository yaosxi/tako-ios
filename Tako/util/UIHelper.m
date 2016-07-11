//
//  UIHelper.m
//  HelloTako
//
//  Created by 熊海涛 on 15/12/11.
//  Copyright © 2015年 熊海涛. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "UIHelper.h"
#import "Constant.h"
#import "Reachability.h"

// add for local ip
#include <ifaddrs.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <net/if.h>

// 反射key
#import <objc/runtime.h>
#import <zlib.h>

#import <CommonCrypto/CommonDigest.h>
#import "md5.h"

// 业务controller
#import "MineViewController.h"
#import "TestViewController.h"


@implementation XHTUIHelper

+(void)forceTableViewToLeft:(UITableView *)tableView{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset: UIEdgeInsetsZero];
    }
    
    if(IOS_VERSION>=8.0){
        [tableView setLayoutMargins: UIEdgeInsetsZero];
    }
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins: UIEdgeInsetsZero];
//    }
}


+(BOOL)isDarkColor:(UIColor *)newColor{
    if ([self alphaForColor: newColor]<10e-5) {
        return YES;
    }
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5){
        NSLog(@"Color is dark");
        return YES;
    }
    else{
        NSLog(@"Color is light");
        return NO;
    }
}

+ (CGFloat) alphaForColor:(UIColor*)color {
    CGFloat r, g, b, a, w, h, s, l;
    BOOL compatible = [color getWhite:&w alpha:&a];
    if (compatible) {
        return a;
    } else {
        compatible = [color getRed:&r green:&g blue:&b alpha:&a];
        if (compatible) {
            return a;
        } else {
            [color getHue:&h saturation:&s brightness:&l alpha:&a];
            return a;
        }
    }
}

+(void)forceCellToLeft:(UITableViewCell*)cell
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if(IOS_VERSION>=8.0){
       [cell setLayoutMargins:UIEdgeInsetsZero];
    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

// notes: this mehod maybe do nothing if your xib is auto-layout enabled
+(void) addBorderonButton:(UIButton*) btn cornerSize:(int) size{
    UIColor* systemBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:230.0/255.0 alpha:1.0];
    btn.layer.borderColor = systemBlue.CGColor;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = size;
}


+(void) addBorderonButton:(UIButton*) btn cornerSize:(int) size borderWith:(int)width{
    UIColor* systemBlue = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:230.0/255.0 alpha:1.0];
    btn.layer.borderColor = systemBlue.CGColor;
    btn.layer.borderWidth = width;
    btn.layer.cornerRadius = size;
}

+ (void) disableDownloadButton:(UIButton*) btn{
    [btn.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor grayColor])];
    btn.enabled = NO;
}

+(UIColor*)systemColor{
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:230/255.0 alpha:1.0];
}

+(UIColor*)systemColorwithAlpha:(float)alpha{
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:230/255.0 alpha:alpha];
}


+(CGRect)addFrame:(CGRect)frame addHeight:(float)height addWidth:(float)width{
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame)+width, CGRectGetHeight(frame)+height);
    return newFrame;
}

+(CGRect)setFrame:(CGRect)frame Height:(float)height Width:(float)width{
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), width, height);
    return newFrame;

}

// 隐藏tableview多余的单元格
+ (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

+(MBProgressHUD*)modalAlertIn:(UIView*)view withText:(NSString*)text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.font = [UIFont boldSystemFontOfSize:15.f];
    return hud;
}

// 读取历史用户
+(NSArray*)loadAllUsers{
    
    // todo: 这些用户会和已存储的user重复
    NSArray* defaultUsers = @[@"xionghaitao@kingsoft.com",@"490791821@qq.com",@"547610328@qq.com",@"3056701074@qq.com",@"carson510@126.com",@"jouje@163.com",@"Kris@tako.im"];
    
    NSArray* storedUsers = [self readNSUserDefaultsObjectWithkey:ALL_USER_ACCOUNT_KEY];
    NSMutableArray* users = [NSMutableArray arrayWithArray:defaultUsers];
    
    if (storedUsers) {
        [users addObjectsFromArray:[self readNSUserDefaultsObjectWithkey:ALL_USER_ACCOUNT_KEY]];
    }
    
    return users;
}

+(void)tipNoNetwork{
    [XHTUIHelper tipWithText:@"网络异常,请检查您的网络并重试~" time:2];
}

+(void)tipWithText:(NSString*)text time:(int) time{
    dispatch_async(dispatch_get_main_queue(), ^{
    [RKDropdownAlert title:text message:nil time:time isFromBottom:YES];
    });
}

+(void)alertWithNoChoice:(NSString*)msg view:(UIViewController*)view{
    if(view==nil){
        view = [self getCurrentVC];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
            // use UIAlertView
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else {
            // use UIAlertController
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [view presentViewController:alertController animated:YES completion:nil];
        }
        
        
       
    });
    
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (CGSize) viewSizeWith: (UIView*) view{
    CGSize screensize = view.bounds.size;
    //float height = screensize.height;
    //float width = screensize.width;
    return screensize;
}



//读取userDefault的nsstring数据
+(NSString*)readNSUserDefaultsWithkey:(NSString*) key{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return [userDefaultes stringForKey:key];
}


//读取userDefault的object数据
+(id)readNSUserDefaultsObjectWithkey:(NSString*) key{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return [userDefaultes objectForKey:key];
}

+(BOOL)isMd5Closed{
    if ([XHTUIHelper readNSUserDefaultsObjectWithkey:IS_MD5_OPEN] && [[XHTUIHelper readNSUserDefaultsObjectWithkey:IS_MD5_OPEN] isEqualToString:@"0"]) {
        return YES;
    }
    return  NO;
}

+(BOOL)isAppLoadBefore{
    return [[XHTUIHelper readNSUserDefaultsObjectWithkey:IS_LOAD_BAR_VIEW_KEY] isEqualToString:@"1"];
}

+(void)addNewAccount:(NSString*)account{
      NSArray*  accounts = [XHTUIHelper readNSUserDefaultsObjectWithkey:ALL_USER_ACCOUNT_KEY];
    if( accounts){
        
        // 已存在，则返回
        if ([accounts containsObject:account]) {
            return;
        }
        
        NSMutableArray* all = [NSMutableArray arrayWithArray:accounts];
        [all addObject:account];
        [XHTUIHelper writeNSUserDefaultsWithKey:ALL_USER_ACCOUNT_KEY withObject:all];
    }else{
        NSArray* first = @[account];
        [XHTUIHelper writeNSUserDefaultsWithKey:ALL_USER_ACCOUNT_KEY withObject:first];
    }
}

//数据持久化至userDefault
+(void)writeNSUserDefaultsWithKey:(NSString*) key withValue:(NSString*) value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //添加
    [userDefaults setObject:value forKey:key];
    
    //同步
    [userDefaults synchronize];
}

+ (void)clearAllUserDefaultsData
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}


//object持久化至userDefault
+(void)writeNSUserDefaultsWithKey:(NSString*) key withObject:(id) value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //添加
    [userDefaults setObject:value forKey:key];
    
    //同步
    [userDefaults synchronize];
}



+ (id) objectWithJsonStr: (NSString*) jsonStr byKey: (NSString*) key
{
    if (jsonStr==nil||key==nil) {
        return nil;
    }
    
    id ret=nil;
    NSData* tempData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if(tempData != nil){
        ret = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
        if(ret != nil && [ret isKindOfClass:[NSDictionary class]]){
            NSDictionary* retDict = (NSDictionary*)ret;
            ret = [retDict objectForKey:key];
        }
    }
    
    return ret;
}


+(void) setDictValue:(NSMutableDictionary*) dict withObject:(id)object forKey:(NSString*)key{
    if(object != nil && dict!=nil){
        [dict setObject:object forKey:key];
    }
}


+(BOOL)isLogined{
    NSString* key = [XHTUIHelper readNSUserDefaultsWithkey:LOGIN_KEY];
    if (key==nil) {
        NSLog(@"login key is invalid,please login again...");
        return NO;
    }
    return [key isEqualToString:LOGIN_SUCCESS_KEY];
}

+(BOOL) isOnsiteEnv{
    return [[self infoPlistValueForKey:TAKO_SERVER_KEY] isEqualToString:@"onsite"];
}


+(NSString*) takoHost{
    if ([self isOnsiteEnv]) {
        return TAKO_ONSITE_SERVER_HOST;
    }else{
            return TAKO_QA_SERVER_HOST;
    }
}

+(NSString*) takoAppUrl{
    if ([self isOnsiteEnv]) {
        return TAKO_ONSITE_APP_URL;
    }else{
        return TAKO_QA_APP_URL;
    }
}

+ (id) infoPlistValueForKey:(NSString *) key
{
    if (key==nil)
    {
        return nil;
    }
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

+(NSString*)stringWithLong:(long long)longvalue{
    return [NSString stringWithFormat:@"%qi",longvalue];
}

//获取本机的IP
+ (NSString *)localIPAddress
{
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

+(void)removeDevicefile:(NSString*)file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* homePath =[paths firstObject];
    NSString* filepath = [homePath stringByAppendingPathComponent:file];

   NSFileManager* mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:filepath]) {
        [mgr removeItemAtPath:filepath error:nil];
    }
}

+(int)isDevicefileValid:file md5:(NSString*)md5{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* homePath =[paths firstObject];
    NSString* filepath = [homePath stringByAppendingPathComponent:file];
    
    // 检查文件是否存在
    NSFileManager* mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:filepath]==YES) {
        NSLog(@"device File exists");
        NSLog(@"file is:%@",filepath);
    }else{
        DDLogError(@"error!!! device File not exists");
        return 1;
    }
    
    // 检查md5
    if ([XHTUIHelper isMd5Closed]) {
        return 0;
    }
    
    NSString* currentMd5 = [XHTUIHelper getFileMD5WithPath:filepath];
    if ([md5 isEqualToString:@""]) {
        NSLog(@"md5为空，不校验。");
        return 0;
    }
    if (![currentMd5 isEqualToString:md5]) {
         DDLogError(@"error!!! device filemd5 validate failed,local:%@,remote:%@",currentMd5,md5);
        return 2;
    }
    return 0;
}


+(UIColor*)navigateColor{
    UIColor* color = [UIColor colorWithRed:0.0 green:100.0/255.0 blue:227.0/255.0 alpha:1.0];
    return color;
}


+(void)formatNavigateColor:(UINavigationBar*)bar{
    UIColor* color = [self navigateColor];
    [bar setBarTintColor:color];
    [bar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
}

+ (NSString*)formatByteCount:(long long)size
{
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}


+ (NSMutableArray*)getObjectKeys:(id)obj
{
    NSMutableArray* keys = [NSMutableArray new];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        [keys addObject:propName];
    }
    return keys;
}

+ (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+(BOOL)isString:(NSString*)destString ContainsString:(NSString*)userString{
    if ([destString rangeOfString:userString].location == NSNotFound) {
        return NO;
    }
    return YES;
}


+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

#define FileHashDefaultChunkSizeForReadingData 1024*8


+(NSString*)getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


+(NSString*)md5withFile:(NSString*) path{
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
//        NSLog(@"length is:%lu",(unsigned long)[fileData length]);
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);// file_length  max to be 256 which never overflow,so here we it force to cc_long
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
}

+(BOOL)isDupCookieExist{
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    NSString* oldUserId = nil;
    if (cookies) {
        for (NSHTTPCookie* cookie in cookies) {
            NSLog(@"cookie new is:%@",cookie);
            if ([cookie.name isEqualToString:@"userid"]) {
            // 不能存在两个相同的userid,否则视为cookie异常，需重新登录。
                if (oldUserId==nil) {
                    oldUserId=cookie.value;
                }else if(![oldUserId isEqualToString:cookie.value]){
                    return YES;
                }
                
            }
        }
    }
    
    return NO;
}

// 只存储userid即可
+(void)saveLoginCookie{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for (NSHTTPCookie* cookie in cookies) {
        NSLog(@"cookie new is:%@",cookie);
        if ([cookie.name isEqualToString:@"userid"]) {
        NSMutableDictionary* cookieDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:LOGIN_COOKIE_KEY]];
        [cookieDict setObject:cookie.properties forKey:@"cookieDict"];
        [defaults setObject:cookieDict forKey:LOGIN_COOKIE_KEY];
        [defaults synchronize];
        break;
        }else{
        }
    }
//    NSLog(@"save result is:%@,",[defaults objectForKey:LOGIN_COOKIE_KEY]);
}



+(void)removeLoginCookie{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:LOGIN_COOKIE_KEY];
    [defaults synchronize];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (id obj in _tmpArray) {
        [cookieJar deleteCookie:obj];
    }
//    NSLog(@"remove result is:%@,",[defaults objectForKey:LOGIN_COOKIE_KEY]);

}

+(void)updateLoginCookie{
    BOOL isDupCookieFlag = [self isDupCookieExist];
    if (isDupCookieFlag) {
        DDLogError(@"检查到异常cookie,将清除cookie...");
        [self removeLoginCookie];
        [XHTUIHelper writeNSUserDefaultsWithKey:LOGIN_KEY withObject:LOGIN_FAILED_KEY];
        return;
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* cookieDict = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:LOGIN_COOKIE_KEY]];
    NSDictionary* cookiePropertis = [cookieDict objectForKey:@"cookieDict"];
    
    if(cookiePropertis) {
       NSHTTPCookie* newCookie = [NSHTTPCookie cookieWithProperties:cookiePropertis];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newCookie];
    }
//    NSLog(@"update result is:%@,",[defaults objectForKey:LOGIN_COOKIE_KEY]);

}


+(void)addRightViewforText:(UITextField*)t image:(NSString*)image{
    
    UIImageView *nameImageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    nameImageview.image = [UIImage imageNamed:image];
    t.rightView = nameImageview;
    t.rightViewMode=UITextFieldViewModeAlways;
}


+(RootTabBarController*)initTabbar{
    
    TestViewController *testVC = [[TestViewController alloc] init];
    UINavigationController *testNav = [[UINavigationController alloc] initWithRootViewController:testVC];
    testNav.tabBarItem.image = [UIImage imageNamed:@"icon_test_unselected"];
    testNav.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_test_selected"];
   //    testNav.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);

    testNav.tabBarItem.title = @"测试";
    testNav.navigationItem.backBarButtonItem.title = @"返回";
    
    MineViewController *mineVC = [[MineViewController alloc] init];
   
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem.image = [UIImage imageNamed:@"ic_my_unselected"];
    mineNav.tabBarItem.selectedImage = [UIImage imageNamed:@"ic_my_selected"];

    mineNav.tabBarItem.title = @"我的";
    mineNav.navigationItem.backBarButtonItem.title = @"返回";
    
    RootTabBarController *tabBar = [[RootTabBarController alloc] init];
    [tabBar setViewControllers:@[testNav,mineNav]];
    [tabBar setSelectedIndex:0];
    
    return tabBar;
    
}

+(void)configDebugInfo{

    // 设置调试color
//#if TARGET_IPHONE_SIMULATOR
    // Sends log statements to Xcode console - if available
    setenv("XcodeColors", "YES", 1);
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 小时后写入下一个文件
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;// 最多写7个文件
    
    //(notes: 根据上面的配置，应用程序将要在系统上保持一周的日志文件。另外，
   //  日志文件的默认输出路径，可以在启动日志中查找：warning ==> default log directory)
    [DDLog addLogger:fileLogger];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];// 修改info日志级别对应的颜色
    
    NSLog(@"ddlog config finish ...");

    // 使用方法如下
//    DDLogVerbose(@"this is a verbose log...");
//    DDLogDebug(@"this is a debug log...");
//    DDLogInfo(@"this is a info log...");
//    DDLogWarn(@"this is a warn log...");
//    DDLogError(@"this is a err log..."); top lever
//#endif

}



+(BOOL)isEmpty:(id)object{
    return object == nil || [object isEqualToString:@""] ||[object isKindOfClass:[NSNull class]] ||[object isEqualToString:@"(null)"] ;
}

+(UIButton*)navButtonWithImage:(NSString*) image{
    UIImage* imageOb = nil;
    if(image == nil){
        imageOb = [[UIImage alloc] init];
    }else{
      imageOb = [UIImage imageNamed:image];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:image]
                      forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 25, 25);
    return button;
}

+(void)animateHide:(UIView*)view{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.1;
    [view.layer addAnimation:animation forKey:nil];
    view.hidden = YES;
}


+(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    
    return isExistenceNetwork;
}


+(NSString*)networkTypeFromStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            dataNetworkItemView = subview;
            break;
        }
    }
    NETWORK_TYPE nettype = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    nettype = [num intValue];
    NSString* result =@"unkown";
    switch (nettype) {
        case NETWORK_TYPE_2G:
            result=@"2G";
            break;
        case NETWORK_TYPE_3G:
            result=@"3G";
            break;
        case NETWORK_TYPE_4G:
            result=@"4G";
            break;
        case NETWORK_TYPE_5G:
            result=@"5G";
            break;
        case NETWORK_TYPE_WIFI:
            result=@"wifi";
            break;
        default:
            break;
    }
    return result;
}


@end



@implementation UIView (Frame)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

@end

