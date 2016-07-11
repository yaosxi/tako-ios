//
//  AppHis+CoreDataProperties.h
//  Tako
//
//  Created by 熊海涛 on 16/3/14.
//  Copyright © 2016年 熊海涛. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//


// 注：该文件中的字段需要与模型文件中的一一对应

#import "AppHis.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppHis (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *appid;
@property (nullable, nonatomic, retain) NSString *appname;
@property (nullable, nonatomic, retain) NSString *logourl;
@property (nullable, nonatomic, retain) NSString *packagename;
@property (nullable, nonatomic, retain) NSString *downloadPassword;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *size;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *versionname;
@property (nullable, nonatomic, retain) NSString *versionId;
@property (nullable, nonatomic, retain) NSString *md5;
@property (nullable, nonatomic, retain) NSString *lanurl;
@property (nullable, nonatomic, retain) NSString *lanhost;
@property (nullable, nonatomic, retain) NSString *testField;

@property (nullable, nonatomic, retain) NSString *userid;
@property (nullable, nonatomic, retain) NSString *currentlength;
@property (nullable, nonatomic, retain) NSString *totallength;
@property (nullable, nonatomic, retain) NSNumber *isDownloadSuccess;
@property (nullable, nonatomic, retain) NSString *releasetime;
@property (nullable, nonatomic, retain) NSDate *createHisTime;

@end

NS_ASSUME_NONNULL_END
