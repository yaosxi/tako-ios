
#import "md5.h"
#include <CommonCrypto/CommonDigest.h>

@interface CalculateMD5(){
    dispatch_queue_t  MD5ChecksumOperationQueue ;
    dispatch_io_t readChannel;
}

@end

@implementation CalculateMD5



- (id)init
{
    self = [super init];
    if (self)
    {
        MD5ChecksumOperationQueue = dispatch_queue_create("com.test.calculateMD5Checksum", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)closeReadChannel
{
    dispatch_async(MD5ChecksumOperationQueue, ^{
        dispatch_io_close(readChannel, DISPATCH_IO_STOP);
    });
}

- (void)MD5Checksum:(NSString *)pathToFile TCB:(void(^)(NSString *md5, NSError *error))tcb
{
    // Initialize the hash object
    __block CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    readChannel = dispatch_io_create_with_path(DISPATCH_IO_STREAM,
                                               pathToFile.UTF8String,
                                               O_RDONLY, 0,
                                               MD5ChecksumOperationQueue,
                                               ^(int error) {
                                                   [self closeReadChannel];
                                               });
    
    if (readChannel == nil)
    {
        NSError* e = [NSError errorWithDomain:@"MD5Error"
                                         code:-999 userInfo:@{
                                                              NSLocalizedDescriptionKey : @"failed to open file for calculating MD5."
                                                              }];
        tcb(nil, e);
        return;
    }
    
    dispatch_io_set_high_water(readChannel, 512*1024);
    
    dispatch_io_read(readChannel, 0, SIZE_MAX, MD5ChecksumOperationQueue, ^(bool done, dispatch_data_t data, int error) {
        if (error != 0)
        {
            NSError* e = [NSError errorWithDomain:@"ExamSoftMD5"
                                             code:error userInfo:@{
                                                                   NSLocalizedDescriptionKey : @"failed to read from file for calculating MD5."
                                                                   }];
            tcb(nil, e);
            [self closeReadChannel];
            return;
        }
        
        if (dispatch_data_get_size(data) > 0)
        {
            const void *buffer = NULL;
            size_t size = 0;
            data = dispatch_data_create_map(data, &buffer, &size);
            
            CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)size);
        }
        
        if (done == YES)
        {
            // Compute the hash digest
            unsigned char digest[CC_MD5_DIGEST_LENGTH];
            CC_MD5_Final(digest, &hashObject);
            
            // Compute the string result
            char *hash = calloc((2 * sizeof(digest) + 1), sizeof(char));
            for (size_t i = 0; i < sizeof(digest); ++i)
            {
                snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
            }
            
            tcb(@(hash), nil);
            
            [self closeReadChannel];
        }
    });
}


@end