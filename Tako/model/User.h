
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TakoUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *retCode;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end

