//
//  AddNewDownloadHeaderView.h
//  icar
//
//  Created by 调伏自己 on 15/10/22.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewDownloadHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) void (^callback)();

- (void)setData:(NSDictionary *)dict;

@end
