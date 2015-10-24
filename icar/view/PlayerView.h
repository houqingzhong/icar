//
//  PlayerView.h
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"

typedef enum : NSUInteger {
    PlayerActionTypeNext,
} PlayerActionType;

typedef enum : NSUInteger {
    PlayModeTypeList,
    PlayModeTypeSingle,
    PlayModeTypeLoop,
} PlayModeType;

@interface PlayerView : UIView<BABAudioPlayerDelegate>
@property(nonatomic, copy) void(^callback)(PlayerActionType, PlayModeType);


- (void)setData:(NSDictionary *)album track:(NSDictionary *)track;

- (ProgressView *)getProgressView;
@end
