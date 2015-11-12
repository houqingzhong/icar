//
//  SplashAdController.h
//  SDK7Demo
//
//  Created by xueli on 15/10/26.
//  Copyright © 2015年 kblong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SmtaranSplashAd;

@protocol SmtaranSplashAdDelegate <NSObject>

@optional
/**
 *  adSplash被点击
 *  @param adSplash
 */
- (void)smtaranSplashAdClick:(nonnull SmtaranSplashAd*)adSplash;

/**
 *  adSplash请求成功并展示广告
 *  @param adSplash
 */
- (void)smtaranSplashAdSuccessToShowAd:(nonnull SmtaranSplashAd*)adSplash;

/**
 *  adSplash请求失败
 *  @param adSplash
 */
- (void)smtaranSplashAdFaildToShowAd:(nonnull SmtaranSplashAd*)adSplash withError:(nullable NSError*) error;

/**
 *  AdSplash被关闭
 *  @param adSplash
 */
- (void)smtaranSplashAdClose:(nonnull SmtaranSplashAd*)adSplash;

@end

@interface SmtaranSplashAd : UIViewController

@property (nonatomic, assign, nullable) id<SmtaranSplashAdDelegate>delegate;
/*
 *  开屏广告展示时间，默认3秒
 */
@property (nonatomic, assign) NSInteger adImpressTime;

/**
 *  初始化并展示开屏广告
 *  @param slotT 广告位id
 *  @param delegate 开屏广告回调
 *  @param vc 当前活动窗口的主controller
 *  @param window 当前活动窗口
 */
- (nonnull instancetype)initWithSlottoken:(nonnull NSString *)slotT
                                 delegate:(nonnull id<SmtaranSplashAdDelegate>)delegate
                                   rootVC:(nonnull UIViewController *)vc
                            currentWindow:(nonnull UIWindow *)window;
@end