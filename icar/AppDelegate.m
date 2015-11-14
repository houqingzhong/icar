//
//  AppDelegate.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright (c) 2015年 lizhuzhu. All rights reserved.
//

#import "AppDelegate.h"
#import "Public.h"
#import <AVFoundation/AVAudioSession.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>

#define dataBaseName @"music.sqlite"
#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName]

@interface AppDelegate ()<SmtaranSplashAdDelegate>
@end

@implementation AppDelegate

- (void)setup
{
    //1. 设置导航栏的背景图片
    UINavigationBar *bar=[UINavigationBar appearance];
    //[bar setBackgroundImage:[UIImage imageNamed:@"navigationbar_background.png"] forBarMetrics:UIBarMetricsDefault];
    [bar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar_background.png"]]];
    bar.barStyle = UIStatusBarStyleDefault;
    //1.2 设置返回按钮的颜色  在plist中添加 View controller-based status bar appearance=NO切记。
    [bar setTintColor:[UIColor whiteColor]];
    //	//设置返回按钮指示器图片
    //	UIImage *backImage=[[UIImage imageNamed:@"navigationbar_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 5)];
    //	[[UINavigationBar appearance] setBackIndicatorImage:backImage];
    //	[[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"navigationbar_back_highlighted"]];
    //
    //2. 设置导航栏文字的主题
    [bar setTitleTextAttributes:@{
                                  NSForegroundColorAttributeName:[UIColor blackColor],
                                  }];
    //3. 设置UIBarButtonItem的外观
    UIBarButtonItem *barItem=[UIBarButtonItem appearance];
    [barItem setBackgroundImage:[UIImage imageNamed:@"navigationbar_button_background.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barItem setBackgroundImage:[UIImage imageNamed:@"navigationbar_button_background_pushed.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    //4. 该item上边的文字样式
    NSDictionary *fontDic=@{
                            NSForegroundColorAttributeName:[UIColor whiteColor],
                            NSFontAttributeName:[UIFont systemFontOfSize:30*XA],  //粗体
                            };
    [barItem setTitleTextAttributes:fontDic
                           forState:UIControlStateNormal];
    [barItem setTitleTextAttributes:fontDic
                           forState:UIControlStateHighlighted];
    // 5.设置状态栏样式
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    self.queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    
    [_queue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"history"]) {
            if ([db executeUpdate:@"CREATE TABLE history (id INTEGER PRIMARY KEY AUTOINCREMENT, album_id INTEGER, track_id INTEGER, album_info text, track_info text, time DOUBLE, timestamp INTEGER)"]) {
                NSLog(@"create table success:download");
            }else{
                NSLog(@"fail to create table:history");
            }
        }else {
            NSLog(@"table is already exist:history");
        }
        
        if (![db tableExists:@"download"]) {
            if ([db executeUpdate:@"CREATE TABLE download (id INTEGER PRIMARY KEY AUTOINCREMENT, album_id INTEGER, track_id INTEGER, album_info text, track_info text, progress DOUBLE, download_state INTEGER default 0, timestamp INTEGER)"]) {
                NSLog(@"create table success:download");
            }else{
                NSLog(@"fail to create table:download");
            }
        }else {
            NSLog(@"table is already exist:download");
        }
    }];
    
    [[TSMessageView appearance] setTintColor:[UIColor colorWithHexString:@"ff7d3d"]];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    self.reachability = [GCNetworkReachability reachabilityForInternetConnection];
    [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
        switch (status) {
            case GCNetworkReachabilityStatusWWAN:
                NSLog(@"-------GCNetworkReachabilityStatusWWAN------");
                [[DownloadClient sharedInstance] startDownload];
                break;
                
            case GCNetworkReachabilityStatusWiFi:
                NSLog(@"-------GCNetworkReachabilityStatusWiFi------");
                [[DownloadClient sharedInstance] startDownload];
                break;
            case GCNetworkReachabilityStatusNotReachable:
                NSLog(@"-------GCNetworkReachabilityStatusNotReachable------");
                [[DownloadClient sharedInstance] stopDownload:^(BOOL finshed) {
                    
                }];
                
                break;
            default:
                break;
        }
    }];
    
    
//    BABAudioPlayer *player = [BABAudioPlayer new];
//    player.allowsBackgroundAudio = YES;
//    [BABAudioPlayer setSharedPlayer:player];
    
    self.localStore = [[YTKKeyValueStore alloc] initDBWithName:@"local-key-value"];
    NSString *tableName = server_data_cahce;
    [_localStore createTableWithName:tableName];
    
    tableName = setting_data_cache;
    [_localStore createTableWithName:tableName];

}

