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
    UIImageView *_icon;
    UILabel     *_title;
    UILabel     *_desc;
    UILabel     *_trackTitile;
    UILabel     *_playTime;
    
    NavPlayButton   *_animationBtn;
}
@end

@implementation HistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;
        _header = [UIImageView new];
        _icon = [UIImageView new];
        _title = [UILabel new];
        //_desc = [UILabel new];
        _trackTitile = [UILabel new];
        _playTime = [UILabel new];
        
        
        //_desc.font = [UIFont systemFontOfSize:12];
        //_desc.textColor = [UIColor colorWithHexString:@"#959595"];
        _title.font = [UIFont systemFontOfSize:28*XA];
        _title.textColor = [UIColor colorWithHexString:@"#333333"];
        _trackTitile.font = [UIFont systemFontOfSize:22*XA];
        _trackTitile.textColor = [UIColor colorWithHexString:@"#959595"];
        _playTime.font = [UIFont systemFontOfSize:22*XA];
        _playTime.textColor = [UIColor colorWithHexString:@"#959595"];
        
        _icon.image = [UIImage imageNamed:@"bg_album_flag.png"];
        [self addSubview:_header];
        [self addSubview:_icon];
        [self addSubview:_title];
        [self addSubview:_desc];
        [self addSubview:_playTime];
        [self addSubview:_trackTitile];
        
        
        _animationBtn = [NavPlayButton buttonWithType:UIButtonTypeCustom];

        [_header addSubview:_animationBtn];
        
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
    
    leftPadding = 20*XA;
    width = height = 28*XA;
    topPadding = (20 + 8)*XA;
    [_icon alignToTheRightOf:_header withLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    
    leftPadding = 10*XA;
    width = ScreenSize.width -_icon.xMax - 2*leftPadding;
    height = 28*XA;

    [_title alignToTheRightOf:_icon matchingCenterWithLeftPadding:leftPadding width:width height:height];
    
    CGFloat bottomPadding = 20*XA;
    CGSize  size = [_playTime.text sizeWithFont:_playTime.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    width = size.width;
    height = size.height;
    [_playTime alignUnder:_title withRightPadding:leftPadding topPadding:topPadding width:width height:height];
    
    bottomPadding = 28*XA;
   
    width = _playTime.xMin - leftPadding - _icon.xMin;
    
    bottomPadding = 28*XA;
    [_trackTitile alignToTheLeftOf:_playTime matchingCenterWithRightPadding:leftPadding width:width height:height];
    
    width = 60*XA;
    height = width;
    [_animationBtn anchorInCenterWithWidth:width height:height];
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
    
    _trackTitile.text = dict[@"title"];
    _title.text = dict[@"track"][@"title"];
    _playTime.text = [NSObject getDurationText:[dict[@"track"][@"time"] floatValue]];
    
    BOOL isPlaying = [dict[@"is_playing"] boolValue];
    if (isPlaying) {
        [self startAnimation];
    }
    else
    {
        [self stopAnimation];
    }
    
    [self setNeedsLayout];
    
}

- (void)updateTime:(NSTimeInterval)time
{
    _playTime.text = [NSObject getDurationText:time];
}

- (void)startAnimation
{
    _animationBtn.hidden = NO;
    [_animationBtn startAnimation];
}

- (void)stopAnimation
{
    _animationBtn.hidden = YES;
    [_animationBtn stopAnimation];
}
@end
