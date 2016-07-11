
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TakoVersion : NSObject
@property (nonatomic, copy) NSString *versionId;
@property (nonatomic, copy) NSString *buildNumber;
@property (nonatomic, copy) NSString *versionName;
@property (nonatomic) BOOL forceUpgrade;
@property (nonatomic, copy) NSDate *createTime;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end

