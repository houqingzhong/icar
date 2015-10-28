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

@interface MainPageViewController ()

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

@end
