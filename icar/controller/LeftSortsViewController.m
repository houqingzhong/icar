//
//  LeftSortsViewController.m
//  LGDeckViewController
//
//  Created by jamie on 15/3/31.
//  Copyright (c) 2015年 Jamie-Ling. All rights reserved.
//

#import "LeftSortsViewController.h"
#import "Public.h"
#import "otherViewController.h"

@interface LeftSortsViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation LeftSortsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.image = [UIImage imageNamed:@"leftbackiamge"];
    [self.view addSubview:imageview];

    UITableView *tableview = [[UITableView alloc] init];
    self.tableview = tableview;
    tableview.frame = self.view.bounds;
    tableview.dataSource = self;
    tableview.delegate  = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:20.0f];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"推荐";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"分类";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"收听历史";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"下载管理";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"设置";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    App(app);
    
    [app.leftSlideVC closeLeftView];//关闭左侧抽屉
    if (0 == indexPath.row) {
        [app.mainNavigationController popToRootViewControllerAnimated:NO];
    }
    else if (1 == indexPath.row) {
        if(nil == app.categoryViewController)
        {
            app.categoryViewController = [CategoryViewController new];
        }
        
        if (app.categoryViewController.navigationController) {
            [app.mainNavigationController popToViewController:app.categoryViewController animated:NO];
        }
        else
        {
            [app.mainNavigationController pushViewController:app.categoryViewController animated:NO];
        }
    }
    else if (2 == indexPath.row) {
        if(nil == app.historyViewController)
        {
            app.historyViewController = [HistoryViewController new];
        }
        [app.historyViewController setType:ViewContrllerTypeMenu];
        if (app.historyViewController.navigationController) {
            [app.mainNavigationController popToViewController:app.historyViewController animated:NO];
        }
        else
        {
            [app.mainNavigationController pushViewController:app.historyViewController animated:NO];
        }
    }
    else if (3 == indexPath.row) {
        if(nil == app.downloadViewController)
        {
            app.downloadViewController = [DownloadViewController new];
        }
        
        if (app.downloadViewController.navigationController) {
            [app.mainNavigationController popToViewController:app.downloadViewController animated:NO];
        }
        else
        {
            [app.mainNavigationController pushViewController:app.downloadViewController animated:NO];
        }
    }
    else if (4 == indexPath.row) {
        if(nil == app.msettingViewController)
        {
            app.msettingViewController = [MSettingViewController new];
        }
        
        if (app.msettingViewController.navigationController) {
            [app.mainNavigationController popToViewController:app.msettingViewController animated:NO];
        }
        else
        {
            [app.mainNavigationController pushViewController:app.msettingViewController animated:NO];
        }
    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 180;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableview.bounds.size.width, 180)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
@end
