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

- (void)updateList:(NSDictionary *)dict  pageNum:(NSInteger)pageNum;

- (PlayType)play:(NSDictionary *)album track:(NSDictionary *)track;

- (PlayModeType)getPlayMode;
@end
