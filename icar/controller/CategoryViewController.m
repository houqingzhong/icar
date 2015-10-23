//
//  CategoryViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "CategoryViewController.h"
#import "Public.h"

@interface CategoryViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) AlbumListViewController *listViewController;
@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.title = @"分类";

    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 20, 18);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    

    
    _dataArray = [NSMutableArray new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    dict[@"icon"] = @"category_default_img14";
    dict[@"title"] = @"车载电台";
    dict[@"tag"] = @"car";
    [_dataArray addObject:dict];
    

    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img1";
    dict[@"title"] = @"有声小说";
    dict[@"tag"] = @"book";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img2";
    dict[@"title"] = @"音乐";
    dict[@"tag"] = @"music";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img3";
    dict[@"title"] = @"综艺娱乐";
    dict[@"tag"] = @"entertainment";
    [_dataArray addObject:dict];
    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img4";
    dict[@"title"] = @"相声评书";
    dict[@"tag"] = @"comic";
    [_dataArray addObject:dict];
    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img13";
    dict[@"tag"] = @"kid";
    dict[@"title"] = @"儿童";
    [_dataArray addObject:dict];

    
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img6";
    dict[@"title"] = @"情感生活";
    dict[@"tag"] = @"emotion";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img7";
    dict[@"title"] = @"历史人文";
    dict[@"tag"] = @"culture";
    [_dataArray addObject:dict];
    
    dict = [NSMutableDictionary new];
    dict[@"icon"] = @"category_default_img8";
    dict[@"title"] = @"收听历史";
    dict[@"tag"] = @"history";
    [_dataArray addObject:dict];

    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableview.dataSource = self;
    self.tableview.delegate  = self;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataArray.count % 3 == 0) {
        return _dataArray.count/3;
    }
    
    return _dataArray.count/3 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    
    NSInteger count = 3;
    if ((indexPath.row + 1)*3 > _dataArray.count) {
        count = 3- ((indexPath.row + 1)*3 - _dataArray.count);
    }

    NSArray *arr = [_dataArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row *3, count)]];

    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[CategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    [cell setData:arr];
    
    WS(ws);
    [cell setCallback:^(NSDictionary *dict) {
        [ws showList:dict];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    if (_dataArray.count == 0) {
        return 0;
    }
    
    NSInteger count = 3;
    if ((indexPath.row + 1)*3 > _dataArray.count) {
        count = 3- ((indexPath.row + 1)*3 - _dataArray.count);
    }
    
    NSArray *arr = [_dataArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row *3, count)]];

    
    return [CategoryCell height:arr[0]];
    
}


- (void)showList:(NSDictionary *)dict
{
    
    if ([dict[@"tag"] isEqualToString:@"history"]) {

        HistoryViewController *historyViewController = [HistoryViewController new];
        [historyViewController setType:ViewContrllerTypeDefault];
        [self.navigationController pushViewController:historyViewController animated:YES];

    }
    else
    {
        if (nil == self.listViewController) {
            self.listViewController = [AlbumListViewController new];
        }
        [_listViewController updateList:dict pageNum:1];
        
        [self.navigationController pushViewController:_listViewController animated:YES];
    }
}

@end
