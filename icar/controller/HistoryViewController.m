//
//  HistoryViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) ViewContrllerType viewContrllerType;
@end

@implementation HistoryViewController

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
    
    if (ViewContrllerTypeMenu == _viewContrllerType) {
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 0, 20, 18);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    }

    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];
    
}

- (void)setType:(ViewContrllerType)type
{
    self.viewContrllerType = type;
}

- (void)openOrCloseLeftList
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
    if (ViewContrllerTypeMenu == _viewContrllerType) {
        NSLog(@"viewWillDisappear");
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [tempAppDelegate.leftSlideVC setPanEnabled:NO];

    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (ViewContrllerTypeMenu == _viewContrllerType) {
        NSLog(@"viewWillAppear");
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [tempAppDelegate.leftSlideVC setPanEnabled:YES];
    }

    
    [self updateList];

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

- (void)updateList
{
    self.title = @"收听历史";
    self.dataArray = nil;
    [self.tableview reloadData];
    
    App(app);
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select * from history group by album_id order by timestamp DESC"];
        
        NSMutableArray *arr = [NSMutableArray new];
        while ([rs next]) {
            
            NSDictionary *album = [[rs stringForColumn:@"album_info"] objectFromJSONString];
            [arr addObject:album];
            
        }
        
        [rs close];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = arr;
            [self.tableview reloadData];

        });
        

    }];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_dataArray removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
@end
