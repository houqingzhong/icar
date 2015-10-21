//
//  CategroyView.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "CategroyView.h"
#import "Public.h"

@interface CategroyView()
{
    UIButton    *_icon;
    UIButton     *_title;
}

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation CategroyView

- (instancetype)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        
        _icon = [UIButton new];
        _title = [UIButton new];

        [_title setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_title.titleLabel setFont:[UIFont systemFontOfSize:20*XA]];
        
        [self addSubview:_icon];
        [self addSubview:_title];

        [_title addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [_icon addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = [_dict[@"title"] sizeWithFont:[UIFont systemFontOfSize:20*XA] maxSize:CGSizeMake(108*XA, 30)];

    CGFloat width = 108*XA;
    CGFloat height = width;
    [_icon anchorTopLeftWithLeftPadding:0 topPadding:0 width:width height:height];
    [_title alignUnder:_icon centeredFillingWidthWithLeftAndRightPadding:0 topPadding:10*XA height:size.height];
    
}

- (void)setData:(NSDictionary *)dict
{
    self.dict = dict;
    [_icon setImage:[UIImage imageNamed:dict[@"icon"]] forState:UIControlStateNormal];

    
    [_title setTitle:dict[@"title"] forState:UIControlStateNormal];
}

+ (CGFloat)height:(NSDictionary *)dict
{
    NSString *text = dict[@"title"];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:20*XA] maxSize:CGSizeMake(108*XA, 30)];
    return 108*XA + size.height + 10*XA;
}


- (void)click
{
    if (_callback) {
        _callback(_dict);
    }
}
@end
