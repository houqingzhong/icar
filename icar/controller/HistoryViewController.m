//
//  HistoryViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/18.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()<BABAudioPlayerDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [BABAudioPlayer sharedPlayer].delegate = self;

    [self updateList];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    [cell setData:_dataArray[indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dict = _dataArray[indexPath.row];
    App(app);
    [app play:dict track:dict[@"track"] target:self slider:nil];
    
    [app.playViewController updateList:dict pageNum:1];
    
    NavPlayButton *btn = self.navigationItem.rightBarButtonItem.customView;
    [btn startAnimation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat cellHeight = (120+8*2)*XA;
    return cellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *dict = _dataArray[indexPath.row];
        
        WS(ws);
        [PublicMethod deleteHistoryAlbum:dict[@"id"] callback:^(BOOL sucess) {
            
            [ws.dataArray removeObjectAtIndex:indexPath.row];
        }];
        
        // Delete the row from the data source.
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
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
            
            NSDictionary *album_ = [[rs stringForColumn:@"album_info"] objectFromJSONString];
            NSMutableDictionary *album = [NSMutableDictionary dictionaryWithDictionary:album_];

            NSDictionary *track_ = [[rs stringForColumn:@"track_info"] objectFromJSONString];
            NSMutableDictionary *track = [NSMutableDictionary dictionaryWithDictionary:track_];
            track[@"time"] = @([rs doubleForColumn:@"time"]);
            album[@"track"] = track;
            
            [arr addObject:album];
            
        }
        
        [rs close];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataArray = arr;
            [self.tableview reloadData];

            [self setPlayState];
        });
        

    }];
}


- (void)setPlayState
{
    App(app);
    if(app.isPlayed)
    {
        
        NSDictionary *lastPlayalbum = app.currentPlayInfo[@"album"];

        BOOL isExist = NO;
        NSInteger index = 0;
        for(NSInteger i = 0; i < self.dataArray.count; i++)
        {
            NSDictionary *album = self.dataArray[i];
            
            if (lastPlayalbum && [lastPlayalbum[@"id"] integerValue] == [album[@"id"] integerValue]) {
                if ([album[@"id"] integerValue] == [lastPlayalbum[@"id"] integerValue]) {
                    isExist = YES;
                    index = i;
                    break;
                }
            }
        }
        
        if (isExist) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            
        }
        
    }
    
}

#pragma BABAudioPlayerDelegate
- (void)audioPlayer:(BABAudioPlayer *)player didChangeElapsedTime:(NSTimeInterval)elapsedTime percentage:(float)percentage
{
    App(app);
    NSDictionary *track = app.currentPlayInfo[@"track"];
    NSDictionary *album = app.currentPlayInfo[@"album"];
    [PublicMethod updateHistory:album[@"id"] trackId:track[@"id"] time:elapsedTime callback:^{
        
    }];
    
    NSInteger albumid = [album[@"id"] integerValue];
    for (HistoryCell *cell in self.tableview.visibleCells) {
        
        NSDictionary *calbum = cell.dict;
        NSInteger calbumid = [calbum[@"id"] integerValue];
        if (calbumid == albumid) {
            [cell updateTime:elapsedTime];
            break;
        }
    }
    
}

@end
