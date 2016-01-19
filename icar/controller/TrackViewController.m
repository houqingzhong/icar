//
//  TrackViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "TrackViewController.h"

#import "Public.h"

@interface TrackViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property(nonatomic,strong)GADBannerView *bannerView;
@end

@implementation TrackViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WS(ws);
    App(app);
    [app.playViewController setCallback:^(CGFloat progress, NSDictionary *album, NSDictionary *track) {
        __weak TrackCell *playCell = nil;
        for (TrackCell *cell in self.tableview.visibleCells) {
            if ([track[@"id"] integerValue] == [cell.dict[@"id"] integerValue]) {
                playCell = cell;
                break;
            }
        }
        
        if (playCell) {
            [playCell updateTime:progress];
            NSIndexPath *indexPath = [ws.tableview indexPathForCell:playCell];
            [ws.tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
    }];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    App(app);
    [app.playViewController setCallback:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = nil;
    

    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) ) style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;

    [self.view addSubview:self.tableview];
    
    _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 50)];
    self.bannerView.adUnitID = @"ca-app-pub-6092667862424445/3909770617";
    self.bannerView.rootViewController = self;
    
    [self.view addSubview:self.bannerView];
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
    
    WS(ws);
    [self.tableview addPullToRefreshWithActionHandler:^{
        ws.pageNum ++;
        [ws updateList:ws.album pageNum:ws.pageNum];
    }];
    
    [self.tableview addInfiniteScrollingWithActionHandler:^{
        ws.pageNum ++;
        [ws updateList:ws.album pageNum:ws.pageNum];
        
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    [cell setData:_dataArray[indexPath.row]];
    
    WS(ws);
    [cell setCallback:^(NSDictionary *dict) {
        [ws download:dict];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *track = _dataArray[indexPath.row];

    App(app);

    [app.playViewController updateList:self.album track:track];
    
    TrackCell *playCell = [tableView cellForRowAtIndexPath:indexPath];
    [app.playViewController setCallback:^(CGFloat progress, NSDictionary *album, NSDictionary *track) {
        [playCell updateTime:progress];
    }];
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    return [TrackCell height:_dataArray[indexPath.row]];
}

- (void)download:(NSDictionary *)dict
{
    if ([dict objectForKey:@"download_state"]) {
        return;
    }

    __block BOOL flag = NO;
    __block  NSInteger index = 0;
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:_dataArray];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"id"] integerValue] == [dict[@"id"] integerValue]) {
            flag = YES;
            index = idx;
        }
    }];

    NSMutableDictionary *newTrack = [[NSMutableDictionary alloc] initWithDictionary:dict];
    newTrack[@"download_state"] = @"0";
    [arr replaceObjectAtIndex:index withObject:newTrack];
    self.dataArray = arr;
    
    [PublicMethod saveDownload:self.album track:dict progress:0 state:DownloadStateDownloadWait];

    [[DownloadClient sharedInstance] startDownload];
    
}

#pragma method

- (void)updateList:(NSDictionary *)album pageNum:(NSInteger)pageNum
{
    WS(ws);
    
    if (1 == pageNum) {
        
        self.dataArray = nil;
        
        [self.tableview reloadData];
        
    }
    self.pageNum = pageNum;
    
    self.album = album;
    
    self.title = album[@"title"];
    
    
    NSString *key = [NSString stringWithFormat:@"%@:%@:%@", @(ServerDataRequestTypeTrack), album[@"id"], @(pageNum)];
    [HttpEngine getDataFromServer:[NSString stringWithFormat:@"%@tracks/%@/%ld/%ld", HOST, album[@"id"], (long)self.pageNum, (long)MPageSize] key:key callback:^(NSArray *arr) {
        
        [ws.tableview.pullToRefreshView stopAnimating];
        [self.tableview.infiniteScrollingView stopAnimating];
        
        if (nil == arr) {
            return ;
        }
        
        if (arr.count == 0) {
            
            [TSMessage showNotificationWithTitle:nil
                                        subtitle:NoMoreData
                                            type:TSMessageNotificationTypeMessage];

            return;
        }
        
        NSMutableArray *newTracks = nil;
        NSMutableArray *arrCells=[NSMutableArray array];
        
        if (1 == ws.pageNum) {
            newTracks = [NSMutableArray arrayWithArray:arr];;
        }
        else
        {
            newTracks = [NSMutableArray arrayWithArray:ws.dataArray];
            
            NSUInteger count = ws.dataArray.count;
            for (NSDictionary *moreDict in arr) {
                [arrCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [newTracks insertObject:moreDict atIndex:count++];
            }
        }

        [PublicMethod getDownloadTracks:album[@"id"] callback:^(NSArray *ts) {

            [newTracks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSMutableDictionary *newTrack = [NSMutableDictionary dictionaryWithDictionary:obj];
                
                [ts enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    if ([obj2[@"id"] integerValue] == [obj[@"id"] integerValue]) {
                        newTrack[@"progress"] = obj2[@"progress"];
                        newTrack[@"download_state"] = obj2[@"download_state"];
                    }
                }];
                
                [newTracks replaceObjectAtIndex:idx withObject:newTrack];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.dataArray = newTracks;
                
                if (1 == ws.pageNum) {
                    [ws.tableview reloadData];
                }
                else
                {
                    [ws.tableview insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
            });
            
        }];
    }];
}
@end
