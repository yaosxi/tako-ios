
#import "AppVersion.h"
//#import <objc/runtime.h>
//#import <zlib.h>
#import "UIHelper.h"
#import "Constant.h"


@implementation TakoAppVersion

-(id)init{
    if((self = [super init])){
        self.propertykeys = [XHTUIHelper getObjectKeys:self];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{

    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if ([key isEqualToString:@"id"]) {
        NSString* versionId = value;
        [super setValue:versionId forKey:@"versionId"];
        return;
    }
    
    if ([key isEqualToString:@"releasetime"]) {
        NSString* time;
        if (value == [NSNull null]) {
            time = @"2016-01-01";// 若找不到时间，默认填2016年的1月1日
        }else{
            NSString* year = [value substringToIndex:10];
            NSString* day = [value substringWithRange:NSMakeRange(11, 5)];
            time = [NSString stringWithFormat:@"%@ %@",year,day];
        }
        [super setValue:time forKey:@"releasetime"];
        return;
    }
    
    // refactor: 此处需要server端增加字段，以简化解析。
    if ([key isEqualToString:@"package"]) {
        
        NSString* versionName = (NSString*)[(NSDictionary*)value objectForKey:@"version"] ;
        [super setValue:versionName forKey:@"versionname"];
        
        NSNumber* size = [(NSDictionary*)value objectForKey:@"size"];
        double sizeM = (double)((double)[size longLongValue]/1024)/1024;
        NSString* v = [NSString stringWithFormat:@"%.1f M",sizeM];
        [super setValue:v forKey:@"size"];
        
        NSString* bundleid = (NSString*)[(NSDictionary*)value objectForKey:@"bundleid"] ;
        [super setValue:bundleid forKey:@"bundleid"];
        
        NSString* md5 = (NSString*)[(NSDictionary*)value objectForKey:@"md5"] ;
        [super setValue:md5 forKey:@"md5"];
        
        NSString* lanurl = (NSString*)[(NSDictionary*)value objectForKey:@"lanurl"] ;
        [super setValue:lanurl forKey:@"lanurl"];
        
        NSString* buildnumber = (NSString*)[(NSDictionary*)value objectForKey:@"buildnumber"] ;
        [super setValue:buildnumber forKey:@"buildnumber"];
        
        return;
    }
    
    
    
    //    // appid敏感字符处理
    //    if ([key isEqualToString:@"id"]) {
    //        [super setValue:value forKey:@"appid"];
    //        return;
    //    }
    
    if (![self.propertykeys containsObject:key]) {
        return;
    }
    
    
    [super setValue:value forKey:key];
}

-(BOOL)isLanInValid{
    return [XHTUIHelper isEmpty:self.lanurl] || [XHTUIHelper isEmpty:self.lanhost] ;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        self = [super init];
        if (self) {
            [self setValuesForKeysWithDictionary:dictionary];
        }
        return self;
    } else {
        return nil;
    }
}

//
//- (NSMutableArray*)getObjectKeys:(id)obj
//{
//    NSMutableArray* keys = [NSMutableArray new];
//    unsigned int propsCount;
//    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
//    for(int i = 0;i < propsCount; i++)
//    {
//        objc_property_t prop = props[i];
//        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
//        [keys addObject:propName];
//    }
//    return keys;
//}


@end