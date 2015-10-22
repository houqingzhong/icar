//
//  DownloadViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadViewController.h"

#import "Public.h"

@interface DownloadViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DownloadViewController

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
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    [self.view addSubview:self.tableview];
    
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
    
    [self updateList];
    
    WS(ws);
    __block NSInteger currentDownloadTrackId = 0;
    __block NSDictionary *currentDownloadTrack = nil;
    [[DownloadClient sharedInstance] setCallback:^(CGFloat progress, NSString *albumId, NSString *trackId, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        NSString *downloadSize = [NSString stringWithFormat:@"%0.2f", (float)totalBytesWritten/1024/1024];
        NSString *totalSize = [NSString stringWithFormat:@"%0.2f", (float)totalBytesExpectedToWrite/1024/1024];

        if (currentDownloadTrackId == 0 || currentDownloadTrackId != trackId.integerValue) {
            currentDownloadTrackId = trackId.integerValue;
            [PublicMethod getDownloadTask:trackId callback:^(NSDictionary *tdic) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tdic];
                dict[@"progress"] = @(progress);
                dict[@"size"] = [NSString stringWithFormat:@"%@/%@", downloadSize, totalSize];
                currentDownloadTrack = dict;
                [ws updateHeader:dict];

            }];
        }
        else
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:currentDownloadTrack];
            dict[@"progress"] = @(progress);
            dict[@"size"] = [NSString stringWithFormat:@"%@/%@", downloadSize, totalSize];
            currentDownloadTrack = dict;
            [ws updateHeader:dict];
        }
        
    }];
}

- (void)updateHeader:(NSDictionary *)dict
{
    ShowDownloadingCell *headerView = (ShowDownloadingCell *)[self.tableview headerViewForSection:0];

    [headerView setData:dict];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (0 == section) {
        return 130*XA;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        NSString *headerIdentifier = @"section-0-headerview";
        
        ShowDownloadingCell * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if (nil == headerView) {
            headerView = [[ShowDownloadingCell alloc] initWithReuseIdentifier:headerIdentifier];
        }

        return headerView;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[DownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    [cell setData:_dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _dataArray[indexPath.row];
    DownloadingViewController *dc = [DownloadingViewController new];
    [dc updateList:dict];
    
    App(app);
    [app.mainNavigationController pushViewController:dc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellHeight = (120+8*2)*XA;
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSDictionary *dict = _dataArray[indexPath.row];
        
        WS(ws);
        [PublicMethod deleteDownloadAlbum:dict[@"id"] callback:^(BOOL sucess) {
            
            NSString *fileFolder = [[DownloadClient sharedInstance] getDownloadPath:dict];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            //NSString *file = [NSString stringWithFormat:@"%@/%@.m4a", fileFolder, dict[@"id"]];
            
            NSError *err = nil;
            if ([fileManager removeItemAtPath:fileFolder error:&err] != YES)
            {
                NSLog(@"%@", err);
            }
            
            [ws.dataArray removeObjectAtIndex:indexPath.row];
        }];
        
        
        // Delete the row from the data source.
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma method

- (void)updateList
{
    self.title = @"下载管理";
    self.dataArray = nil;
    [self.tableview reloadData];
    
    App(app);
    
    [app.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select * from download group by album_id order by timestamp DESC"];
        
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

@end
