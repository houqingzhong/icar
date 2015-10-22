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
@property (nonatomic, strong) NSDictionary *dict;
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
        [_playProgress setProgressTintColor:[UIColor colorWithHexString:@"#ff7d3d" alpha:0.8]];
        
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

    if(dict[@"download_state"])
    {
        [_icon setImage:[UIImage imageNamed:@"btn_downloaded"] forState:UIControlStateNormal];        
    }
    else
    {
        [_icon setImage:[UIImage imageNamed:@"download_location"] forState:UIControlStateNormal];
    }

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
