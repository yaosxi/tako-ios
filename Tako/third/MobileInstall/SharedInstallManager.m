//
//  SharedInstallManager.m
//  InstallProgress
//
//  Created by star on 14/12/21.
//  Copyright (c) 2014年 Star. All rights reserved.
//  modify by xht :  add delegate for listener .
//

#import "SharedInstallManager.h"

#import "LSApplicationProxy.h"
#import "LSApplicationWorkspace.h"
#import <dlfcn.h>

#import "InstallingModel.h"

@implementation SharedInstallManager

NSTimer* timer = nil;

+(SharedInstallManager *)shareInstWithdelegate:(id<XHTInstallProgressDelegate>)delegate{

    static SharedInstallManager *shareInstallInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        
        if (shareInstallInstance == nil) {
            
            shareInstallInstance = [[SharedInstallManager alloc] init];
            shareInstallInstance.delegate = delegate;
        }
        
    });
    
    return shareInstallInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _installAry = [[NSMutableArray alloc] init];
        
        [self run];
        
    }
    return self;
}

+ (void)stop{
    if (timer) {
        [timer invalidate];
        timer=nil;
    }
}

- (void)run{
   timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateInstallList) userInfo:nil repeats:NO];
//    [self updateInstallList];
}

-(void)updateInstallList{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(installProgressChanged:) name:@"SBInstalledApplicationsDidChangeNotification" object:nil];
    
    void *lib = dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices", RTLD_LAZY);
    
    NSMutableArray* newInstallItems = [NSMutableArray new];
    NSMutableArray* currentInstallItems = [NSMutableArray new];
    NSMutableArray* failedItems = [NSMutableArray new];
    NSMutableArray* finishedInstallItems = [NSMutableArray new];
    
    if (lib)
    {
        Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
        id AAURLConfiguration1 = [LSApplicationWorkspace defaultWorkspace];
        [AAURLConfiguration1 addObserver:self];
        if (AAURLConfiguration1)
        {
            id arrApp = [AAURLConfiguration1 allApplications];
            
            for (int i=0; i<[arrApp count]; i++) {
                
                LSApplicationProxy *LSApplicationProxy = [arrApp objectAtIndex:i];
                NSString* bundleId =[LSApplicationProxy applicationIdentifier];
                
               
                NSProgress *progress = (NSProgress *)[LSApplicationProxy installProgress];
               
                // add xht
//                InstallingModel* hello = [InstallingModel new];
//                hello.bundleID = @"333";
//                [hello addObserver:self forKeyPath:@"bundleID" options:NSKeyValueObservingOptionNew context:NULL];
//                hello.bundleID = @"444";
                

//                NSLog(@"arry count is:%lu,bundleid is:%@ ",(unsigned long)[arrApp count],bundleId);
//
//                if ([bundleId isEqualToString:@"com.ukids.coloreddots"]) {
//                    NSLog(@"hello,color progress is:%@,count is:%lu",progress,(unsigned long)[arrApp count]);
//                }
                InstallingModel *model = [self getInstallModel:bundleId];

                NSLog(@"bundleId 1 is:%@",bundleId);
                if (progress)
                {
                    NSLog(@"bundleId is:%@",bundleId);
                    
                    // todo: 不可用，因为安装时机是用户选择的，所以注册监听的时间不确定。此处会漏掉许多安装进度。
                    [progress addObserver:self forKeyPath:@"userInfo.installState" options:NSKeyValueObservingOptionNew context:NULL];
                    
                    NSLog(@"add observer for progress:%@",progress);
                    
                    if (model) {
                        NSString* newProgress = [[progress localizedDescription] substringToIndex:2];
                        
                        if ([newProgress isEqualToString:@"0%"] && ![model.progress isEqualToString:newProgress]) {
                            // 安装失败
                            [failedItems addObject:model];
                        }
                        else if (![model.progress isEqualToString:newProgress]) {
                            // 更新安装进度
                            [currentInstallItems addObject:model];
                        }
                        NSLog(@"所有应用的安装进度, app:%@,progress:%@",model.bundleID,model.progress);
                        model.progress = [[progress localizedDescription] substringToIndex:2];
                        model.status  =  [NSString stringWithFormat:@"%@",[[progress userInfo] valueForKey:@"installState"]];
                        
                    }else{
                        InstallingModel *model = [[InstallingModel alloc] init];
                        
                        model.bundleID = bundleId;
                        model.progress = [[progress localizedDescription] substringToIndex:2];
                        model.status  = [NSString stringWithFormat:@"%@",[[progress userInfo] valueForKey:@"installState"]];
                        
                        [_installAry addObject:model];
                        
                        // 新增安装
                        [newInstallItems addObject:model];
                        
                    }
                    
                }else{
                
                    // 新增结束
                    [_installAry removeObject:model];
                    if (model) {
                        [finishedInstallItems addObject:model];
                    }
                }
            }
        }
        
//        NSLog(@"_installAry count:%lu",(unsigned long)_installAry.count);
//        for (InstallingModel* temp in _installAry) {
//            NSLog(@"bundleid:%@,progress:%@,status:%@",temp.bundleID,temp.progress,temp.status);
//        }
        if (lib) dlclose(lib);
    }

    if ([newInstallItems count] > 0) {
        NSLog(@"发现新增安装任务：%lu",(unsigned long)[newInstallItems count]);
//        [self.delegate newInstall:newInstallItems];
    }
    if ([currentInstallItems count] > 0) {
        NSLog(@"发现新的安装任务进度有更新：%lu",(unsigned long)[currentInstallItems count]);
//        [self.delegate currentInstallProgress:currentInstallItems];
    }
    if ([finishedInstallItems count] > 0) {
        NSLog(@"发现新的安装任务结束：%lu",(unsigned long)[finishedInstallItems count]);
//        [self.delegate finishInstall:finishedInstallItems];
    }
    if ([failedItems count] > 0) {
        NSLog(@"发现新的安装任务失败：%lu",(unsigned long)[failedItems count]);
//        [self.delegate failedInstall:failedItems];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"receive new update ...change is:%@ object is:%@",change,object);
    
//    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress is: %f", progress.fractionCompleted);
    }
}

-(void)installProgressChanged:(NSNotification*)notice{

    NSLog(@"hello~  i receive a notification from install.....");

}

- (void)dealloc
{
    NSLog(@"will dead...");
}




//
//-(BOOL)isInstalledApp:(NSString*)bundleid{
//    void *lib = dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices", RTLD_LAZY);
//    BOOL isInstalled;
//    if (lib) {
//        Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
//        isInstalled = [[LSApplicationWorkspace defaultWorkspace] applicationIsInstalled:bundleid];
//        
//        if (isInstalled) {
//            NSLog(@"yes");}
//        else {
//            NSLog(@"no");
//        }
//    }
//    
//    return isInstalled;
//}

-(InstallingModel *)getInstallModel:(NSString *)bunldID{

    for (InstallingModel *model in _installAry) {
        
        if ([model.bundleID isEqualToString:bunldID]) {
            
            return model;
        }
    }

    return nil;
}

@end
