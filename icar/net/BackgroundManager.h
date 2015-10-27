//
//  BackgroundManager.h
//  TestBackGround
//
//  Created by jiangshan zhang on 12-6-18.
//  Copyright (c) 2012年 Youku. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    BackgroundManagerStateNormal,
    BackgroundManagerStateStart,
    BackgroundManagerStateEnd,
    BackgroundManagerStateUnSupport
}BackgroundManagerState;
@interface BackgroundManager : NSObject

@property (nonatomic, assign) BOOL enableSilentDownload;

+ (id)sharedManager;
- (void)beginBackgroundMode;
- (void)endBackgroundMode;
- (void)restoreplayIfNeed;
- (void)enableBackground:(BOOL)enable;
@end
