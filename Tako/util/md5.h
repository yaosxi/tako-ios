
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
   新开线程，异步计算md5
 */
@interface CalculateMD5 : NSObject

- (void)MD5Checksum:(NSString *)pathToFile TCB:(void(^)(NSString *md5, NSError *error))tcb;

@end
