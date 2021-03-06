//
//  TrackCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "TrackCell.h"
#import "Public.h"

@interface TrackCell()
{
    UIButton    *_icon;
    UILabel     *_title;
    UILabel     *_duration;
    
    UIProgressView     *_playProgress;
}

@end

@implementation TrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;
        _icon = [UIButton new];
        _title = [UILabel new];
        _duration = [UILabel new];

        _playProgress.progress = 0.3;
        [_playProgress setProgressTintColor:[UIColor colorWithHexString:@"#ff7d3d"]];
        
        _title.font = [UIFont systemFontOfSize:24*XA];
        _duration.font = [UIFont systemFontOfSize:16*XA];
        _duration.textColor = [UIColor colorWithHexString:@"#959595"];
        [_icon setImage:[UIImage imageNamed:@"download_location"] forState:UIControlStateNormal];
        [_icon addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_icon];
        [self addSubview:_title];
        [self addSubview:_duration];
        [self addSubview:_playProgress];
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
    
    CGFloat width = ScreenSize.width - 2*leftPadding - 100*XA;
    
    CGFloat height = 30*XA;

    [_title anchorTopLeftWithLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    
    height = 20*XA;

    [_duration anchorBottomLeftWithLeftPadding:leftPadding bottomPadding:topPadding width:width height:height];

    
    height = CGRectGetHeight(self.frame);
    width = height;

    [_icon anchorCenterRightWithRightPadding:leftPadding width:width height:height];
    
    topPadding = leftPadding = (height - 60*XA)/2;
    _icon.imageEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding+10*XA, topPadding, leftPadding-10*XA);
    
    [_playProgress anchorBottomCenterFillingWidthWithLeftAndRightPadding:0 bottomPadding:0 height:0.5];
    
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

    if ([dict[@"download_state"] integerValue] == DownloadStateDownloadFinish) {
        [_icon setTitle:nil forState:UIControlStateNormal];
        [_icon setImage:[UIImage imageNamed:@"btn_downloaded"] forState:UIControlStateNormal];//download_location

        _playProgress.progress = 1;
        _playProgress.hidden = YES;
    }
    else if ([dict[@"download_state"] integerValue] == DownloadStateDownloading)
    {
        [_icon setImage:nil forState:UIControlStateNormal];
        [_icon setTitle:@"下载中" forState:UIControlStateNormal];
        [_icon.titleLabel setTextColor:[UIColor colorWithHexString:@"#ff7d3d"]];

        _playProgress.hidden = NO;
    }
    else
    {
        
        [_icon setTitle:nil forState:UIControlStateNormal];
        [_icon setImage:[UIImage imageNamed:@"download_location"] forState:UIControlStateNormal];
        _playProgress.hidden = NO;
        _playProgress.progress = [dict[@"progress"] floatValue];
    }
}


- (void)updateTime:(NSTimeInterval)time
{
    
    _duration.text = [NSString stringWithFormat:@"%@/%@", [NSObject getDurationText:time], [NSObject getDurationText:[_dict[@"duration"] floatValue]]];
    
    [self setNeedsLayout];
    
}


+ (CGFloat)height:(NSDictionary *)dict
{
    return 100 * XA;
}


- (void)click
{
    if (_callback) {
        [_icon setImage:[UIImage imageNamed:@"btn_downloaded"] forState:UIControlStateNormal];
        _callback(_dict);
    }
        
}
@end
