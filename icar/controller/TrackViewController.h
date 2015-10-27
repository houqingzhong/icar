//
//  TrackViewController.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Public.h"

@interface TrackViewController : BaseViewController
@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic, strong) NSDictionary *track;
@property (nonatomic, strong) NSMutableDictionary  *playingInfo;

- (void)updateList:(NSDictionary *)album  pageNum:(NSInteger)pageNum;
- (void)updateList:(NSDictionary *)album localArray:(NSArray *)localArray pageNum:(NSInteger)pageNum;

- (PlayType)play:(NSDictionary *)album track:(NSDictionary *)track;

- (PlayModeType)getPlayMode;
@end
