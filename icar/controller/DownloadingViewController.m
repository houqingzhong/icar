//
//  DownloadingViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/19.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "DownloadingViewController.h"

#import "Public.h"

@interface DownloadingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDictionary *album;
@property (nonatomic,strong) UITableView *tableview;

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
    NSLog(@"viewWillAppear");
    
    WS(ws);
    [[DownloadClient sharedInstance] setCallback:^(CGFloat progress, NSString *albumId, NSString *trackId) {
        if ([ws.album[@"id"] integerValue] == albumId.integerValue) {
            
            NSArray *cells = [ws.tableview visibleCells];
            [cells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadingCell *cell = obj;
                if([cell.dict[@"id"] integerValue] == trackId.integerValue)
                {
                    [cell setProgress:progress];
                }
                
            }];
            
        }
    }];
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

    App(app);
    [app play:self.album track:dict target:nil slider:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return [DownloadingCell height:_dataArray[indexPath.row]];
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
    
    [HttpEngine recommend:[NSString stringWithFormat:@"%@tracks/%@", HOST, dict[@"id"]] callback:^(NSArray *arr) {
        
        if (nil == arr) {
            return ;
        }
        NSMutableArray *newTracks = [NSMutableArray new];
        
        [PublicMethod getDownloadTracks:dict[@"id"] callback:^(NSArray *ts) {
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSMutableDictionary *newTrack = [NSMutableDictionary dictionaryWithDictionary:obj];
                
                [ts enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    if ([obj2[@"id"] integerValue] == [obj[@"id"] integerValue]) {
                        newTrack[@"progress"] = obj2[@"progress"];
                        newTrack[@"download_state"] = obj2[@"download_state"];
                    }
                }];
                
                [newTracks addObject:newTrack];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.dataArray = newTracks;
                
                [ws.tableview reloadData];
                
            });
        }];
    }];
    
}

@end

