//
//  BackgroundManager.m
//  TestBackGround
//
//  Created by jiangshan zhang on 12-6-18.
//  Copyright (c) 2012年 Youku. All rights reserved.
//

#import "BackgroundManager.h"
#import "MPAudioSession.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#include <sys/sysctl.h>

@interface BackgroundManager ()
{
    AVAudioPlayer * player;
    NSString * audioSessionCategory;
    BackgroundManagerState state;
    UInt32 lastAllowMix;
    NSInteger refer;
}


@end

@implementation BackgroundManager
@synthesize enableSilentDownload;

- (void)createPlayer
{
    NSString * path=[[NSBundle mainBundle] pathForResource:@"mute" ofType:@"mp3"];
    NSURL * url=[NSURL fileURLWithPath:path];
    player=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops=-1;
}

- (void)destroyPlayer
{
    if(player)
    {
        [player stop];
        player=nil;
    }
}

- (id)init
{
    self=[super init];
    if(self)
    {
        enableSilentDownload = YES;
        refer = 0;
    }
    return self;
}

+ (BOOL)supportBackground
{
    return YES;
}

- (NSString *)machine {
    size_t size;
    
    // Set 'oldp' parameter to NULL to get the size of the data
    // returned so we can allocate appropriate amount of space
    sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
    
    // Allocate the space to store name
    char *name = malloc(size);
    
    // Get the platform name
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    // Place name into a string
    NSString *machine = [NSString stringWithUTF8String:name];
    
    // Done with this
    free(name);
    
    return machine;
}
/*
 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 4S/GSM), TBD
 iPhone4,2 ->    (iPhone 4S/CDMA), TBD
 iPhone4,3 ->    (iPhone 4S/???)
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 
 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, WiFi)
 iPad3,2   ->    (iPad 3G, GSM)
 iPad3,3   ->    (iPad 3G, CDMA)
 iPad4,1   ->    (iPad 4G, WiFi)
 iPad4,2   ->    (iPad 4G, GSM)
 iPad4,3   ->    (iPad 4G, CDMA)
 
 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??
 */
-(BOOL)supportDevice{
    //iphone 3gs以后的
    //ipod 3及其以后的
    BOOL rtn = NO;
    NSString * deviceName = [[self machine] lowercaseString];
    if ([deviceName hasPrefix:@"iphone"]) {
        NSMutableString * string = [NSMutableString string];
        [string appendString:[deviceName substringFromIndex:6]];
        if (string.length > 0) {
            [string replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
            if ([string intValue]> 21) {
                rtn = YES;
            }
        }
    }
    if ([deviceName hasPrefix:@"ipod"]) {
        NSMutableString * string = [NSMutableString string];
        [string appendString:[deviceName substringFromIndex:4]];
        if (string.length > 0) {
            [string replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
            if ([string intValue]>= 31) {
                rtn = YES;
            }
        }
    }
    if ([deviceName hasPrefix:@"ipad"]) {
        rtn = YES;
    }

    return rtn;
}
+ (id)sharedManager
{
    static BackgroundManager * manager=nil;
    if(manager==nil)
    {
        manager=[[BackgroundManager alloc] init];
    }
    return manager;
}

- (void)restoreplayIfNeed{
    
    if (state == BackgroundManagerStateStart) {
        [player play];
    }
}

- (void)beginBackgroundMode
{
    if([BackgroundManager supportBackground] && [self supportDevice])
    {
        if (state != BackgroundManagerStateStart) {
            [self enableBackground:YES];
        }
    }
}

- (void)enableBackground:(BOOL)enable
{
    if (enable) {
        if (refer == 0) {
            [[MPAudioSession sharedInstance] setActive:YES];
            [self createPlayer];
            [player play];
            
            state = BackgroundManagerStateStart;
        }
        refer ++;
        
    } else {
        refer--;
        if (refer == 0) {
            [[MPAudioSession sharedInstance] setActive:NO];
            [self destroyPlayer];
            
            state = BackgroundManagerStateEnd;
        }
        if (refer < 0) {
            refer = 0;
        }
    }

}

- (void)endBackgroundMode
{

    if([BackgroundManager supportBackground] && [self supportDevice])
    {
        if (state == BackgroundManagerStateStart) {
            [self enableBackground:NO];
        }
    }
}

- (void)dealloc
{
    [self endBackgroundMode];
    [self destroyPlayer];
}

@end
