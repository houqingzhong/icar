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

@property (nonatomic,strong) PlayerView  *playerView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSArray *localArray;

@end

@implementation TrackViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _playingInfo = [NSMutableDictionary new];
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

    [self.view addSubview:self.tableview];
    
    self.playerView = [PlayerView new];
    [self.view addSubview:self.playerView];
    
    [_playerView anchorBottomCenterFillingWidthWithLeftAndRightPadding:0 bottomPadding:0 height:120*XA];
    
    WS(ws);
    [_playerView setCallback:^(NSString *albumId, NSString *trackId, PlayerActionType actionType, PlayModeType playMode) {
        
        if (ws.dataArray.count == 0) {
            return ;
        }
        
        if (nil == ws.indexPath) {
            
            [ws.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"id"] integerValue] == trackId.integerValue) {
                    ws.indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    *stop = YES;
                }
            }];
            
        }
        
        if (PlayerActionTypeNext == actionType) {
            
            if ([[DownloadClient sharedInstance] hasNetwork]) {
                NSIndexPath *nextPlayIndexPath = [PublicMethod getNextPlayIndexPath:playMode currentIndexPath:ws.indexPath dataArray:ws.dataArray];
                NSDictionary *track = ws.dataArray[nextPlayIndexPath.row];
                [ws play:ws.album track:track];
            }
            else
            {
                [ws playNextLocal];
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

    
    [self setPlayState:_album];
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
    
    self.indexPath = indexPath;

    NSDictionary *dict = _dataArray[indexPath.row];
    [self play:self.album track:dict];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    return [TrackCell height:_dataArray[indexPath.row]];
}


- (PlayType)play:(NSDictionary *)album track:(NSDictionary *)track
{
    [_playerView setData:album track:track];
    
    return [self play:album track:track target:_playerView slider:[_playerView getProgressView]];
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
    [self updateList:album localArray:nil pageNum:pageNum];
}

- (void)updateList:(NSDictionary *)album localArray:(NSArray *)localArray pageNum:(NSInteger)pageNum
{
    self.localArray = nil;
    
    WS(ws);
    [PublicMethod getDownloadTracks:album[@"id"] callback:^(NSArray *ts) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.localArray = ts;
        });
    }];

    
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
                
                
                
                [self setPlayState:album];
            });
            
        }];
    }];
    
}

- (PlayType)play:(NSDictionary *)album track:(NSDictionary *)track target:(id<BABAudioPlayerDelegate>)target slider:(UISlider *)slider
{
    if (!album || !track) {
        
        return PlayTypeDataError;
    }

    App(app);
    
    if ([self.track[@"id"] integerValue] == [track[@"id"] integerValue]) {
        
        return PlayTypeSame;
    }
    
    [[BABAudioPlayer sharedPlayer] pause];

    PlayType playType = PlayTypeOnline;
    if (![NSObject isNull:track[@"play_path_32"]]) {
        
        NSURL *fileUrl = [[DownloadClient sharedInstance] getDownloadFile:album track:track];
        
        BABAudioItem *playItem = nil;
        if (fileUrl) {
            playItem = [BABAudioItem audioItemWithURL:fileUrl];
            [playItem setLocal:YES];
            playType = PlayTypeLocal;
        }
        else
        {
            fileUrl = [NSURL URLWithString:track[@"play_path_32"]];
            if (![[DownloadClient sharedInstance] hasNetwork]) {
                
                [TSMessage showNotificationWithTitle:nil
                                            subtitle:NetworkError
                                                type:TSMessageNotificationTypeMessage];
                
                [[BABAudioPlayer sharedPlayer] stop];
                return PlayTypeNetError;
            }
            else if (![[DownloadClient sharedInstance] isWifi] && ![PublicMethod isAllowPlayInGprs])
            {
                
                [TSMessage showNotificationWithTitle:nil
                                            subtitle:NotAllowedPlayError
                                                type:TSMessageNotificationTypeMessage];
                
                [[BABAudioPlayer sharedPlayer] stop];
                
                return PlayTypeNetError;
            }
            
            playItem = [BABAudioItem audioItemWithURL:fileUrl];

            playType = PlayTypeOnline;
        }

        [[BABAudioPlayer sharedPlayer] queueItem:playItem];
        
    }
    else
    {
        return PlayTypeDataError;
    }
    
    
    [PublicMethod saveHistory:album track:track callback:nil];
    
    [BABAudioPlayer sharedPlayer].delegate = target;
    
    BABConfigureSliderForAudioPlayer(slider, [BABAudioPlayer sharedPlayer]);
    
    
    app.isPlayed = YES;
    app.isStoped = NO;

    self.playingInfo[@"album_id"] = album[@"id"];
    self.playingInfo[@"track_id"] = track[@"id"];
    
    [PublicMethod getHistoryTrack:track[@"id"] callback:^(NSDictionary * localTrack) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (localTrack) {
                
                float value = [localTrack[@"time"] doubleValue]/[track[@"duration"] floatValue];
                
                NSTimeInterval time = [localTrack[@"time"] doubleValue];
                if (value >= 1.0) {
                    value = 0;
                    time = 0;
                }
                
                [[BABAudioPlayer sharedPlayer] seekToTime:time];
                
                
                slider.value = value;
                
            }
            
            [[BABAudioPlayer sharedPlayer] play];
            
            [self setPlayState:track];
        });
        
    }];
    
    return  playType;
}


- (void)setPlayState:(NSDictionary *)album
{
    App(app);
    if(app.isPlayed)
    {
        if (album && [album[@"id"] integerValue] == [self.playingInfo[@"album_id"] integerValue]) {
            
            BOOL isExist = NO;
            NSInteger index = 0;
            for(NSInteger i = 0; i < self.dataArray.count; i++)
            {
                NSDictionary *track = self.dataArray[i];
                if ([track[@"id"] integerValue] == [self.playingInfo[@"track_id"] integerValue]) {
                    isExist = YES;
                    index = i;
                    break;
                }
                
            }
            
            if (isExist) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
                self.indexPath = indexPath;
                
                [self.tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                
            }
            
        }
        
    }
}

- (PlayModeType)getPlayMode
{
    return _playerView.playModeType;
}


- (void)playNextLocal
{
    for (int i = 0; i < _dataArray.count; i++) {
        if (i > self.indexPath.row) {
            NSDictionary *track = _dataArray[i];
            NSURL *fileUrl = [[DownloadClient sharedInstance] getDownloadFile:self.album track:track];
            if (fileUrl) {
                self.indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self setPlayState:self.album];
                [self play:self.album track:track];
                break;
            }
            
        }
    }
    
}

//- (void)setLocalArray
//{
//    NSMutableArray *array = [NSMutableArray new];
//    WS(ws);
//    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull track, NSUInteger idx, BOOL * _Nonnull stop)
//     {
//         NSURL *fileUrl = [[DownloadClient sharedInstance] getDownloadFile:ws.album track:track];
//         if (fileUrl) {
//             [array addObject:track];
//         }
//         
//     }];
//    
//    self.localArray = array;
//}
@end
