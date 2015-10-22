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


#import <JSONKit.h>
#import <FMDB.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <AFSoundManager.h>
#import "PublicMethod.h"
#import "UIView+Facade.h"
#import "NSString+Extension.h"
#import "UIColor+Hex.h"
#import "NSObject+Extend.h"

#import "DownloadClient.h"

#import "CategroyView.h"
#import "HttpEngine.h"
#import "BaseCell.h"
#import "AlbumCell.h"
#import "TrackCell.h"
#import "CategoryCell.h"
#import "DownloadingCell.h"
#import "DownloadCell.h"

#import "ProgressView.h"
#import "NavPlayButton.h"

#import "PlayerView.h"

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

#import "AppDelegate.h"

//#define FMPlayer(s) AudioPlayer *s = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).player

#define App(s) AppDelegate * s = (AppDelegate *)[[UIApplication sharedApplication] delegate]

#endif
