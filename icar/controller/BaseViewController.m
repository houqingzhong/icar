//
//  BaseViewController.m
//  icar
//
//  Created by lizhuzhu on 15/10/17.
//  Copyright © 2015年 lizhuzhu. All rights reserved.
//

#import "BaseViewController.h"
#import "Public.h"

@interface BaseViewController ()
{
    NavPlayButton *_rightBtn;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageNum = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    
    _rightBtn = [NavPlayButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(0, 0, 60*XA, 60*XA);
    [_rightBtn addTarget:self action:@selector(openPlayList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    App(app);
    [app.leftSlideVC setPanEnabled:NO];

    if(app.isPlayed)
    {
        [_rightBtn startAnimation];
    }
    else
    {
        [_rightBtn stopAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    
    App(app);
    [app.leftSlideVC setPanEnabled:NO];
    
    [self.tableview.pullToRefreshView stopAnimating];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)openPlayList
{
    App(app);

    if(app.isPlayed)
    {
        App(app);
        if (app.playViewController.navigationController) {
            [app.mainNavigationController popToViewController:app.playViewController animated:YES];
        }
        else
        {
            [app.mainNavigationController pushViewController:app.playViewController animated:YES];
        }
    }

}


- (void)startPlayAnimation
{
    [_rightBtn startAnimation];
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
}
@end
