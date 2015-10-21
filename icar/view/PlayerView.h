//
//  PlayerView.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PlayerActionTypeNext,
} PlayerActionType;

typedef enum : NSUInteger {
    PlayModeTypeList,
    PlayModeTypeSingle,
    PlayModeTypeLoop,
} PlayModeType;

@interface PlayerView : UIView
@property(nonatomic, copy) void(^callback)(PlayerActionType, PlayModeType);

- (void)setAlbum:(NSDictionary *)album track:(NSDictionary *)track;

- (void)setData:(NSDictionary *)dict album:(NSDictionary *)album time:(NSTimeInterval)time;

@end
