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

#define dataBaseName @"music.sqlite"
#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];
    
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

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];   //设置通用背景颜色
    [self.window makeKeyAndVisible];
    
    MainPageViewController *mainVC = [[MainPageViewController alloc] init];
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
    self.leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainNavigationController];
    self.window.rootViewController = self.leftSlideVC;
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#ff7d3d"]];

    [[DownloadClient sharedInstance] clearOnLanch];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
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

- (void)play:(NSDictionary *)album track:(NSDictionary *)track target:(id<BABAudioPlayerDelegate>)target slider:(UISlider *)slider
{
    if (!album || !track) {
        return;
    }
    
    [PublicMethod saveHistory:album track:track callback:nil];
    
    
    if (![NSObject isNull:track[@"play_path_32"]]) {
        
        if (nil == [BABAudioPlayer sharedPlayer]) {
            BABAudioPlayer *player = [BABAudioPlayer new];
            [BABAudioPlayer setSharedPlayer:player];
            
        }
        
        BOOL isLocal = YES;
        NSURL *url = [[DownloadClient sharedInstance] getDownloadFile:album track:track];
        
        if (nil == url) {
            url = [NSURL URLWithString:track[@"play_path_32"]];
            isLocal = NO;
        }
        
        BABAudioItem *item = [BABAudioItem audioItemWithURL:url];
        [item setLocal:isLocal];
        [[BABAudioPlayer sharedPlayer] queueItem:item];
        
    }
    
    
    [BABAudioPlayer sharedPlayer].delegate = target;
    
    BABConfigureSliderForAudioPlayer(slider, [BABAudioPlayer sharedPlayer]);
    
    App(app);
    
    if(!app.isStoped)
    {
        
        self.currentPlayInfo = @{@"album":album, @"track":track};
        
        [PublicMethod getHistoryTrack:track[@"id"] callback:^(NSDictionary * localTrack) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (localTrack) {
                    
                    float value = [localTrack[@"time"] doubleValue]/[track[@"duration"] floatValue];
                    
                    
                    [[BABAudioPlayer sharedPlayer] seekToPercent:value];
                    
                    slider.value = value;
                    
                    
                }
                else
                {
                    [[BABAudioPlayer sharedPlayer] play];
                }
                
                app.isPlayed = YES;
                
            });
            
        }];
    }
    
}

/*
- (void)play:(NSDictionary *)album track:(NSDictionary *)track
{
    if (!album || !track) {
        return;
    }
    
    [PublicMethod saveHistory:album track:track callback:nil];
    
    
    if (![NSObject isNull:track[@"play_path_32"]]) {
    
        AFSoundItem *playItem = nil;
        if ([[DownloadClient sharedInstance] isFileDownloaded:album[@"id"] trackId:track[@"id"]]) {;
            NSString *filePath = [[DownloadClient sharedInstance] getDownloadPath:album];
            playItem = [[AFSoundItem alloc] initWithLocalResource:[NSString stringWithFormat:@"%@.m4a", track[@"id"]] atPath:filePath];
        }
        else
        {

            playItem = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:track[@"play_path_32"]]];
        
        }

        if (nil == self.player) {
            self.player = [[AFSoundPlayback alloc] init];
        }
        
        [self.player playItem:playItem];

        
    }
    
    if(!self.isStoped)
    {
        
        self.currentPlayInfo = @{@"album":album, @"track":track};
        
        [PublicMethod getHistoryTrack:track[@"id"] callback:^(NSDictionary * localTrack) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (localTrack) {
                    
                    NSTimeInterval value = [localTrack[@"time"] doubleValue]/[track[@"duration"] doubleValue];
                    
                    [self.player playAtSecond:(NSInteger)value];

                }

                [self.player play];
                
                self.isPlayed = YES;
                
            });
            
        }];
    }
}
*/
@end
