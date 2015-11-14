//
//  TrackCell.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface TrackCell : BaseCell

@property(nonatomic, copy) void(^callback)(NSDictionary*);
@property (nonatomic, strong) NSDictionary *dict;

- (void)updateTime:(NSTimeInterval)time;

+ (CGFloat)height:(NSDictionary *)dict;

@end
