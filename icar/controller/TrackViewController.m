//
//  TrackViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "TrackViewController.h"

#import "Public.h"

@interface TrackViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) PlayerView  *playerView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSDictionary *album;
@end

@implementation TrackViewController

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
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame) - 120*XA) style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    //_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    
    self.playerView = [PlayerView new];
    [self.view addSubview:self.playerView];
    
    [_playerView anchorBottomCenterFillingWidthWithLeftAndRightPadding:0 bottomPadding:0 height:120*XA];
    
    
    WS(ws);
    [_playerView setCallback:^(PlayerActionType actionType, PlayModeType playMode) {
        
    }];
    
    [_playerView setCallback:^(PlayerActionType actionType, PlayModeType playMode) {
        if (ws.dataArray.count == 0) {
            return ;
        }
        
        if (PlayerActionTypeNext == actionType) {
            
            if (PlayModeTypeSingle == playMode) {
                
                if (nil == ws.indexPath) {
                    ws.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [ws.tableview selectRowAtIndexPath:ws.indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                }
             
                NSDictionary *dict = ws.dataArray[ws.indexPath.row];
                [ws play:dict];
                
            }
            else
            {
                if (nil == ws.indexPath) {
                    ws.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [ws.tableview selectRowAtIndexPath:ws.indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                    NSDictionary *dict = ws.dataArray[ws.indexPath.row];
                    [ws play:dict];

                }
                else if (ws.indexPath.row + 1 <= ws.dataArray.count-1)
                {
                    ws.indexPath = [NSIndexPath indexPathForRow:ws.indexPath.row+1 inSection:ws.indexPath.section];
                    
                    [ws.tableview selectRowAtIndexPath:ws.indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

                    NSDictionary *dict = ws.dataArray[ws.indexPath.row];
                    [ws play:dict];
                }
                else
                {
                    if (PlayModeTypeLoop == playMode) {
                        ws.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        NSDictionary *dict = ws.dataArray[ws.indexPath.row];
                        [ws play:dict];
                    }

                }
                
            }
        }
    }];
    
    
    [self.tableview addPullToRefreshWithActionHandler:^{
        ws.pageNum ++;
        [ws updateList:ws.album pageNum:ws.pageNum];
    }];
    
    [self.tableview addInfiniteScrollingWithActionHandler:^{
        ws.pageNum ++;
        
        [ws updateList:ws.album pageNum:ws.pageNum];
        
        
    }];

}

- (void) openOrCloseLeftList
{
    App(app);
    
    if (app.leftSlideVC.closed)
    {
        [app.leftSlideVC openLeftView];
    }
    else
    {
        [app.leftSlideVC closeLeftView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    App(app);
    [app.leftSlideVC setPanEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    App(app);
    [app.leftSlideVC setPanEnabled:NO];
    
    [BABAudioPlayer sharedPlayer].delegate = _playerView;
    
    BABConfigureSliderForAudioPlayer([_playerView getProgressView], [BABAudioPlayer sharedPlayer]);

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
    
    if (![[DownloadClient sharedInstance] hasNetwork]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    self.indexPath = indexPath;

    NSDictionary *dict = _dataArray[indexPath.row];
    [self play:dict];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    return [TrackCell height:_dataArray[indexPath.row]];
}


- (void)play:(NSDictionary *)dict
{
    [_playerView setData:dict album:self.album time:0];
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

- (void)updateList:(NSDictionary *)dict  pageNum:(NSInteger)pageNum
{
    
    if (1 == pageNum) {
        
        self.dataArray = nil;
        
        [self.tableview reloadData];
        
    }
    self.pageNum = pageNum;
    
    self.album = dict;
    
    self.title = dict[@"title"];
    
    
    WS(ws);
    NSString *key = [NSString stringWithFormat:@"%@:%@:%@", @(ServerDataRequestTypeTrack), dict[@"id"], @(pageNum)];
    [HttpEngine getDataFromServer:[NSString stringWithFormat:@"%@tracks/%@/%ld/%ld", HOST, dict[@"id"], (long)self.pageNum, (long)PageSize] key:key callback:^(NSArray *arr) {
        
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

        
        [PublicMethod getDownloadTracks:dict[@"id"] callback:^(NSArray *ts) {

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
                
                [ws setPlayState:dict];
                
            });
            
        }];
        
        

    }];
    
}

- (void)setPlayState:(NSDictionary *)album
{
    App(app);
    if(app.isPlayed)
    {
        
        NSDictionary *lastPlayalbum = app.currentPlayInfo[@"album"];
        NSDictionary *lastPlaytrack = app.currentPlayInfo[@"track"];
        
        if (lastPlayalbum && [lastPlayalbum[@"id"] integerValue] == [album[@"id"] integerValue]) {
            
            BOOL isExist = NO;
            NSInteger index = 0;
            for(NSInteger i = 0; i < self.dataArray.count; i++)
            {
                NSDictionary *track = self.dataArray[i];
                if ([track[@"id"] integerValue] == [lastPlaytrack[@"id"] integerValue]) {
                    isExist = YES;
                    index = i;
                    break;
                }
                
            }
            
            if (isExist) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                
            }
            
        }
        
    }
}
@end
