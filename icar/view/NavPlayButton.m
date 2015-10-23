//
//  NavPlayButton.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "NavPlayButton.h"
#import "Public.h"

@interface NavPlayButton()
{
    UILabel *_title;
    UIImageView *_icon;
    CGFloat imageviewAngle;
    
    NSTimer *_animTimer;
    
    NSInteger _imageNum;
}
@end

@implementation NavPlayButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _title = [UILabel new];
        _icon = [UIImageView new];
        [self addSubview:_title];
        [self addSubview:_icon];
        
        _imageNum = 1;
        
    }
    
    return self;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_icon anchorTopRightWithRightPadding:0 topPadding:0 width:60*XA height:60*XA];
}


- (void)startAnimation
{
    [_animTimer invalidate];
    _animTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self startAnimation];
    }
}

- (void)stopAnimation
{

    [_animTimer invalidate];
    _animTimer = nil;
//    [_icon.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)changeImage
{
    switch (_imageNum) {
        case 1:
            _imageNum = 2;
            _icon.image = [UIImage imageNamed:@"list_icon_playing1"];
            break;
        case 2:
            _imageNum = 1;
            _icon.image = [UIImage imageNamed:@"list_icon_playing"];
            break;
        default:
            break;
    }
}
@end
