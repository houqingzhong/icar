//
//  AddNewDownloadHeaderView.m
//  icar
//
//  Created by 调伏自己 on 15/10/22.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "AddNewDownloadHeaderView.h"
#import "Public.h"

@interface AddNewDownloadHeaderView()
{
    UIImageView *_icon;
    UILabel          *_titleLabel;
    UILabel          *_seperator;
}
@end

@implementation AddNewDownloadHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _seperator = [UILabel new];
        _icon = [UIImageView new];
        _titleLabel = [UILabel new];
        
        _titleLabel.font = [UIFont systemFontOfSize:30*XA];
        _titleLabel.text = @"添加更多";
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _seperator.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        
        [_icon setImage:[UIImage imageNamed:@"download_addmore_icon"]];
        
        [self addSubview:_icon];
        [self addSubview:_titleLabel];
        [self addSubview:_seperator];
        
        
        UITapGestureRecognizer *oneFingerTwoTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
        
        [self addGestureRecognizer:oneFingerTwoTaps];
    }
    
    return self;
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 1) {
        if (_callback) {
            _callback();
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layout];
}

- (void)layout
{
    
    CGFloat left  = 20*XA;
    CGFloat width = 40*XA;
    CGFloat height = 40*XA;
    [_icon anchorCenterLeftWithLeftPadding:left width:width height:height];
    
    width = CGRectGetWidth(self.frame) - _icon.xMax - 3*left;
    [_titleLabel alignToTheRightOf:_icon matchingCenterAndFillingWidthWithLeftAndRightPadding:left height:30*XA];
    
    [_seperator anchorBottomCenterFillingWidthWithLeftAndRightPadding:0 bottomPadding:0 height:1*XA];
}

- (void)setData:(NSDictionary *)dict
{
    
    _titleLabel.text = dict[@"title"];
    
    [self setNeedsLayout];
}

@end
