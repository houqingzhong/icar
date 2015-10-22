//
//  ShowDownloadingCell.m
//  icar
//
//  Created by 调伏自己 on 15/10/22.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "ShowDownloadingCell.h"
#import "Public.h"

@interface ShowDownloadingCell()
{
    UIImageView *_icon;
    UILabel          *_showLabel;
    UILabel          *_titleLabel;
    UILabel          *_sizeLable;
    UIProgressView          *_progressView;
    UILabel          *_seperator;

}
@end

@implementation ShowDownloadingCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];

        _icon = [UIImageView new];
        _titleLabel = [UILabel new];
        _showLabel = [UILabel new];
        _showLabel.text = @"正在缓存";
        _sizeLable = [UILabel new];
        _progressView = [UIProgressView new];
        
        _showLabel.font = [UIFont systemFontOfSize:30*XA];
        _showLabel.textColor = [UIColor colorWithHexString:@"#333333"];

        
        _sizeLable.font = [UIFont systemFontOfSize:22*XA];
        _sizeLable.textColor = [UIColor colorWithHexString:@"#959595"];

        _titleLabel.font = [UIFont systemFontOfSize:22*XA];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#959595"];

        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.progress = 0.0;
        [_progressView setProgressTintColor:[UIColor colorWithHexString:@"#ff7d3d" alpha:0.9]];
        
        [_icon setImage:[UIImage imageNamed:@"download_file_icon"]];

        [self addSubview:_icon];
        [self addSubview:_showLabel];
        [self addSubview:_titleLabel];
        [self addSubview:_sizeLable];
        [self addSubview:_progressView];
        
        _seperator = [UILabel new];
        
        _seperator.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        
        [self addSubview:_seperator];
        
        
        UITapGestureRecognizer *oneFingerTwoTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
        
        [self addGestureRecognizer:oneFingerTwoTaps];

    }
    
    return self;
}


- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 1) {
        NSLog(@"click");
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layout];
}

- (void)layout
{
    
    CGFloat left  = 20*XA;
    CGFloat top  = 20*XA;
    CGFloat width = 60*XA;
    CGFloat height = 60*XA;
    [_icon anchorCenterLeftWithLeftPadding:left width:width height:height];
    
    [_showLabel alignToTheRightOf:_icon fillingWidthWithLeftAndRightPadding:left topPadding:top height:30*XA];
    
    top = 10*XA;
    CGSize size = [_sizeLable.text sizeWithFont:_sizeLable.font maxSize:CGSizeMake(_showLabel.width, _showLabel.height)];
    width =size.width;
    height =size.height;
    [_sizeLable alignUnder:_showLabel matchingRightWithTopPadding:top width:width height:height];

    width = CGRectGetWidth(self.frame) - _icon.xMax - _sizeLable.width - 2*left;
    [_titleLabel alignUnder:_showLabel matchingLeftWithTopPadding:top width:width height:height];
    
    top = 15*XA;
    height = 1*XA;
    [_progressView alignUnder:_titleLabel matchingLeftWithTopPadding:top width:_showLabel.xMax - _icon.xMax - left height:height];
    
    [_seperator anchorBottomCenterFillingWidthWithLeftAndRightPadding:0 bottomPadding:0 height:1*XA];
    
}

- (void)setData:(NSDictionary *)dict
{

    _sizeLable.text = [NSString stringWithFormat:@"%0.2f%%", [dict[@"progress"] floatValue]*100];
    _titleLabel.text = dict[@"title"];
    
    _progressView.progress = [dict[@"progress"] floatValue];
    
    [self setNeedsLayout];
}


@end
