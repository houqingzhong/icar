//
//  CategroyView.h
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategroyView : UIView

@property(nonatomic, copy) void(^callback)(NSDictionary*);

- (void)setData:(NSDictionary *)dict;

+ (CGFloat)height:(NSDictionary *)dict;

@end
