//
//  MPAudioSession.h
//  YoukuCore
//
//  Created by flexih on 1/8/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface MPAudioSession : NSObject

@property (nonatomic, getter = isActive) BOOL active;

+ (MPAudioSession *)sharedInstance;

@end
