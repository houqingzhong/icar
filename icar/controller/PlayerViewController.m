    //
//  PlayerViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "PlayerViewController.h"
#import "Public.h"


#define kSectionViewIdentifier @"kSectionViewIdentifier"

@interface PlayerViewController ()<JxbPlayerDelegate>

//@property (nonatomic, strong) PYAudioPlayer        *player;
@property (nonatomic, strong) JxbPlayer     *player;
@property (nonatomic, strong) NSTimer       *timer;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation PlayerViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.player = [[JxbPlayer alloc] initWithMainColor:[UIColor colorWithHexString:@"#ff7d3d"] frame:CGRectMake(0, 20, self.view.width, 100)];
        self.player.delegate = self;
        
    
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    
    [self.view addSubview:self.tableview];
    
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
    
    NSDictionary *track = _dataArray[indexPath.row];
    [cell setData:track];
    
    WS(ws);
    [cell setCallback:^(NSDictionary *dict) {
        [ws download:ws.album track:dict];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *track = _dataArray[indexPath.row];
    [self play:self.album track:track];
    
    App(app);
    TrackCell *playCell = [tableView cellForRowAtIndexPath:indexPath];
    [app.playViewController setCallback:^(CGFloat progress, NSDictionary *album, NSDictionary *track) {
        [playCell updateTime:progress];
    }];
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary *track = _dataArray[indexPath.row];
    return [TrackCell height:track];
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *v = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kSectionViewIdentifier];

    [v addSubview:self.player];

    
    return v;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 130;
}

- (void)play:(NSDictionary *)album track:(NSDictionary *)track
{
    
    [PublicMethod saveHistory:album track:track callback:nil];
    
    App(app);
    NSMutableDictionary *mediaItemInfo = [NSMutableDictionary new];
    if (album[@"title"]) {
        mediaItemInfo[@"albumTitle"] = album[@"title"];
    }
    
    if (track[@"title"]) {
        mediaItemInfo[@"title"] = track[@"title"];
    }
    
    mediaItemInfo[@"icon"] = [UIImage imageNamed:@"AppIcon"];
    mediaItemInfo[@"duration"] = track[@"duration"];
    mediaItemInfo[@"curTime"] = @"0";
    
    app.mediaItemInfo = mediaItemInfo;
    
    
    self.album = album;
    self.track = track;
    
    NSURL *fileUrl = [[DownloadClient sharedInstance] getDownloadFile:album track:track];
    
    if (nil == fileUrl && ![[DownloadClient sharedInstance] isWifi]) {
        
        if ([[DownloadClient sharedInstance] is3G] && ![PublicMethod isAllowPlayInGprs]) {
            [self playNext];
            return;
        }
        
    }
    
//    if (![[DownloadClient sharedInstance] hasNetwork]) {
//        
//        [self playNext];
//        
//        return;
//    }

    
    if (!fileUrl && ![NSObject isNull:track[@"play_path_32"]]) {

        fileUrl = [NSURL URLWithString:track[@"play_path_32"]];
    }
    
    if (!fileUrl && ![NSObject isNull:track[@"play_path_64"]]) {
        fileUrl = [NSURL URLWithString:track[@"play_path_64"]];
    }
    
    self.player.itemUrl = [fileUrl absoluteString];
    
    [self.player play];
    [self.player setBBegin:YES];
    
    [PublicMethod getHistoryTrack:_track[@"id"] callback:^(NSDictionary * localTrack) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (localTrack) {

                NSTimeInterval time = [localTrack[@"time"] doubleValue];

                if ([localTrack[@"duration"] doubleValue] - time < 2) {
                    time = 1;
                }
                
                if (time > 0) {
                    [self.player seekToTime:time];
                }

            }
            
        });
        
    }];

    
}


- (void)download:(NSDictionary *)album track:(NSDictionary *)track
{
    if ([track objectForKey:@"download_state"]) {
        return;
    }
    
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"id"] integerValue] == [track[@"id"] integerValue]) {
            obj[@"download_state"] = @(0);
        }
    }];
    
    [PublicMethod saveDownload:album track:track progress:0 state:DownloadStateDownloadWait];
    
    [[DownloadClient sharedInstance] startDownload];
    
}

#pragma method

- (void)updateList:(NSDictionary *)album track:(NSDictionary *)track
{
    [self updateList:album pageNum:1];
    
    [self play:album track:track];
    
}

- (NSInteger)getCurrentRow
{
    __block NSInteger row = -1;
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"id"] isEqualToString:self.track[@"id"]]) {
                
                row = idx;
                *stop = YES;
            }
        }];
    
    return row;
}

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

- (void)playPre
{
    NSIndexPath* currentPath = [self.tableview indexPathForSelectedRow];
    NSInteger row = currentPath.row - 1;
    
    if (row < 0) {
        row = -1;
    }
    
    
    if (-1 == row) {
        
        return;
    }
    
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:row inSection:currentPath.section];
    [self.tableview selectRowAtIndexPath:preIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    NSDictionary *track = _dataArray[preIndexPath.row];
    [self play:self.album track:track];

}

- (void)playEvent
{
    [self.player playEvent];
}

- (void)pauseEvent
{
    [self.player pauseEvent];
}


- (void)playNext
{
    
    NSLog(@"play next");
    
    NSIndexPath* currentPath = [self.tableview indexPathForSelectedRow];
    NSInteger row = currentPath.row + 1;
    
    if (row <= _dataArray.count - 1) {
        
    }
    else
    {
        row = -1;
    }
    
    if (-1 == row) {
        return;
    }
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:row inSection:currentPath.section];
    [self.tableview selectRowAtIndexPath:nextIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    
    NSDictionary *track = _dataArray[nextIndexPath.row];
    [self play:self.album track:track];
    
}

#pragma PYPlayerDelegate

- (void)XBPlayer_play
{
    NSLog(@"XBPlayer_play");
}

- (void)XBPlayer_pause
{
    NSLog(@"XBPlayer_pause");
}

- (void)XBPlayer_stop
{
    NSLog(@"XBPlayer_stop");
    [self playNext];
}

- (void)XBPlayer_playDuration:(NSTimeInterval)duration
{
    NSLog(@"XBPlayer_playDuration %f", duration);
    
    if (_callback) {
        _callback(duration, self.album, self.track);
    }
    
    
    App(app);
    NSMutableDictionary *mediaItemInfo = [NSMutableDictionary dictionaryWithDictionary:app.mediaItemInfo];

    mediaItemInfo[@"curTime"] = [NSString stringWithFormat:@"%f", duration];
    
    app.mediaItemInfo = mediaItemInfo;
    
    [app configNowPlayingInfoCenter];

    if (self.album && self.track && [self.player playableCurrentTime] > 0) {
        [PublicMethod updateHistory:_album[@"id"] trackId:_track[@"id"] time:[self.player playableCurrentTime] callback:nil];
    }
    
    
}

- (void)XBPlayer_next
{
    [self playNext];
}

- (void)XBPlayer_pre
{
    [self playPre];
}

@end
