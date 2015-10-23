//
//  TrackViewController.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface TrackViewController : BaseViewController

- (void)updateList:(NSDictionary *)dict  pageNum:(NSInteger)pageNum;

@end
