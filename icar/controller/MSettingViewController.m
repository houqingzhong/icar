//
//  MSettingViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/24.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "MSettingViewController.h"
#import "Public.h"

@interface MSettingViewController()<SmtaranBannerAdDelegate>
@property (nonatomic,strong) SmtaranBannerAd *smtaranBanner;

@end

@implementation MSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"设置";

    self.icon_arrow = @"CellArrow";
    
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"车载音乐台" auditFlag:MS_Audit_Flag];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];


    
    CFSettingSwitchItem *allowPlay3G =[CFSettingSwitchItem itemWithIcon:nil title:@"使用2G/3G/4G网络播放"];
    // 用户第一次设置前  默认打开开关
    allowPlay3G.defaultOn = YES;
    // 开关状态改变时执行的操作
    allowPlay3G.opration_switch = ^(BOOL isON){
        [PublicMethod allowGprsPlay:isON];
    };
    
    CFSettingSwitchItem *allowDownload3G =[CFSettingSwitchItem itemWithIcon:nil title:@"使用2G/3G/4G网络下载"];
    // 用户第一次设置前  默认打开开关
    allowDownload3G.defaultOn = YES;
    // 开关状态改变时执行的操作
    allowDownload3G.opration_switch = ^(BOOL isON){
        [PublicMethod allowGprsDownload:isON];
        
        [[DownloadClient sharedInstance] allow3GDownload];
    };
    
    CFSettingArrowItem *cleaPicCach =[CFSettingArrowItem itemWithIcon:nil title:@"清楚图片缓存" destVcClass:nil];
    [cleaPicCach setOpration:^{
//        [UIImageView clearCache];
        App(app);
        [app.localStore clearTable:server_data_cahce];
        
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:ClearCacheMsg
                                        type:TSMessageNotificationTypeMessage];
        
    }];
    
    CFSettingGroup *group1 = [[CFSettingGroup alloc] init];
    group1.items = @[ allowDownload3G, allowPlay3G, cleaPicCach];
    
    UILabel *footer = [UILabel new];
    footer.font = [UIFont systemFontOfSize:22*XA];
    footer.textColor = [UIColor colorWithHexString:@"#959595"];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    

    footer.textAlignment = NSTextAlignmentCenter;
    footer.text = [NSString stringWithFormat:@"车载音乐台 v%@", app_Version];
    group1.footerrView = footer;
    group1.footerHeight = 30;

    
    [self.dataList addObject:group1];

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self sdkAdRequestBannerAction];
}
//创建Smtaran横幅广告
-(void)sdkAdRequestBannerAction
{
    if (self.smtaranBanner) {
        self.smtaranBanner.delegate = nil;
        [self.smtaranBanner removeFromSuperview];
        self.smtaranBanner = nil;
    }
    // 设置delegate ,type  slotToken
    // 确保初始化banner前已设置过 publisherID
    
    //SmtaranBannerAdSizeNormal  iPhone 320X50  iPhone6 375*50 iPhone6 Plus 414*50  iPad 728X90
    self.smtaranBanner = [[SmtaranBannerAd alloc] initBannerAdSize:SmtaranBannerAdSizeNormal delegate:self slotToken:MS_setting_Banner];
    
    //轮播周期
    /*
     SmtaranBannerAdRefreshTimeNone,         //不刷新
     SmtaranBannerAdRefreshTimeHalfMinute,   //30秒刷新
     SmtaranBannerAdRefreshTimeOneMinute,    //60秒刷新
     */
    [self.smtaranBanner  setBannerAdRefreshTime:SmtaranBannerAdRefreshTimeHalfMinute];
    //轮播动画
    /*
     SmtaranBannerAdAnimationTypeNone    = -1,   //无动画
     SmtaranBannerAdAnimationTypeRandom  = 1,    //随机动画
     SmtaranBannerAdAnimationTypeFade    = 2,    //渐隐渐现
     SmtaranBannerAdAnimationTypeCubeT2B = 3,    //立体翻转从左到右
     SmtaranBannerAdAnimationTypeCubeL2R = 4,    //立体翻转从上到下
     */
    [self.smtaranBanner  setBannerAdAnimeType:SmtaranBannerAdAnimationTypeFade];
    
    self.smtaranBanner.frame = CGRectMake(0,self.view.frame.size.height-120, self.view.frame.size.width, 50);//此处的width和height可以是SDK返回的数据
    [self.view addSubview:self.smtaranBanner];
}

#pragma mark - SmtaranBannerAdDelegate
#pragma mark

//横幅广告被点击时,触发此回调方法,用于统计广告点击数
- (void)smtaranBannerAdClick:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerAdClick");
}

//横幅广告成功展示时,触发此回调方法,用于统计广告展示数
- (void)smtaranBannerAdSuccessToShowAd:(SmtaranBannerAd *)adBanner
{
    NSLog(@"smtaranBannerAdSuccessToShowAd");
}

//横幅广告展示失败时,触发此回调方法
- (void)smtaranBannerAdFaildToShowAd:(SmtaranBannerAd *)adBanner withError:(NSError *)error
{
    NSLog(@"smtaranBannerAdFaildToShowAd, error = %@", [error description]);
}

//横幅广告点击后,打开 LandingSite 时,触发此回调方法,请勿释放横幅广告
- (void)smtaranBannerLandingPageShowed:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageShowed");
}

//关闭 LandingSite 回到应用界面时,触发此回调方法
- (void)smtaranBannerLandingPageHided:(SmtaranBannerAd*)adBanner
{
    NSLog(@"smtaranBannerLandingPageHided");
}

- (void)openOrCloseLeftList
{

    App(app);
    if (app.leftSlideVC.closed)
    {
        [app.leftSlideVC openLeftView];
    }
    else
    {
        [app.leftSlideVC closeLeftView];
    }
}

@end
