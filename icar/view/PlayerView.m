//
//  PlayerView.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "PlayerView.h"
#import "Public.h"

@interface PlayerView()
{
    UIImageView     *_playerTop;
    UISlider        *_progressView;
    UILabel         *_timeLeft;
    UILabel         *_timeRight;
    UIButton        *_nextButton;
    UIButton        *_playButtton;
    
    UIButton        *_modeButton;
    UIButton        *_timeSettingButton;
    
    UIActivityIndicatorView *_activityView;
    
}

@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic, strong) NSDictionary *track;

@property (nonatomic, assign) BOOL  isScribe;

@end

@implementation PlayerView

- (void)dealloc
{
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        self.backgroundColor = [UIColor yellowColor];
        
        _progressView = [UISlider new];
        [self addSubview:_progressView];
        
        
        _timeLeft = [UILabel new];
        [self addSubview:_timeLeft];
        
        
        _timeRight = [UILabel new];
        [self addSubview:_timeRight];
        
        
        _playButtton = [UIButton new];
        [self addSubview:_playButtton];

        _nextButton = [UIButton new];
        [self addSubview:_nextButton];

        _modeButton = [UIButton new];
        [self addSubview:_modeButton];

        //_timeSettingButton = [UIButton new];
        //[self addSubview:_timeSettingButton];
        
        _activityView = [UIActivityIndicatorView new];
        [_playButtton addSubview:_activityView];
        
        _activityView.hidden = YES;
        
        [_progressView setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
        [_progressView setMinimumTrackTintColor:[UIColor colorWithHexString:@"#ff5000"]];
        [_progressView setMaximumValueImage:[UIImage imageNamed:@"player_slider_playback_right"]];
        [_progressView addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventTouchDragInside];
        
        _timeLeft.font = [UIFont systemFontOfSize:14*XA];
        _timeRight.font = [UIFont systemFontOfSize:14*XA];

        _timeLeft.textColor = [UIColor grayColor];
        _timeRight.textColor = [UIColor grayColor];
        
        [_modeButton setImage:[UIImage imageNamed:@"bg_mode_loop_on"] forState:UIControlStateNormal];
        [_timeSettingButton setImage:[UIImage imageNamed:@"widget_sleep"] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"widget_play_next"] forState:UIControlStateNormal];
        
        [_playButtton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
        [_nextButton addTarget:self action:@selector(nextItem) forControlEvents:UIControlEventTouchUpInside];
        
        [_modeButton addTarget:self action:@selector(setMode) forControlEvents:UIControlEventTouchUpInside];
        
        [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
        
        [self setMode];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layout];
}


- (void)layout
{
    CGFloat left = 10 * XA;
    CGFloat top = 30 * XA;
    CGFloat width = CGRectGetMaxX(self.frame) - 2*left;
    CGFloat height = 30 * XA;

    CGSize size = [_timeLeft.text sizeWithFont:_timeLeft.font maxSize:CGSizeMake(width, 100)];
    width = size.width + 10*XA;
    height = size.height;
    [_timeLeft anchorTopLeftWithLeftPadding:left topPadding:top width:width height:height];
    
    size = [_timeRight.text sizeWithFont:_timeRight.font maxSize:CGSizeMake(width, 100)];
    width = size.width + 10*XA;
    height = size.height;
    [_timeRight anchorTopRightWithRightPadding:left topPadding:top width:width height:height];
    

    left = 20*XA;
    height = 30 * XA;
    width = CGRectGetMaxX(self.frame) - ((left + _timeLeft.xMax) *2);
    [_progressView alignToTheRightOf:_timeLeft matchingCenterWithLeftPadding:left width:width height:height];
 
    left = 40*XA;
    CGFloat bottom = 30*XA;
    width = 44*XA;
    height = 42*XA;
    [_modeButton anchorBottomLeftWithLeftPadding:left bottomPadding:bottom width:width height:height];
    

    width = 44*XA;
    height = 44*XA;
    [_timeSettingButton anchorBottomRightWithRightPadding:left bottomPadding:bottom width:width height:height];
    
    
    width = 60*XA;
    height = 60*XA;
    left = (CGRectGetMaxX(self.frame) - width)/2 - CGRectGetMaxX(_modeButton.frame);
    [_playButtton alignToTheRightOf:_modeButton matchingCenterWithLeftPadding:left width:width height:height];
    
    left = 30*XA;
    width = 44*XA;
    height = 44*XA;
    [_nextButton alignToTheRightOf:_playButtton matchingCenterWithLeftPadding:left width:width height:height];
    
    [_activityView anchorInCenterWithWidth:20*XA height:XA*20];
}

- (void)setData:(NSDictionary *)album track:(NSDictionary *)track
{
    
    self.album = album;
    self.track = track;
    
    
    _timeLeft.text = [NSObject getDurationText:0];
    _timeRight.text = [NSObject getDurationText:[track[@"duration"] floatValue]];
    
     
    [self setNeedsLayout];
}


- (void)updateProgres:(NSInteger)timePlayed duration:(NSInteger)duration
{
    _timeLeft.text = [NSObject getDurationText:timePlayed];//FormattedTimeStringFromTimeInterval(timePlayed);
    _timeRight.text = [NSObject getDurationText:duration];//FormattedTimeStringFromTimeInterval(duration);
    _progressView.value = (CGFloat)timePlayed/duration;
}


- (void)nextItem
{
    if (_callback) {
        _callback(self.album[@"id"], self.track[@"id"], PlayerActionTypeNext, _playModeType);
    }
}

- (UISlider *)getProgressView
{
    return _progressView;
}

- (void)setMode
{
    switch (_playModeType) {
        case PlayModeTypeList:
            _playModeType = PlayModeTypeLoop;
            [_modeButton setImage:[UIImage imageNamed:@"bg_mode_loop_on"] forState:UIControlStateNormal];
            break;
        case PlayModeTypeSingle:
            _playModeType = PlayModeTypeList;
            [_modeButton setImage:[UIImage imageNamed:@"bg_mode_list_on"] forState:UIControlStateNormal];
            break;
        case PlayModeTypeLoop:
            _playModeType = PlayModeTypeSingle;
            [_modeButton setImage:[UIImage imageNamed:@"bg_mode_single_on"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)play
{
    if (_callback) {
        App(app);

        [self setPlayState:![app.playViewController isPlaying]];
        
        _callback(self.album[@"id"], self.track[@"id"], PlayerActionTypePlay, _playModeType);
    }
}

- (void)setPlayState:(BOOL)isPlay
{
    if (isPlay) {
        [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
    }
}

- (void)valueChange
{
    self.isScribe = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changePlayTime) object:nil];
    [self performSelector:@selector(changePlayTime) withObject:nil afterDelay:1];
}

- (void)changePlayTime
{
    self.isScribe = NO;
    App(app);
    if ([app.playViewController isPlaying]) {
        if (_callback) {
            _callback(self.album[@"id"], self.track[@"id"], PlayerActionTypeChangeTime, _playModeType);
        }
    }
}

- (CGFloat)sliderValue
{
    return _progressView.value;
}

- (BOOL)isScribe
{
    return _isScribe;
}
@end