//
//  BindPeripheralViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BindPeripheralViewController.h"

@interface BindPeripheralViewController () <UITableViewDelegate ,UITableViewDataSource >
{
    NSMutableArray *_dataArr;
}

@property (nonatomic ,weak) UIView *downView;
@property (nonatomic ,weak) UITableView *peripheralList;

@property (nonatomic ,weak) UIButton *saveButton;

@property (nonatomic ,strong) UIImageView *lockImageView;

@property (nonatomic ,strong) UIImageView *connectImageView;

@property (nonatomic ,strong) UIImageView *refreshImageView;

@property (nonatomic ,strong) UILabel *perNameLabel;

@end

@implementation BindPeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *arr = @[@"1",@"2",@"3",@"4",@"5"];
    
    _dataArr = [NSMutableArray arrayWithArray:arr];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchPeripheral)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.title = @"设备绑定";
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    [self creatUpView];
}

- (void)creatUpView
{
    UIImageView *bluetoothImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 80, self.view.frame.size.width * 120 / 320, 30, 46)];
    [self.view addSubview:bluetoothImageView];
    [bluetoothImageView setImage:[UIImage imageNamed:@"ble_icon"]];
    
    self.lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x + 50, self.view.frame.size.width * 120 / 320, 30, 46)];
    [self.view addSubview:self.lockImageView];
    [self.lockImageView setImage:[UIImage imageNamed:@"ble_lock_oper"]];
    
    self.connectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 25, self.view.frame.size.width * 136.5 / 320, 50, 13)];
    [self.view addSubview:self.connectImageView];
    [self.connectImageView setImage: [UIImage imageNamed:@"ble_break_icon"]];
    
    self.refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.downView.center.x - 44, 100, 88, 78.5)];
    [self.downView addSubview:self.refreshImageView];
    [self.refreshImageView setImage:[UIImage imageNamed:@"ble_refresh"]];
    
    self.perNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, self.view.frame.size.width * 190 / 320, 200, 19)];
    [self.view addSubview:self.perNameLabel];
    [self.perNameLabel setText:@"未绑定设备"];
    [self.perNameLabel setTextColor:[UIColor whiteColor]];
    self.perNameLabel.textAlignment = NSTextAlignmentCenter;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 261 / 320, self.view.frame.size.width, 13)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
}

- (void)searchPeripheral
{
    NSLog(@"search peripheral.");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bindcell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bindcell"];
    }
    
    cell.textLabel.text = _dataArr[indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (UIView *)downView
{
    if (!_downView) {
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 274 / 320, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * 274 / 320))];
        downView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:downView];
        _downView = downView;
    }
    
    return _downView;
}

- (UITableView *)peripheralList
{
    if (!_peripheralList) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.downView.frame.size.height - 21 - 50) style:UITableViewStylePlain];
        view.backgroundColor = [UIColor redColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.downView addSubview:view];
        _peripheralList = view;
    }
    
    return _peripheralList;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.downView.center.x - 90, self.downView.frame.size.height - 21 - 47, 180, 47)];
        [button setTitle:@"绑定设备" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self.downView addSubview:button];
        _saveButton = button;
    }
    
    return _saveButton;
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
