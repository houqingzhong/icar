//
//  MainPageViewController.m
//  LeftSlide
//
//  Created by huangzhenyu on 15/6/18.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "MainPageViewController.h"
#import "Public.h"
#define vBackBarButtonItemName  @"backArrow.png"    //导航条返回默认图片名

@interface MainPageViewController ()<SmtaranBannerAdDelegate>
@property (nonatomic,strong) SmtaranBannerAd *smtaranBanner;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation MainPageViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
       
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推荐";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"车载音乐台" auditFlag:MS_Audit_Flag];

    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];

    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];
    
    WS(ws);
    [self.tableview addPullToRefreshWithActionHandler:^{
        [ws updateRecommend];
    }];
    
    [self updateRecommend];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[AlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [cell setData:_dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *album = _dataArray[indexPath.row];
    App(app);
    TrackViewController *tc = [TrackViewController new];
    [tc updateList:album pageNum:1];
    [app.mainNavigationController pushViewController:tc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellHeight = (120+8*2)*XA;
    return cellHeight;
}


#pragma method


- (void)updateRecommend
{
    WS(ws);
    NSString *key = [NSString stringWithFormat:@"%@:%@", @(ServerDataRequestTypeRecommend),  @(0)];
    [HttpEngine getDataFromServer:[NSString stringWithFormat:@"%@recommend", HOST] key:key callback:^(NSArray *albums) {
        
      
        ws.dataArray = albums;
        
        [ws.tableview.pullToRefreshView stopAnimating];
        
        [ws.tableview reloadData];
        
    }];
    
}

- (void)showAlbum:(NSDictionary *)album
{
    
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
    self.smtaranBanner = [[SmtaranBannerAd alloc] initBannerAdSize:SmtaranBannerAdSizeNormal delegate:self slotToken:MS_class_Banner];
    
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
    
    self.smtaranBanner.frame = CGRectMake(0,self.view.frame.size.height-50, self.view.frame.size.width, 50);//此处的width和height可以是SDK返回的数据
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

@end
