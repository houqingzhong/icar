//
//  PlayerView.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"

@interface PlayerView : UITableViewHeaderFooterView

@property(nonatomic, copy) void(^callback)(NSString *, NSString *,PlayerActionType, PlayModeType);

@property(nonatomic, assign) PlayModeType    playModeType;


- (void)setData:(NSDictionary *)album track:(NSDictionary *)track;

- (void)updateProgres:(NSInteger)timePlayed duration:(NSInteger)duration;

- (void)setPlayState:(BOOL)isPlay;

- (CGFloat)sliderValue;

- (BOOL)isScribe;

@end
