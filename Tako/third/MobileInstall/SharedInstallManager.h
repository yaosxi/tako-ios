//
//  SharedInstallManager.h
//  InstallProgress
//
//  Created by star on 14/12/21.
//  Copyright (c) 2014年 Star. All rights reserved.
//  modify by xht :  add delegate for listener .
//  由于此类调用了apple私有api，暂未使用，
//

#import <Foundation/Foundation.h>

@protocol XHTInstallProgressDelegate <NSObject>

-(void) finishInstall:(NSArray*)models;
-(void) failedInstall:(NSArray*)models;
-(void) currentInstallProgress:(NSArray*)models;
-(void) newInstall:(NSArray*)models;

@end

@interface SharedInstallManager : NSObject

@property (strong, nonatomic) NSMutableArray *installAry;
@property (weak, nonatomic) id<XHTInstallProgressDelegate> delegate;

+(SharedInstallManager *)shareInstWithdelegate:(id<XHTInstallProgressDelegate>)delegate;

- (void)run;
+ (void)stop;

//-(BOOL)isInstalledApp:(NSString*)bundleid;

-(void)updateInstallList;

@end
