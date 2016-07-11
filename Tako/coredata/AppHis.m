//
//  AppHis.m
//  Tako
//
//  Created by 熊海涛 on 16/3/14.
//  Copyright © 2016年 熊海涛. All rights reserved.
//

#import "AppHis.h"

@implementation AppHis

// 重写 取 没有定义key 时 返回，未使用
- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key{
//    NSLog(@"do nothing...");
}


// 重写 取 没有定义key 时 返回，使用1
- (nullable id)valueForUndefinedKey:(NSString *)key{
    return key;
}

//// 重写 取 没有定义key 时 返回，使用2
//- (void)setValue:(id)value forKey:(NSString *)key{
//    NSLog(@"do nothing...");
//}


// 重写 赋值为nil 时 ，修改赋值，未使用
- (void)setNilValueForKey:(NSString *)key{
    [self setValue:@"" forKeyPath:key];
}
@end
