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

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *dict;

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
    
    
    WS(ws);
    [self.tableview addPullToRefreshWithActionHandler:^{
        ws.pageNum = 1;
        
        [ws updateList:ws.dict pageNum:ws.pageNum];
    }];
    
    [self.tableview addInfiniteScrollingWithActionHandler:^{
        ws.pageNum ++;
        
        [ws updateList:ws.dict pageNum:ws.pageNum];


    }];
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
    [tempAppDelegate.leftSlideVC setPanEnabled:NO];
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

    App(app);
    [app jumpToPlayViewController:dict];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellHeight = (120+8*2)*XA;
    return cellHeight;
}



#pragma method

- (void)updateList:(NSDictionary *)dict pageNum:(NSInteger)pageNum
{
    self.pageNum = pageNum;
    
    self.dict = dict;
    self.title = dict[@"title"];

    //NSString *url = [NSString stringWithFormat:@"%@category_album/%@/％ld/%ld", HOST, dict[@"tag"], (long)self.pageNum, (long)PageSize];
    
    WS(ws);
    [HttpEngine getDataFromServer:[NSString stringWithFormat:@"%@category_album/%@/%ld/%ld", HOST, dict[@"tag"], (long)self.pageNum, (long)PageSize] type:ServerDataRequestTypeCategory callback:^(NSArray *albums) {
        [self.tableview.pullToRefreshView stopAnimating];
        [self.tableview.infiniteScrollingView stopAnimating];

        if (albums == nil) {
            
            return ;
        }
        
        if (albums.count == 0) {
            
            [TSMessage showNotificationWithTitle:nil
                                        subtitle:NoMoreData
                                            type:TSMessageNotificationTypeMessage];
            
            return;
        }
        
        NSMutableArray *newalbums = nil;
        NSMutableArray *arrCells=[NSMutableArray array];
        if (1 == ws.pageNum) {
            newalbums = [NSMutableArray arrayWithArray:albums];;
        }
        else
        {
            newalbums = [NSMutableArray arrayWithArray:ws.dataArray];
            
            NSUInteger count = ws.dataArray.count;
            for (NSDictionary *moreDict in albums) {
                [arrCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [newalbums insertObject:moreDict atIndex:count++];
            }
        }

        ws.dataArray = newalbums;
        
        if (1 == ws.pageNum) {
            [ws.tableview reloadData];
        }
        else
        {
            [ws.tableview insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }];
    
}

@end
