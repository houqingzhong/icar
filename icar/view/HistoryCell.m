//
//  HistoryCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/22.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "HistoryCell.h"
#import "Public.h"

@interface HistoryCell()
{
    UIImageView *_header;
    UILabel     *_title;
    UILabel     *_playTime;

    UILabel     *_localIcon;
}
@end

@implementation HistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;
        _header = [UIImageView new];
        _localIcon = [UILabel new];

        _title = [UILabel new];
        _playTime = [UILabel new];
        
        
        _title.textAlignment = NSTextAlignmentLeft;
        _localIcon.backgroundColor = [UIColor colorWithHexString:@"#ff7d3d"];
        _localIcon.font = [UIFont systemFontOfSize:22*XA];
        _title.font = [UIFont systemFontOfSize:28*XA];
        _title.textColor = [UIColor colorWithHexString:@"#333333"];
        _playTime.font = [UIFont systemFontOfSize:22*XA];
        _playTime.textColor = [UIColor colorWithHexString:@"#959595"];
        _localIcon.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _localIcon.text = @"本地";
        
        [self addSubview:_header];
        [self addSubview:_title];
        [self addSubview:_playTime];
        [_header addSubview:_localIcon];
        
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
    CGFloat leftPadding = 8*XA;
    CGFloat topPadding = 8*XA;
    CGFloat width = 120* XA;
    CGFloat height = width;
    [_header anchorTopLeftWithLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    
    topPadding = (20 + 8)*XA;
    leftPadding = 20*XA;
    width = ScreenSize.width - _header.xMax - 2*leftPadding;
    height = 28*XA;

    [_title alignToTheRightOf:_header matchingCenterWithLeftPadding:leftPadding width:width height:height];
    
    topPadding = 10*XA;
    CGSize  size = [_playTime.text sizeWithFont:_playTime.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    width = size.width;
    height = size.height;
    [_playTime alignUnder:_title withRightPadding:leftPadding topPadding:topPadding width:width height:height];
 
    size = [_localIcon.text sizeWithFont:_localIcon.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    width = size.width+5*XA;
    height = size.height+5*XA;
    [_localIcon anchorBottomRightWithRightPadding:0 bottomPadding:0 width:width height:height];
}

- (void)setData:(NSDictionary *)dict
{
    self.dict = dict;
    
    if(![NSObject isNull:dict[@"cover_url"]]){
        [_header setImageWithURL:[NSURL URLWithString:dict[@"cover_url"]] placeholderImage:[UIImage imageNamed:@"album_cover_bg"]];
    }
    else
    {
        [_header setImage:[UIImage imageNamed:@"album_cover_bg"]];
    }
    
    _title.text = dict[@"track"][@"title"];
    _playTime.text = [NSString stringWithFormat:@"%@/%@", [NSObject getDurationText:[dict[@"track"][@"time"] floatValue]], [NSObject getDurationText:[dict[@"track"][@"duration"] floatValue]]];
    
    if ([dict[@"track"][@"download_state"] integerValue] == DownloadStateDownloadFinish) {
        _localIcon.text = @"本地";
    }
    else if ([dict[@"track"][@"download_state"] integerValue] > 0)

    {
        _localIcon.text = @"下载中";
    }
    else
    {
        _localIcon.text = @"在线";
    }

    [self setNeedsLayout];
    
}

- (void)updateTime:(NSTimeInterval)time
{
    //_playTime.text = [NSObject getDurationText:time];
    
    _playTime.text = [NSString stringWithFormat:@"%@/%@", [NSObject getDurationText:time], [NSObject getDurationText:[_dict[@"track"][@"duration"] floatValue]]];

    
}

@end
