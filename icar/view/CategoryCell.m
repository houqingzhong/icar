//
//  CategoryCell.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "CategoryCell.h"
#import "Public.h"

@interface CategoryCell()
{
    CategroyView * _image1;
    CategroyView * _image2;
    CategroyView * _image3;
}
@end

@implementation CategoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _image1 = [CategroyView new];
        _image2 = [CategroyView new];
        _image3 = [CategroyView new];
        [self addSubview:_image1];
        [self addSubview:_image2];
        [self addSubview:_image3];

        WS(ws);
        [_image1 setCallback:^(NSDictionary *dict) {
            if (ws.callback) {
                ws.callback(dict);
            }
        }];
        
        [_image2 setCallback:^(NSDictionary *dict) {
            if (ws.callback) {
                ws.callback(dict);
            }
        }];
        
        [_image3 setCallback:^(NSDictionary *dict) {
            if (ws.callback) {
                ws.callback(dict);
            }
        }];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat leftPadding = (ScreenSize.width - 108*XA * 3)/4;
    CGFloat topPadding = 20*XA;
    CGFloat width = 108*XA;
    CGFloat height = width;
    [_image1 anchorTopLeftWithLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    [_image2 alignToTheRightOf:_image1 withLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    [_image3 alignToTheRightOf:_image2 withLeftPadding:leftPadding topPadding:topPadding width:width height:height];
    
}

- (void)setData:(NSArray *)arr
{
    _image1.hidden = YES;
    _image2.hidden = YES;
    _image3.hidden = YES;
    if (arr.count > 0) {
        [_image1 setData:arr[0]];
        _image1.hidden = NO;
    }
    
    if (arr.count > 1) {
        [_image2 setData:arr[1]];
        _image2.hidden = NO;
    }
    
    if (arr.count > 2) {
        [_image3 setData:arr[2]];
        _image3.hidden = NO;
    }
    
    [self setNeedsLayout];    
}

+ (CGFloat)height:(NSDictionary *)dict
{
    CGFloat padding = 20*XA;
    
    CGFloat cellHeight = [CategroyView height:dict];
    cellHeight += 2*padding;
    
    return cellHeight;
}

- (void)showAlbumList:(id)sender
{
    if (sender == _image1) {
        
    }
    else if (sender == _image2) {
        
    }
    else if (sender == _image3) {
        
    }
    NSLog(@"s");
}
@end
