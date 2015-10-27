//
//  MPAudioSession.m
//  YoukuCore
//
//  Created by flexih on 1/8/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import "MPAudioSession.h"
#import <libkern/OSAtomic.h>

@interface MPAudioSession ()

@property (nonatomic) NSInteger refer;

@end

@implementation MPAudioSession
@dynamic active;

+ (MPAudioSession *)sharedInstance
{
    static MPAudioSession *audio_session = nil;
    if (audio_session == nil) {
        audio_session = [[super allocWithZone:NULL] init];
    }
    return audio_session;
}

- (void)setActive:(BOOL)active
{
//    if (active) {
//        if (_refer == 0) {
//            [[AVAudioSession sharedInstance]
//                setCategory:AVAudioSessionCategoryPlayback
//                      error:nil];
//            [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        }
//        
//        ++_refer; //OSAtomicIncrement32(&_refer);
//        
//    } else {
//        --_refer; //OSAtomicDecrement32(&_refer);
//        
//        if (_refer == 0) {
//            [[AVAudioSession sharedInstance]
//                setCategory:AVAudioSessionCategorySoloAmbient
//                      error:nil];
//            [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        } else if (_refer < 0) {
//            _refer = 0;
//        }
//    }
}

- (BOOL)isActive
{
    return _refer > 0;
}

@end