- (void)startDownload
{
    [[DownloadClient sharedInstance] clearOnLanch];
    
    if ([[DownloadClient sharedInstance] hasNetwork]) {
        [[DownloadClient sharedInstance] startDownload];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //5644382e67e58e6eac00084e
    [MobClick startWithAppkey:@"5644382e67e58e6eac00084e" reportPolicy:BATCH channelId:@"App Store"];
    [self setup];
    [self startDownload];
    
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"车载音乐台" auditFlag:MS_Audit_Flag];
    
    _playViewController = [PlayerViewController new];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];   //设置通用背景颜色
    //[self.window makeKeyAndVisible];
        
    MainPageViewController *mainVC = [[MainPageViewController alloc] init];
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
    self.leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainNavigationController];
    
    
    //信息流开屏广告(信息流广告模拟开屏效果)
    SmtaranSplashAd *sadVC = [[SmtaranSplashAd alloc] initWithSlottoken:MS_Poster delegate:self rootVC:self.leftSlideVC currentWindow:self.window];
    self.window.rootViewController = sadVC;
    
    //self.window.rootViewController = self.leftSlideVC;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#ff7d3d"]];

    
    return YES;
}
/**
 *  adSplash被点击
 *  @param adSplash
 */
- (void)smtaranSplashAdClick:(nonnull SmtaranSplashAd*)adSplash
{
    NSLog(@"%s", __func__);
}

/**
 *  adSplash请求成功并展示广告
 *  @param adSplash
 */
- (void)smtaranSplashAdSuccessToShowAd:(nonnull SmtaranSplashAd*)adSplash
{
    NSLog(@"%s", __func__);
}

/**
 *  adSplash请求失败
 *  @param adSplash
 */
- (void)smtaranSplashAdFaildToShowAd:(nonnull SmtaranSplashAd*)adSplash withError:(nullable NSError*) error
{
    NSLog(@"%s", __func__);
}

/**
 *  AdSplash被关闭
 *  @param adSplash
 */
- (void)smtaranSplashAdClose:(nonnull SmtaranSplashAd*)adSplash
{
    NSLog(@"%s", __func__);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSLog(@"downlaod  completionHandler");
    
    [[DownloadClient sharedInstance] setCompleteHandler:completionHandler identifier:identifier];
    
}



//- (void)playerDidFinishPlaying
//{
//    [[SCLTAudioPlayer sharedPlayer] play];
//}

- (void) interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = (NSUInteger)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    if(interuptionType == AVAudioSessionInterruptionTypeBegan)
        [self beginInterruption];
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded)
        [self endInterruption];
}

- (void)beginInterruption {
    
//    [_player pause];
    
}

- (void)endInterruption {
//    [_player play];
}


- (void)updateTrackProgress
{

}

-(void)configNowPlayingInfoCenter:(NSDictionary *)info
{
    
    if (!info) {
        return;
    }
    
//    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
//        
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        
//        if (info[@"track"][@"title"]) {
//            dict[MPMediaItemPropertyArtist] = info[@"track"][@"title"];
//        }
//        if (info[@"track"][@"albumTitle"]) {
//            dict[MPMediaItemPropertyAlbumTitle] = info[@"track"][@"albumTitle"];
//        }
//        
//        MPMediaItemArtwork *mArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"icon"]];
//        dict[MPMediaItemPropertyArtwork] = mArt;
//        
//        dict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(_player.currentTime);
//        dict[MPMediaItemPropertyPlaybackDuration] = @(_player.duration-_player.currentTime);
//        
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//        
//    }
    
}

//- (void)updateStatus
//{
//    App(app);
//    switch (app.player.status) {
//        case DOUAudioStreamerPlaying:
//            
//            break;
//            
//        case DOUAudioStreamerPaused:
//            
//            break;
//            
//        case DOUAudioStreamerIdle:
//            
//            break;
//            
//        case DOUAudioStreamerFinished:
//            [_player play];
//            break;
//            
//        case DOUAudioStreamerBuffering:
//            
//            break;
//            
//        case DOUAudioStreamerError:
//            
//            break;
//    }
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"status"]) {
//        [self performSelector:@selector(updateStatus)
//                     onThread:[NSThread mainThread]
//                   withObject:nil
//                waitUntilDone:NO];
//    }
//    else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

@end
