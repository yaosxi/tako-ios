
#import "App.h"
//#import <objc/runtime.h>
//#import <zlib.h>
#import "UIHelper.h"
#import "Constant.h"


@implementation TakoApp

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
  
    // refactor: 此处需要server端增加字段，以简化解析。
    if ([key isEqualToString:@"releaseversion"]) {
        
        NSString* versionName = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"version"];
        [super setValue:versionName forKey:@"versionname"];
        
        NSString* buildNumber = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"buildnumber"];
        [super setValue:buildNumber forKey:@"buildnumber"];
        
         NSNumber* size = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"size"];
        double sizeM = (double)((double)[size longLongValue]/1024)/1024;
        NSString* v = [NSString stringWithFormat:@"%.1f M",sizeM];
        [super setValue:v forKey:@"size"];
        
         NSString* bundleid = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"bundleid"];
        [super setValue:bundleid forKey:@"bundleid"];
        
         NSString* md5 = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"md5"];
        [super setValue:md5 forKey:@"md5"];
        
        NSString* lanurl = [(NSDictionary*)[(NSDictionary*)value objectForKey:@"package"] objectForKey:@"lanurl"];
        [super setValue:lanurl forKey:@"lanurl"];
        
        
        NSString* versionId = (NSString*)[(NSDictionary*)value objectForKey:@"id"];
        [super setValue:versionId forKey:@"versionId"];
        

        NSString* t ;
        NSDictionary* tempv = (NSDictionary*)value;
        if ([tempv objectForKey:@"releasetime"] == [NSNull null]) {
            t = @"2016-01-01";// 若找不到时间，默认填2016年的1月1日
        }else{
            NSString* releasetime = (NSString*)[(NSDictionary*)value objectForKey:@"releasetime"];
            NSString* year = [releasetime substringToIndex:10];
            NSString* day = [releasetime substringWithRange:NSMakeRange(11, 5)];
            t = [NSString stringWithFormat:@"%@ %@",year,day];
        }
    
        [super setValue:t forKey:@"releasetime"];
        
        return;
    }
   
    
    
    // appid敏感字符处理
    if ([key isEqualToString:@"id"]) {
        [super setValue:value forKey:@"appid"];
        return;
    }
    
    if (![self.propertykeys containsObject:key]) {
        return;
    }
    
    
    [super setValue:value forKey:key];
}

-(BOOL)isLanInValidurl:(NSString*)url host:(NSString*)host{

    // 调整：2016_05_06 服务端可能不再返回lanHost地址
    if ([XHTUIHelper isEmpty:url] || ([XHTUIHelper isEmpty:host] && ![url hasPrefix:@"http"])) {
        return YES;
    }
    return NO;
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