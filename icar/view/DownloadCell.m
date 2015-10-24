//
//  DownloadCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/20.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadCell.h"
#import "Public.h"

@interface DownloadCell()
{
    UIImageView *_header;
    UIImageView *_icon;
    UILabel     *_title;
    UILabel     *_desc;
    UILabel     *_trackCount;
    UILabel     *_playCount;
}
@end

@implementation DownloadCell

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
        
        
        //_desc.font = [UIFont systemFontOfSize:12];
        //_desc.textColor = [UIColor colorWithHexString:@"#959595"];
        _header.contentMode = UIViewContentModeScaleAspectFill;
        _header.clipsToBounds = YES;

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
    
}

- (void)setData:(NSDictionary *)dict
{
    
    if(![NSObject isNull:dict[@"cover_url"]]){
        [_header setImageWithURL:[NSURL URLWithString:dict[@"cover_url"]] placeholderImage:[UIImage imageNamed:@"album_cover_bg"]];
    }
    else
    {
        [_header setImage:[UIImage imageNamed:@"album_cover_bg"]];
    }
    
    _title.text = dict[@"title"];

    _trackCount.text = [NSString stringWithFormat:@"节目：%@", dict[@"track_count"]];
    
    [self setDownloadCount:dict[@"id"]];
    
    [self setNeedsLayout];
}


- (void)setDownloadCount:(NSString *)albumId
{
    App(app);
    
    [app.queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from download where album_id = %@ order by timestamp DESC", albumId];
        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableArray *arr = [NSMutableArray new];
        while ([rs next]) {
            
            NSDictionary *album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
            [arr addObject:album];
            
        }
        

        [rs close];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _playCount.text = [NSString stringWithFormat:@"下载：%lu", (unsigned long)arr.count];
            
            [self setNeedsLayout];
        });
        
    }];

}
@end
