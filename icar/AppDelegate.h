//
//  AppDelegate.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright (c) 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"

@class HistoryViewController;
@class TrackViewController;
@class PlayerViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LeftSlideViewController           *leftSlideVC;
@property (strong, nonatomic) UINavigationController            *mainNavigationController;
@property (strong, nonatomic) CategoryViewController            *categoryViewController;
@property (strong, nonatomic) DownloadViewController            *downloadViewController;
@property (strong, nonatomic) HistoryViewController             *historyViewController;
@property (strong, nonatomic) PlayerViewController              *playViewController;
@property (strong, nonatomic) MSettingViewController            *msettingViewController;
@property (strong, nonatomic) FMDatabaseQueue       *queue;
@property (strong, nonatomic) YTKKeyValueStore      *localStore;
@property (strong, nonatomic) GCNetworkReachability *reachability;

-(void)configNowPlayingInfoCenter:(NSDictionary *)info;

@end

