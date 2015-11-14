//
//  PlayerViewController.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"

@interface PlayerViewController : BaseViewController

@property(nonatomic, copy) void(^callback)(CGFloat progress, NSDictionary *album, NSDictionary *track);

@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic, strong) NSDictionary *track;

- (void)updateList:(NSDictionary *)album track:(NSDictionary *)track;

- (BOOL)isPlaying;
@end
