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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LeftSlideViewController      *leftSlideVC;
@property (strong, nonatomic) UINavigationController       *mainNavigationController;
@property (strong, nonatomic) CategoryViewController       *categoryViewController;
@property (strong, nonatomic) DownloadViewController       *downloadViewController;
@property (strong, nonatomic) HistoryViewController        *historyViewController;
@property (strong, nonatomic) TrackViewController          *playViewController;
@property (strong, nonatomic) MSettingViewController       *msettingViewController;
@property (assign, nonatomic) BOOL    isPlayed;
@property (assign, nonatomic) BOOL    isStoped;
@property (strong, nonatomic) FMDatabaseQueue *queue;
@property (strong, nonatomic) NSDictionary  *currentPlayInfo;
@property (strong, nonatomic) YTKKeyValueStore  *localStore;

@property (strong, nonatomic) GCNetworkReachability *reachability;
//- (void)play:(NSDictionary *)album track:(NSDictionary *)track;
- (BOOL)play:(NSDictionary *)album track:(NSDictionary *)track target:(id<BABAudioPlayerDelegate>)target slider:(UISlider *)slider;

- (void)jumpToPlayViewController:(NSDictionary *)album;

@end

