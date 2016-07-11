//
//  CoreDataManager.h
//  Tako
//
//  coredata 公共类，copy from third part
//

#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

+ (CoreDataManager *)shareCoreDataManagerManager;


/**
 * 创建空的表映射对象
 * 参数:实体描述名
 * 返回值:id
 */
- (id)createEmptyObjectWithEntityName:(NSString *)entityName;

/**
 * 查询托管对象上下文中的对象
 * 参数:(查询条件)
 * 返回值:id
 */
- (id)getOneWithPredicate:(NSPredicate *)predicate entityName:(NSString *)entityName;

/**
 * 查询托管对象上下文中的对象
 * 参数:(查询条件,排序条件,返回总个数)
 * 返回值:NSArray
 */
- (NSArray *)getListWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptions entityName:(NSString *)entityName limitNum:(NSNumber *)limitNum;

/**
 * 查询托管对象上下文中的对象
 * 参数:(查询条件,排序条件,页码，分页大小)
 * 返回值:NSArray
 */
- (NSArray *)getListWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptions entityName:(NSString *)entityName pageNow:(int)pageNow pageSize:(int)pageSize;

/**
 * 删除托管对象上下文中的一个对象
 * 参数:需要删除的任意对象
 * 返回值:void
 */
- (void)deleteObject:(NSManagedObject *)object;

/**
 * 删除托管对象上下文中的所有对象
 * 参数:实体描述名
 * 返回值:void
 */
- (void)removeAllObjectWithEntityName:(NSString *)entityName;

/**
 * 保存托管对象上下文中的更改
 * 参数:NO
 * 返回值:BOOL
 */
- (BOOL)save;

/**
 * 保存托管对象上下文中的更改(在程序将要崩溃前)
 * 参数:NO
 * 返回值:BOOL
 */
- (void)saveBeforeTerminate;

@end