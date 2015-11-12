//
//  CategoryViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "CategoryViewController.h"
#import "Public.h"

@interface CategoryViewController()<SmtaranBannerAdDelegate>
@property (nonatomic,strong) SmtaranBannerAd *smtaranBanner;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) AlbumListViewController *listViewController;
@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SmtaranSDKManager getInstance] setPublisherID:MS_PublishID withChannel:@"车载音乐台" auditFlag:MS_Audit_Flag];

    self.title = @"分类";

    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    

    
    _dataArray = [NSMutableArray new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    dict[@"icon"] = @"category_default_img14";
    dict[@"title"] = @"车载电台";
    dict[@"tag"] = @"car";
    [_dataArray addObject:dict];
    

    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img1";
    dict[@"title"] = @"有声小说";
    dict[@"tag"] = @"book";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img2";
    dict[@"title"] = @"音乐";
    dict[@"tag"] = @"music";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img3";
    dict[@"title"] = @"综艺娱乐";
    dict[@"tag"] = @"entertainment";
    [_dataArray addObject:dict];
    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img4";
    dict[@"title"] = @"相声评书";
    dict[@"tag"] = @"comic";
    [_dataArray addObject:dict];
    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img13";
    dict[@"tag"] = @"kid";
    dict[@"title"] = @"儿童";
    [_dataArray addObject:dict];

    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img6";
    dict[@"title"] = @"情感生活";
    dict[@"tag"] = @"emotion";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img7";
    dict[@"title"] = @"历史人文";
    dict[@"tag"] = @"culture";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img8";
    dict[@"title"] = @"收听历史";
    dict[@"tag"] = @"history";
    [_dataArray addObject:dict];

    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataArray.count % 3 == 0) {
        return _dataArray.count/3;
    }
    
    return _dataArray.count/3 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    
    NSInteger count = 3;
    if ((indexPath.row + 1)*3 > _dataArray.count) {
        count = 3- ((indexPath.row + 1)*3 - _dataArray.count);
    }

    NSArray *arr = [_dataArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row *3, count)]];

    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[CategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    [cell setData:arr];
    
    WS(ws);
    [cell setCallback:^(NSDictionary *dict) {
        [ws showList:dict];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    if (_dataArray.count == 0) {
        return 0;
    }
    
    NSInteger count = 3;
    if ((indexPath.row + 1)*3 > _dataArray.count) {
        count = 3- ((indexPath.row + 1)*3 - _dataArray.count);
    }
    
    NSArray *arr = [_dataArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row *3, count)]];

    
    return [CategoryCell height:arr[0]];
    
}


- (void)showList:(NSDictionary *)dict
{
    
    if ([dict[@"tag"] isEqualToString:@"history"]) {

        HistoryViewController *historyViewController = [HistoryViewController new];
        [historyViewController setType:ViewContrllerTypeDefault];
        [self.navigationController pushViewController:historyViewController animated:YES];

    }
    else
    {
        if (nil == self.listViewController) {
            self.listViewController = [AlbumListViewController new];
        }
        [_listViewController updateList:dict pageNum:1];
        
        [self.navigationController pushViewController:_listViewController animated:YES];
    }
}

@end
