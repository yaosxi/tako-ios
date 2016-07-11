//
//  InstallingModel.h
//  InstallProgress
//
//  Created by star on 14/12/21.
//  Copyright (c) 2014年 Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstallingModel : NSObject

@property(nonatomic,strong) NSString *bundleID;

@property(nonatomic,strong) NSString *progress;

@property(nonatomic,strong) NSString *status;

@end
