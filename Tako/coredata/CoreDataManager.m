//
//  CoreDataManager.m
//  Tako
//
//  coredata 公共类，copy from third part
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

@interface CoreDataManager ()

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;//托管对象上下文

@end

static CoreDataManager *staticCoreDataManager;

#define DB_NAME @"Tako.sqlite"
#define TABLE_NAME @"DownloadModel"

@implementation CoreDataManager

- (id)init
{
    if (self = [super init])
    {
        if (!self.managedObjectContext)
        {
            //指定存储数据文件(CoreData是建立在SQLite之上的,文件后缀名为:xcdatamodel)
            NSString *persistentStorePath = [self documentPathOffile:@"Tako.sqlite"]; //zmt.sqlite
            
            //创建托管对象模型
            //NSManagedObjectModel  *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:TABLE_NAME withExtension:@"momd"];
            NSManagedObjectModel  *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            
            //创建持久化存储协调器,并使用SQLite数据库做持久化存储
            NSURL *storeUrl = [NSURL fileURLWithPath:persistentStorePath];
            NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
            
            NSError *error = nil;
            NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],
                                      NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};
            NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
            
            //创建托管对象上下文
            if (persistentStore && !error)
            {
                NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
                
                self.managedObjectContext = managedObjectContext;
            }
        }
    }
    return self;
}

+ (CoreDataManager *)shareCoreDataManagerManager
{
    if (nil == staticCoreDataManager)
    {
        staticCoreDataManager = [[CoreDataManager alloc] init];
    }
    return staticCoreDataManager;
}

- (id)createEmptyObjectWithEntityName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
}

- (id)getOneWithPredicate:(NSPredicate *)predicate entityName:(NSString *)entityName
{
    NSArray *result = [self getListWithPredicate:predicate sortDescriptors:nil entityName:entityName limitNum:@1];
    if (result && result.count > 0)
    {
        return [result firstObject];
    }
    return nil;
}

- (NSArray *)getListWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptions entityName:(NSString *)entityName limitNum:(NSNumber *)limitNum
{
    NSError *error = nil;
    
    //创建取回数据请求
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    //设置查询条件
    [fetchRequest setPredicate:predicate];
    
    //设置排序条件
    [fetchRequest setSortDescriptors:sortDescriptions];
    
    //查询条件的总数
    if ([limitNum intValue]>0)
    {
        [fetchRequest setFetchLimit:[limitNum intValue]];
    }
    
    //执行获取数据请求,返回数组
    NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchResult;
}

- (NSArray *)getListWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptions entityName:(NSString *)entityName pageNow:(int)pageNow pageSize:(int)pageSize
{
    NSError *error = nil;
    
    //创建取回数据请求
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    //设置查询条件
    [fetchRequest setPredicate:predicate];
    
    //设置排序条件
    [fetchRequest setSortDescriptors:sortDescriptions];
    
    //查询条件的总数
    [fetchRequest setFetchLimit:pageSize];
    
    [fetchRequest setFetchOffset:(pageNow-1)*pageSize];
    
    //执行获取数据请求,返回数组
    NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchResult;
}

- (void)deleteObject:(NSManagedObject *)object
{
    [self.managedObjectContext deleteObject:object];
    
    [self save];
}

- (void)removeAllObjectWithEntityName:(NSString *)entityName
{
    NSArray *allObjects = [self getListWithPredicate:nil sortDescriptors:nil entityName:entityName limitNum:nil];
    
    if (allObjects && 0 != allObjects.count)
    {
        for (NSManagedObject *object in allObjects)
        {
            [self.managedObjectContext deleteObject:object];
        }
        [self save];
    }
}

- (BOOL)save
{
    NSError *error = nil;
    
    return [self.managedObjectContext save:&error];
}

- (void)saveBeforeTerminate
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}


- (NSString *)documentPathOffile:(NSString *)file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths == nil) return nil;
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (documentsDirectory == nil) return nil;
    
    if (nil != file)
        return [documentsDirectory stringByAppendingPathComponent:file];
    NSLog(@"document path is %@",documentsDirectory);
    return documentsDirectory;
}


@end
