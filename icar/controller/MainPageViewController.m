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

@interface MainPageViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableview;
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

    
    [self updateRecommend];
    
}

- (void) openOrCloseLeftList
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (tempAppDelegate.leftSlideVC.closed)
    {
        [tempAppDelegate.leftSlideVC openLeftView];
    }
    else
    {
        [tempAppDelegate.leftSlideVC closeLeftView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.leftSlideVC setPanEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.leftSlideVC setPanEnabled:YES];
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
    
    NSDictionary *dict = _dataArray[indexPath.row];
    TrackViewController *tc = [TrackViewController new];
    [tc updateList:dict];
    
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.mainNavigationController pushViewController:tc animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellHeight = (120+8*2)*XA;
    return cellHeight;
}


#pragma method

- (void)updateRecommend
{
    [HttpEngine recommend:[NSString stringWithFormat:@"%@recommend", HOST] callback:^(NSArray *albums) {
        
      
        self.dataArray = albums;
        
        [self.tableview reloadData];
        
    }];
    
}

- (void)showAlbum:(NSDictionary *)album
{
    
}

@end
