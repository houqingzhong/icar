//
//  AlbumListViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "AlbumListViewController.h"

#import "Public.h"

@interface AlbumListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation AlbumListViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
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

- (void)updateList:(NSDictionary *)dict
{
    self.title = dict[@"title"];
    self.dataArray = nil;
    [self.tableview reloadData];

    [HttpEngine recommend:[NSString stringWithFormat:@"%@category_album/%@", HOST, dict[@"tag"]] callback:^(NSArray *albums) {
        
        
        self.dataArray = albums;
        
        [self.tableview reloadData];
        
    }];
    
}

@end
