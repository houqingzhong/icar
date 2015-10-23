//
//  HistoryCell.h
//  icar
//
//  Created by lizhuzhu on 15/10/22.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "BaseCell.h"

@interface HistoryCell : BaseCell

@property (nonatomic, strong) NSDictionary *dict;

- (void)updateTime:(NSTimeInterval)time;


@end
