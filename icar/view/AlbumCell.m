//
//  AlbumCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright (c) 2015年 lizhuzhu. All rights reserved.
//

#import "AlbumCell.h"
#import "Public.h"

@interface AlbumCell()
{
    UIImageView *_header;
    UIImageView *_icon;
    UILabel     *_title;
    UILabel     *_desc;
    UILabel     *_trackCount;
    UILabel     *_playCount;
}
@end

@implementation AlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.clipsToBounds = YES;
        _header = [UIImageView new];
        _icon = [UIImageView new];
        _title = [UILabel new];
        //_desc = [UILabel new];
        _trackCount = [UILabel new];
        _playCount = [UILabel new];
        
        _header.contentMode = UIViewContentModeScaleAspectFill;
        _header.clipsToBounds = YES;
        
        //_desc.font = [UIFont systemFontOfSize:12];
        //_desc.textColor = [UIColor colorWithHexString:@"#959595"];

        _trackCount.font = [UIFont systemFontOfSize:12];
        _trackCount.textColor = [UIColor colorWithHexString:@"#959595"];
        _playCount.font = [UIFont systemFontOfSize:12];
        _playCount.textColor = [UIColor colorWithHexString:@"#959595"];
        
        _icon.image = [UIImage imageNamed:@"bg_album_flag.png"];
        [self addSubview:_header];
        [self addSubview:_icon];
        [self addSubview:_title];
        [self addSubview:_desc];
        [self addSubview:_playCount];
        [self addSubview:_trackCount];
        
        
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
    
    
    width = ScreenSize.width - (8 + 20 + 120 + 28 + 20 + 8)*XA;
    height = 28*XA;

    [_title alignToTheRightOf:_icon matchingCenterWithLeftPadding:leftPadding width:width height:height];
    
    
    CGFloat bottomPadding = 20*XA;
    CGSize size = [_trackCount.text sizeWithFont:_trackCount.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    width = size.width;
    height = size.height;
    bottomPadding = 28*XA;
    [_trackCount alignToTheRightOf:_header withLeftPadding:leftPadding bottomPadding:bottomPadding width:width height:height];
    
    bottomPadding = 28*XA;
    size = [_playCount.text sizeWithFont:_playCount.font maxSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    width = size.width;
    height = size.height;
    [_playCount alignToTheRightOf:_trackCount withLeftPadding:leftPadding bottomPadding:bottomPadding width:width height:height];
    
//    width = ScreenSize.width - (8 + 20 + 120 + 40)*XA;
//    height = 30*XA;
//    leftPadding = (120 + 20 )*XA;
//    topPadding = 10*XA;
//    [_desc alignUnder:_icon withLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    

}

- (void)setData:(NSDictionary *)dict
{

    //if (![dict[@"cover_url"] isKindOfClass:[NSNull class]] && dict[@"cover_url"]) {
    if(![NSObject isNull:dict[@"cover_url"]]){
        [_header setImageWithURL:[NSURL URLWithString:dict[@"cover_url"]] placeholderImage:[UIImage imageNamed:@"album_cover_bg"]];        
    }
    else
    {
        [_header setImage:[UIImage imageNamed:@"album_cover_bg"]];
    }

    _title.text = dict[@"title"];
    //_desc.text = dict[@"mid_intro"];
    _trackCount.text = [NSString stringWithFormat:@"节目：%@", dict[@"track_count"]];
    
    CGFloat playCount = [dict[@"play_count"] floatValue];
    NSString *text = nil;
    NSString *tag = @"播放：";
    if (playCount > 10000) {
        playCount = playCount/10000;

        if ((NSInteger)playCount % 10000 == 0) {
            text = [NSString stringWithFormat:@"%@%f万", tag, playCount];
        }
        else
        {
            text = [NSString stringWithFormat:@"%@%.1f万", tag, playCount];
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"%@%f", tag, playCount];
        
    }
    _playCount.text = text;
    
    [self setNeedsLayout];

}

@end
