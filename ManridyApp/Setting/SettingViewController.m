//
//  SettingViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingContentView.h"

@interface SettingViewController ()

@property (nonatomic ,weak) SettingContentView *setView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:@"设置"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = titleLabel;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
   self.setView.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
//    [self.view addSubview:self.setView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.setView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (SettingContentView *)setView
{
    if (!_setView) {
        SettingContentView *view = [[SettingContentView alloc] initWithFrame:self.view.bounds];
        
        
        [self.view addSubview:view];
        _setView = view;
    }
    
    return _setView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
