//
//  PlayerView.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "PlayerView.h"
#import "Public.h"

@interface PlayerView()<BABAudioPlayerDelegate>
{
    UIImageView     *_playerTop;
    ProgressView        *_progressView;
    UILabel         *_timeLeft;
    UILabel         *_timeRight;
    UIButton        *_nextButton;
    UIButton        *_playButtton;
    
    UIButton        *_modeButton;
    UIButton        *_timeSettingButton;
    
    UIActivityIndicatorView *_activityView;
    
    PlayModeType    _playModeType;
}

@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic, strong) NSDictionary *track;

@end

@implementation PlayerView

- (void)dealloc
{
    [BABAudioPlayer sharedPlayer].delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        _progressView = [ProgressView new];
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

        _timeSettingButton = [UIButton new];
        [self addSubview:_timeSettingButton];
        
        _activityView = [UIActivityIndicatorView new];
        [_playButtton addSubview:_activityView];
        
        _activityView.hidden = YES;
        
        [_progressView setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
        [_progressView setMinimumTrackTintColor:[UIColor colorWithHexString:@"#ff5000"]];
        [_progressView setMaximumValueImage:[UIImage imageNamed:@"player_slider_playback_right"]];
        
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
        
        BABAudioPlayer *player = [BABAudioPlayer sharedPlayer];
        if (BABAudioPlayerStatePlaying == player.state) {
            [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
        }
        else
        {
            [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
        }
        
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
    CGFloat top = 15 * XA;
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
    CGFloat bottom = 20*XA;
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

- (void)setAlbum:(NSDictionary *)album track:(NSDictionary *)track
{
    
    self.album = album;
    self.track = track;

    [BABAudioPlayer sharedPlayer].delegate = self;
    
    BABConfigureSliderForAudioPlayer(_progressView, [BABAudioPlayer sharedPlayer]);

    [self setNeedsLayout];

}

- (void)setData:(NSDictionary *)dict album:(NSDictionary *)album time:(NSTimeInterval)time
{
   
    [self setAlbum:album track:dict];
    
    
    _timeLeft.text = [NSObject getDurationText:0];
    _timeRight.text = [NSObject getDurationText:[dict[@"duration"] floatValue]];

    App(app);
    
    [app play:album track:dict target:self slider:_progressView];
    
    if(!app.isStoped)
    {
        [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
    }
    else
    {
        [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
    }
    
    [self setNeedsLayout];
}

- (void)play
{
    App(app);
    if (BABAudioPlayerStatePlaying == [BABAudioPlayer sharedPlayer].state) {
        [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
        [[BABAudioPlayer sharedPlayer] pause];
        app.isStoped = YES;
    }
    else
    {
        [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
        [[BABAudioPlayer sharedPlayer] play];
        app.isStoped = NO;
    }
    
}


- (void)nextItem
{
    if (_callback) {
        _callback(PlayerActionTypeNext, _playModeType);
    }
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

#pragma mark Delegate

- (void)audioPlayer:(BABAudioPlayer *)player didChangeState:(BABAudioPlayerState)state
{
    _activityView.hidden = YES;
    if (BABAudioPlayerStatePlaying == state) {
        [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
    }
    else if (BABAudioPlayerStateBuffering == state)
    {
        [_playButtton setImage:[UIImage imageNamed:@"widget_pause_pressed"] forState:UIControlStateNormal];
        
        _activityView.hidden = NO;
    }
    
    [PublicMethod updateHistory:self.album[@"id"] trackId:self.track[@"id"] time:player.timeElapsed callback:nil];
    
}

- (void)audioPlayer:(BABAudioPlayer *)player didChangeElapsedTime:(NSTimeInterval)elapsedTime percentage:(float)percentage
{

    _timeLeft.text = [NSObject getDurationText:elapsedTime];
    _timeRight.text = [NSObject getDurationText:player.duration];
    _progressView.value = percentage;

    [PublicMethod updateHistory:self.album[@"id"] trackId:self.track[@"id"] time:player.timeElapsed callback:nil];

}


- (void)audioPlayer:(BABAudioPlayer *)player didFinishPlayingAudioItem:(BABAudioItem *)audioItem
{
    [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];
    
    if (_callback) {
        _callback(PlayerActionTypeNext, _playModeType);
    }
}

- (void)audioPlayer:(BABAudioPlayer *)player didLoadMetadata:(NSDictionary *)metadata forAudioItem:(BABAudioItem *)audioItem
{
    
}

- (void)audioPlayer:(BABAudioPlayer *)player didFailPlaybackWithError:(NSError *)error
{
    [_playButtton setImage:[UIImage imageNamed:@"widget_play_pressed"] forState:UIControlStateNormal];

}

@end
