//
//  SplashAdController.m
//  SDK7Demo
//
//  Created by xueli on 15/10/26.
//  Copyright © 2015年 kblong. All rights reserved.
//

#import "SmtaranSplashAd.h"
#import "SmtaranFactoryAd.h"
#import "SmtaranSDKManager.h"
#import "SmtaranNativeAd.h"
#import "FWBaseDownload.h"

@interface SmtaranSplashAd ()<SmtaranAdFactoryDelegate,SmtaranNativeDelegate>

@property(nonatomic, strong, nullable) SmtaranFactoryAd *smFAd;
@property(nonatomic, strong, nullable) SmtaranNativeAd  *smNAd;
@property(nonatomic, strong) UIViewController *originVC;
@property(nonatomic, strong) UIWindow *originWindow;
@property(nonatomic, strong) UIButton *skipButton;
@property(nonatomic, assign, getter=isButtonEnable) BOOL buttonEnable;

@end

@implementation SmtaranSplashAd

#pragma mark - life cycle

- (void)dealloc {
    self.originWindow = nil;
    self.originVC = nil;
    
    self.smFAd.delegate = nil;
    self.smFAd = nil;
    
    self.smNAd.delegate = nil;
    self.smNAd = nil;
}

- (nonnull instancetype)initWithSlottoken:(nonnull NSString *)slotT
                                 delegate:(nonnull id<SmtaranSplashAdDelegate>)delegate
                                   rootVC:(nonnull UIViewController *)vc
                            currentWindow:(nonnull UIWindow *)window
{
    self = [super init];
    if (self) {
        assert(slotT);
        assert(vc);
        assert(window);
        
        self.originVC = vc;
        self.originWindow = window;
        _delegate = delegate;
        _adImpressTime = 3;
        _buttonEnable = NO;
        
        UIImageView *defaultImageView = [self getLauchImageWithWindow:self.originWindow];
        assert(defaultImageView);
        [self.view  addSubview:defaultImageView];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self.view addSubview:self.skipButton];
                       });
        
        
        if (self.smFAd) {
            _smFAd.delegate = nil;
            _smFAd = nil;
        }
        _smFAd = [[SmtaranFactoryAd alloc]init];
        _smFAd.delegate = self;
        _smFAd.capacity = 1;
        CGSize adSize = [[UIScreen mainScreen] bounds].size;
        assert(NSStringFromCGSize(adSize));
        
        [_smFAd requestWithSize:adSize slotToken:slotT completion:^(NSArray *adViews) {
        }];
    }
    return self;
}

#pragma mark - NativeDelegate
-(void)smtaranAdFactorySuccessToRequest:(SmtaranFactoryAd*) adFactory
{
    _smNAd = (SmtaranNativeAd *)adFactory.adViews[0];
    _smNAd.delegate = self;
    _smNAd.frame = self.view.bounds;
    [self.view addSubview:_smNAd];
    NSString *imageURL = _smNAd.content[@"image"];
    
    __weak typeof(self) weakself = self;
    
    [[FWBaseDownload sharedDownload] download:@{imageURL:@""} completed:^(NSDictionary *response) {
        
        NSString *imagePath = response[_smNAd.content[@"image"]];
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        
        if (imageData) {
            [self displaySplashAd:imageData];
        }
        else
        {
            [weakself enterHomePage];
        }
    }];
}

-(void)smtaranAdFactoryFaildToRequest:(SmtaranFactoryAd*) adFactory withError:(NSError*) error
{
    if ([_delegate respondsToSelector:@selector(smtaranSplashAdFaildToShowAd:withError:)]) {
        [_delegate smtaranSplashAdFaildToShowAd:self withError:error];
    }
    [self enterHomePage];
}

-(void)smtaranNativeClick:(SmtaranNativeAd*) adNative
{
    if ([_delegate respondsToSelector:@selector(smtaranSplashAdClick:)]) {
        [_delegate smtaranSplashAdClick:self];
    }
    [self enterHomePage];
}

-(void)smtaranNativeAppeared:(SmtaranNativeAd*) adNative
{
    if ([_delegate respondsToSelector:@selector(smtaranSplashAdSuccessToShowAd:)]) {
        [_delegate smtaranSplashAdSuccessToShowAd:self];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.adImpressTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if (self.isButtonEnable) {
                           return;
                       }
                       [self closeSplashAd];
                   });
}
-(void)closeSplashAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        _buttonEnable = YES;
        if ([_delegate respondsToSelector:@selector(smtaranSplashAdClose:)]) {
            [_delegate smtaranSplashAdClose:self];
        }
        [self enterHomePage];
    });
}

#pragma mark - private methods

- (void)enterHomePage
{
    [self.originWindow setRootViewController:self.originVC];
}

- (void)displaySplashAd:(nonnull NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIImage *image = [UIImage imageWithData:data];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            imageView.frame = _smNAd.frame;
        }
        else
        {
            imageView.frame = self.view.frame;
        }
        [_smNAd addSubview:imageView];
        [_smNAd addSubview:self.skipButton];
    });
    
}

- (nullable UIImageView *)getLauchImageWithWindow:(nonnull UIWindow *)window
{
    CGSize viewSize = window.bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    UIImageView *launchView = [[UIImageView alloc] initWithFrame:window.bounds];
    
    if (imagesDict) {
        for (NSDictionary* dict in imagesDict)
        {
            CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
            
            if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            {
                launchImage = dict[@"UILaunchImageName"];
            }
        }
        launchView.image = [UIImage imageNamed:launchImage];
        launchView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else
    {
        UIView *lunchView = [[NSBundle mainBundle ]loadNibNamed:@"LaunchScreen" owner:nil options:nil][0];
        lunchView.frame = window.bounds;
        launchView = (UIImageView*)lunchView;
    }
    
    return launchView;
}

#pragma mark - Custom Delegate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - getters and setters
- (nonnull UIButton *)skipButton
{
    if (_skipButton == nil)
    {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _skipButton.frame = CGRectMake(self.view.frame.size.width-80, 20, 80, 30);
        [_skipButton setTitle:@"跳过广告" forState:UIControlStateNormal];
        [_skipButton sizeToFit];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipButton.titleLabel.font = [UIFont systemFontOfSize: 15.f];
        [_skipButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]];
        [_skipButton addTarget:self
                        action:@selector(closeSplashAd)
              forControlEvents:UIControlEventTouchUpInside];
        _skipButton.layer.cornerRadius = 5;
        _skipButton.layer.masksToBounds = YES;
        
    }
    return _skipButton;
    
}

@end
