
#import "Version.h"

@implementation TakoVersion


//- (void)setValue:(id)value forKey:(NSString *)key
//{
//    if ([value isKindOfClass:[NSNull class]]) {
//        return;
//    }
//    
//    if ([key isEqualToString:@"coord"]) {
//        value = [[Coord alloc] initWithDictionary:value];
//    }
//
//    [super setValue:value forKey:key];
//}
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

@end