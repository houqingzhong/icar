//
//  DownloadingViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/19.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadingViewController.h"

#import "Public.h"

@interface DownloadingViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *album;

@end

@implementation DownloadingViewController

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
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame)) style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    
    [[DownloadClient sharedInstance] setCallback:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.tableview reloadData];
    
    [self updateList:self.album];
    
    WS(ws);
    [[DownloadClient sharedInstance] setCallback:^(CGFloat progress, NSString *albumId, NSString *trackId, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        if ([ws.album[@"id"] integerValue] == albumId.integerValue) {
            
            NSArray *cells = [ws.tableview visibleCells];
            [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadingCell *cell = obj;
                if([cell.dict[@"id"] integerValue] == trackId.integerValue)
                {
                    
                    DownloadState state = 0;
                    if (progress >= 1.0) {
                        state = DownloadStateDownloadFinish;
                        
                        NSIndexPath *indexPath = [ws.tableview indexPathForCell:cell];
                        NSMutableDictionary *newTrack = [NSMutableDictionary dictionaryWithDictionary:cell.dict];
                        newTrack[@"download_state"] = @(DownloadStateDownloadFinish);
                        [ws.dataArray replaceObjectAtIndex:indexPath.row withObject:newTrack];
                    }
                    else
                    {
                        state = DownloadStateDownloading;
                    }
                    
                    [PublicMethod updateDownloadState:albumId trackId:trackId progress:progress state:state callback:nil];
                    
                    [cell setProgress:progress];
                }
                
            }];
            
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (0 == section) {
        return 90*XA;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        NSString *headerIdentifier = @"section-0-headerview-2";
        
        AddNewDownloadHeaderView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if (nil == headerView) {
            headerView = [[AddNewDownloadHeaderView alloc] initWithReuseIdentifier:headerIdentifier];
        }
        
        WS(ws);
        [headerView setCallback:^{
            [ws showTrackViewController];
        }];
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
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[DownloadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
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
    NSDictionary *dict = _dataArray[indexPath.row];
    
//    App(app);
//    [app updateTrackViewControler:self.album pageNum:1];
//    PlayType playType = [app play:self.album track:dict];
//    
//    if (PlayTypeNetError == playType) {
//        [self playNextIndexPath:[app.playViewController getPlayMode] currentIndexPath:indexPath dataArray:_dataArray];
//    }
    
    
    App(app);
    [app updateTrackViewControler:self.album track:dict pageNum:1];
    [app jumpToPlayViewController];
    

    
    NavPlayButton *btn = self.navigationItem.rightBarButtonItem.customView;
    [btn startAnimation];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return [DownloadingCell height:_dataArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dict = _dataArray[indexPath.row];

        WS(ws);
        [PublicMethod deleteDownloadTrack:dict[@"id"] callback:^(BOOL sucess) {
            NSString *fileFolder = [[DownloadClient sharedInstance] getDownloadPath:ws.album];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];

            NSString *file = [NSString stringWithFormat:@"%@/%@.m4a", fileFolder, dict[@"id"]];
            
            NSError *err = nil;
            if ([fileManager removeItemAtPath:file error:&err] != YES)
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

- (void)updateList:(NSDictionary *)dict
{
    
    self.album = dict;
    
    self.title = dict[@"title"];
    
    self.dataArray = nil;
    [self.tableview reloadData];
    
    
    WS(ws);
    
    [PublicMethod getDownloadTracks:dict[@"id"] callback:^(NSArray *ts) {
        
        NSMutableArray *newTracks = [NSMutableArray new];

        
        [ts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *newTrack = [NSMutableDictionary dictionaryWithDictionary:obj];
            newTrack[@"progress"] = obj[@"progress"];
            newTrack[@"download_state"] = obj[@"download_state"];
            [newTracks addObject:newTrack];
        }];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.dataArray = newTracks;
            
            [ws.tableview reloadData];
            
        });
    }];

}

- (void)showTrackViewController
{
    
    App(app);
    [app jumpToPlayViewController];

}


@end

