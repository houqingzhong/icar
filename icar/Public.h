//
//  Public.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright (c) 2015年 lizhuzhu. All rights reserved.
//

#ifndef icar_Public_h
#define icar_Public_h

#define  kConfigCanDownloadStateChanged             @"kConfigCanDownloadStateChanged"
#define  kConfigCanPlayStateChanged                       @"kConfigCanPlayStateChanged"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define ScreenSize [[UIScreen mainScreen] bounds].size
#define XA ScreenSize.width/640
#define WS(s) __weak typeof (self) s = self

#define HOST @"http://www.zhiyurencai.cn/music/api/"

#define NetworkError @"亲，您的手机网络不太顺畅喔～"
#define NoMoreData @"亲，您已经看到最后一条了喔～"
#define ClearCacheMsg @"亲，您的缓存已经清理完成了喔～"
#define NotAllowedPlayError @"亲，您还没有允许移动网络播放喔～"

#define server_data_cahce  @"server_data_cahce"
#define setting_data_cache @"setting_data_cache"

#define allow_3g_download   @"allow_3g_download"
#define allow_3g_play       @"allow_3g_play"


static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;
static void *kCurrentTimeKVOKey = &kCurrentTimeKVOKey;

typedef enum : NSUInteger {
    DownloadStateDownloadWait = 1,
    DownloadStateDownloadPause,
    DownloadStateDownloading,
    DownloadStateDownloadFinish,
} DownloadState;


typedef enum : NSUInteger {
    ViewContrllerTypeDefault,
    ViewContrllerTypeMenu,
} ViewContrllerType;

typedef enum : NSUInteger {
    ServerDataRequestTypeRecommend,
    ServerDataRequestTypeCategory,
    ServerDataRequestTypeAlbum,
    ServerDataRequestTypeTrack,
} ServerDataRequestType;

typedef enum : NSUInteger {
    PlayTypeLocal,
    PlayTypeOnline,
    PlayTypeSame,
    PlayTypeNetError,
    PlayTypeDataError,
} PlayType;


typedef enum : NSUInteger {
    PlayerActionTypePlay,
    PlayerActionTypeNext,
    PlayerActionTypeChangeTime,
} PlayerActionType;

typedef enum : NSUInteger {
    PlayModeTypeList,
    PlayModeTypeSingle,
    PlayModeTypeLoop,
} PlayModeType;

#define MPageSize 20

#import <JSONKit.h>
#import <FMDB.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <UIScrollView+SVPullToRefresh.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import <YTKKeyValueStore.h>
#import <PYAudioKit.h>
#import <UIColor+MoreColors.h>
//#import <BABAudioPlayer.h>
//#import <BABAudioUtilities.h>
#import <TSMessage.h>
#import <TSMessageView.h>
#import <GCNetworkReachability.h>
#import <JxbPlayer.h>
//#import <DOUAudioStreamer.h>
#import "TableViewSettingList.h"
#import "UIView+Facade.h"
#import "NSString+Extension.h"
#import "UIColor+Hex.h"
#import "NSObject+Extend.h"

#import "DownloadClient.h"
#import "PublicMethod.h"

#import "CategroyView.h"
#import "HttpEngine.h"
#import "BaseCell.h"
#import "AlbumCell.h"
#import "TrackCell.h"
#import "CategoryCell.h"
#import "DownloadingCell.h"
#import "DownloadCell.h"
#import "HistoryCell.h"
#import "ShowDownloadingCell.h"
#import "AddNewDownloadHeaderView.h"
#import "ProgressView.h"
#import "NavPlayButton.h"

//#import "PlayerView.h"
#import "BaseViewController.h"

#import "PlayerViewController.h"

#import "MainPageViewController.h"
#import "LeftSortsViewController.h"
#import "LeftSlideViewController.h"
#import "CategoryViewController.h"
#import "AlbumListViewController.h"
#import "TrackViewController.h"
#import "DownloadViewController.h"
#import "PlayerViewController.h"
#import "HistoryViewController.h"
#import "DownloadingViewController.h"
#import "AboutViewController.h"

#import "MSettingViewController.h"

#import "AppDelegate.h"

#import "SmtaranSDKManager.h"
#import "MobClick.h"
#import "SmtaranBannerAd.h"
#import "SmtaranSplashAd.h"

//#define FMPlayer(s) AudioPlayer *s = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).player

#define App(s) AppDelegate * s = (AppDelegate *)[[UIApplication sharedApplication] delegate]

#endif
