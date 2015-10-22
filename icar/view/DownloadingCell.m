//
//  DownloadingCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadingCell.h"

#import "Public.h"

@interface DownloadingCell()
{
    UILabel     *_title;
    UILabel     *_duration;
    UILabel     *_separator;
    UIButton    *_icon;

    UIProgressView     *_playProgress;
}

@end

@implementation DownloadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;

        self.backgroundColor = [UIColor clearColor];
        
        _title = [UILabel new];
        _duration = [UILabel new];
        _separator = [UILabel new];
        _icon = [UIButton new];

        _playProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        
        _playProgress.progress = 0.0;
        [_playProgress setProgressTintColor:[UIColor colorWithHexString:@"#ff7d3d" alpha:0.3]];
        
        _title.font = [UIFont systemFontOfSize:24*XA];
        _duration.font = [UIFont systemFontOfSize:16*XA];
        _duration.textColor = [UIColor colorWithHexString:@"#959595"];
        
        
        [_icon setImage:[UIImage imageNamed:@"download_location"] forState:UIControlStateNormal];
        [_icon addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        _title.backgroundColor = [UIColor clearColor];
        _duration.backgroundColor = [UIColor clearColor];
        _separator.backgroundColor = [UIColor colorWithHexString:@"#959595"];
        
        _separator.alpha = 0.3;
        
        [self addSubview:_icon];

        [self addSubview:_title];
        [self addSubview:_duration];
        [self addSubview:_playProgress];
        [self addSubview:_separator];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)layout
{
    CGFloat leftPadding = 20*XA;
    CGFloat topPadding = 20*XA;
    
    CGFloat width = ScreenSize.width - 2*leftPadding;
    
    CGFloat height = 30*XA;
    
    width = ScreenSize.width-leftPadding - 100*XA;

    [_title anchorTopLeftWithLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    
    height = 20*XA;
    
    CGSize size = [_duration.text sizeWithFont:_duration.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), height)];
    width = size.width;

    [_duration anchorBottomLeftWithLeftPadding:leftPadding bottomPadding:topPadding width:width height:height];
    
    height = CGRectGetHeight(self.frame);
    width = height;
    
    [_icon anchorCenterRightWithRightPadding:leftPadding width:width height:height];
    
    topPadding = leftPadding = (height - 60*XA)/2;
    _icon.imageEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding+10*XA, topPadding, leftPadding-10*XA);
    
    
    height = 30*XA;
    width = (ScreenSize.width - leftPadding) *_playProgress.progress;
    [_playProgress anchorBottomLeftWithLeftPadding:leftPadding bottomPadding:1.5 width:width height:0.5];

    
    width = ScreenSize.width-leftPadding;
    [_separator anchorBottomLeftWithLeftPadding:leftPadding bottomPadding:0 width:width height:0.5];

}

- (void)setData:(NSDictionary *)dict
{
    
    self.dict = dict;
    
    _title.text = dict[@"title"];
    
    CGFloat duration = [dict[@"duration"] floatValue];
    
    
    if (duration < 60) {
        _duration.text = [NSString stringWithFormat:@"00:00:%02.0f", duration];
    }
    else if(duration/60 < 60)
    {
        CGFloat sec = (NSInteger)duration%60;
        CGFloat min = duration/60;
        _duration.text = [NSString stringWithFormat:@"00:%02.0f:%02.0f", min, sec];
    }
    else if(duration/3600 > 0)
    {
        CGFloat hour = (NSInteger)duration/3600;
        
        duration = (NSInteger)duration%3600;
        
        if(duration/60 < 60)
        {
            CGFloat sec = (NSInteger)duration%60;
            CGFloat min = duration/60;
            _duration.text = [NSString stringWithFormat:@"%02.0f:%02.0f:%02.0f", hour, min, sec];
        }
        
    }
    
    _duration.text = [NSString stringWithFormat:@"时长：%@", _duration.text];
    
    if(dict[@"download_state"])
    {
        [_icon setImage:[UIImage imageNamed:@"btn_downloaded"] forState:UIControlStateNormal];
    }
    else
    {
        [_icon setImage:[UIImage imageNamed:@"download_location"] forState:UIControlStateNormal];
    }
    
    if ([dict[@"download_state"] integerValue] == DownloadStateDownloadFinish) {
        _playProgress.progress = 1;
    }
    else
    {
        _playProgress.progress = [dict[@"progress"] floatValue];
    }
    
    [self setNeedsLayout];
    
}

- (void)setProgress:(CGFloat )progress
{
    _playProgress.progress = progress;
    
    [self setNeedsLayout];
}

+ (CGFloat)height:(NSDictionary *)dict
{
    return 100 * XA;
}

- (void)click
{
    if (_callback) {
        [_icon setImage:[UIImage imageNamed:@"finished_flag"] forState:UIControlStateNormal];
        _callback(_dict);
    }
    
}

@end
