//
//  CategoryCell.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

@property(nonatomic, copy) void(^callback)(NSDictionary*);

- (void)setData:(NSArray *)arr;

+ (CGFloat)height:(NSDictionary *)dict;
@end
