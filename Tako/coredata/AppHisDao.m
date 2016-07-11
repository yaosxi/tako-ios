
#import "AppHisDao.h"
#import "Constant.h"
#import "UIHelper.h"
#import "AppDelegate.h"


@interface AppHisDao()
@property (strong, nonatomic)AppDelegate *delegate;
@end

static AppHisDao *share = nil;


#define APP_MODEL_NAME @"AppHis"

@implementation AppHisDao

+(AppHisDao*) share{
    @synchronized(self) {
    
        if (share==nil) {
             share = [[self alloc] init];
             share.delegate = [UIApplication sharedApplication].delegate;
        }
    
        return share;
    }
}



-(BOOL)updateApp:(TakoApp*)apphis{
    // 查询
   
   AppHis* app = [self fetchAppWithVersionId:apphis.versionId];
    if (app == nil) {
        NSLog(@"没有查询到有效数据，不更新。");
        return NO;
    }
    
    NSArray* keys = [XHTUIHelper getObjectKeys:apphis];
    for (NSString* key in keys) {
        id value = [apphis valueForKey:key];
        
        // nil值和0值不更新
        if (value && value != 0) {
            [app setValue:value forKey:key];
        }
    }

    [self.delegate saveContext];
    return YES;
}


-(BOOL)createApp:(TakoApp*)apphis{
    
    apphis.userid = [XHTUIHelper readNSUserDefaultsWithkey:USER_ID_KEY];
    // refactor: 使用主键？
    AppHis* oldApp = [self fetchAppWithVersionId:apphis.versionId];
    if (oldApp) {
        NSLog(@"警告：重复数据，将直接更新原有数据。");
        [self updateApp:apphis];
        return YES;
    }
    // 增加
    NSManagedObject* app = [NSEntityDescription insertNewObjectForEntityForName:APP_MODEL_NAME inManagedObjectContext:self.delegate.managedObjectContext];
    NSDictionary* appHisDict = [XHTUIHelper getObjectData:apphis];
   
    
    // 不匹配的值自动填写为空。
    [app setValuesForKeysWithDictionary:appHisDict];
    
    // refactor: 延迟save？
    [self.delegate saveContext];
    return YES;
}

// 该用户下的所有apps
-(NSArray*)fetchAllApp{
    // 查询
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:APP_MODEL_NAME inManagedObjectContext:self.delegate.managedObjectContext];
    NSString* cond = [NSString stringWithFormat:@"%@ = '%@'",@"userid",[XHTUIHelper readNSUserDefaultsWithkey:USER_ID_KEY]];
    request.predicate = [NSPredicate predicateWithFormat:cond];

    NSError *error = nil;
    NSArray* objects = [self.delegate.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"find result count is：%lu",(unsigned long)[objects count]);
    if (objects.count == 0) {
        return nil;
    }
    return objects;

}

-(AppHis*)fetchLatestAppWithAppId:(NSString*)appid{
    
    // 查询
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:APP_MODEL_NAME inManagedObjectContext:self.delegate.managedObjectContext];
    

    NSString* cond = [NSString stringWithFormat:@"appid = '%@' AND userid = '%@'",appid,[XHTUIHelper readNSUserDefaultsWithkey:USER_ID_KEY]];
    request.predicate = [NSPredicate predicateWithFormat:cond];
    
    NSError *error = nil;
    NSArray* objects = [self.delegate.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"find result count is：%lu",(unsigned long)[objects count]);
    
    AppHis* latestHis = nil;
    for (id obj in objects) {
        AppHis* a = (AppHis*)obj;

        if (latestHis==nil || [a.createHisTime timeIntervalSinceDate:latestHis.createHisTime]>0) {
                latestHis=a;
        }

        NSLog(@"obj is:%@,%@,%@,%@,%@",a.userid,a.appname,a.appid,a.versionname,a.versionId);
    }
    if (objects.count == 0) {
        return nil;
    }
    
    return latestHis;
}


-(AppHis*)fetchAppWithVersionId:(NSString*)versionId{
    
    // 查询
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:APP_MODEL_NAME inManagedObjectContext:self.delegate.managedObjectContext];
    
    
    NSString* cond = [NSString stringWithFormat:@"versionId = '%@' AND userid = '%@'",versionId,[XHTUIHelper readNSUserDefaultsWithkey:USER_ID_KEY]];
    request.predicate = [NSPredicate predicateWithFormat:cond];
    
    NSError *error = nil;
    NSArray* objects = [self.delegate.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"find result count is：%lu",(unsigned long)[objects count]);
    for (id obj in objects) {
        AppHis* a = (AppHis*)obj;
        NSLog(@"obj is:%@,%@,%@,%@,%@",a.userid,a.appname,a.appid,a.versionname,a.versionId);
    }
    if (objects.count == 0) {
        return nil;
    }
    
    return [objects objectAtIndex:0];
}


-(void)removeAppWithVersionId:(NSString*)versionId{
    AppHis* app = [self fetchAppWithVersionId:versionId];
    if(app==nil){
        DDLogError(@" app remove # no app found, version is:%@,will return...",versionId);
        return;
    }
    [self.delegate.managedObjectContext deleteObject:app];
    
    // refactor: 延迟保存？
    [self.delegate saveContext];
}

-(void)removeAllApp{
    // 查询
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:APP_MODEL_NAME inManagedObjectContext:self.delegate.managedObjectContext];
    
    NSError *error = nil;
    NSArray* objects = [self.delegate.managedObjectContext executeFetchRequest:request error:&error];
//    NSLog(@"find result count is：%lu",(unsigned long)[objects count]);
        for (id obj in objects) {
            NSLog(@"obj is:%@",obj);
            [self.delegate.managedObjectContext deleteObject:obj];
        }
    
    // refactor: 延迟保存？
    [self.delegate saveContext];
}

-(void)save{
    [self.delegate saveContext];
}

@end