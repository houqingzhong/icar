//
//  MSettingViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/24.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "MSettingViewController.h"
#import "Public.h"

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
        [UIImageView clearCache];
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

    footer.textAlignment = NSTextAlignmentCenter;
    NSString *verText = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    footer.text = [NSString stringWithFormat:@"车载音乐台 v%@", verText];
    group1.footerrView = footer;
    group1.footerHeight = 30;

    
    [self.dataList addObject:group1];

    
}

@end
