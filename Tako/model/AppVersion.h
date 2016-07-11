
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// cell表格的数据类
@interface TakoAppVersion : NSObject
@property (nonatomic,copy) NSString *appname;
@property (nonatomic,copy) NSString *appid;
@property (nonatomic, copy) NSString *versionname;//appversion 1.0.1
@property (nonatomic, copy) NSString *versionId;//appversionid 34343435ssds55
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *releaseDesc;

@property (nonatomic,strong) NSNumber* cellHeight ;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *packagename;
@property (nonatomic, copy) NSString *logourl;

@property (nonatomic,copy)  NSString *installProgress;
@property (nonatomic, copy) NSString *releasetime;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *bundleid;
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *userid;

@property (nonatomic) BOOL isClicked;// 单击more按钮

@property (nonatomic, copy) NSString *currentlength;
@property (nonatomic, copy) NSString *totallength;

// properties for cell
@property (nonatomic,copy) NSString* myCellIndex;
@property (nonatomic,copy) NSString *downloadUrl;

@property (nonatomic,copy) NSString* downloadPassword;

@property (nonatomic) BOOL isHidden;
@property (nonatomic) BOOL isDownloadSuccess;
@property (nonatomic) BOOL isNeedUpdate;

@property NSString* progress;
@property float progressValue;
@property enum APPSTATUS status;

@property (nonatomic) NSArray* propertykeys;

@property (nonatomic, copy) NSString *lanhost;
@property (nonatomic, copy) NSString *lanurl;

// version新增的属性
@property (nonatomic,copy) NSString *buildnumber;
@property (nonatomic,copy) NSString *releasenote;
@property (nonatomic) BOOL forceupgrade;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(BOOL)isLanInValid;

@end

