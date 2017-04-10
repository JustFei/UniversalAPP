//
//  UnitsSettingViewController.m
//  ManridyApp
//
//  Created by Faith on 2017/3/29.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UnitsSettingViewController.h"
#import "UnitsSettingTableViewCell.h"
#import "BLETool.h"

@interface UnitsSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isMetric;

@end

@implementation UnitsSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:37.0 / 255.0 green:154.0 / 255.0 blue:219.0 / 255.0 alpha:1];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:@"单位"];
    [titleLabel setTextColor:[UIColor blackColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"unitsCell";
    UnitsSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (nil == cell) {
        cell = [[UnitsSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    self.isMetric = [self isMetricOrImperialSystem];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.unitsLabel.text = NSLocalizedString(@"Metric", nil);
            cell.selecetImageView.image = self.isMetric ? [UIImage imageNamed:@"unit_icon"] : nil;
            [cell.unitsLabel setTextColor:self.isMetric ? [UIColor colorWithRed:37.0 / 255.0 green:154.0 / 255.0 blue:219.0 / 255.0 alpha:1] : [UIColor blackColor]];
        }
            break;
        case 1:
        {
            cell.unitsLabel.text = NSLocalizedString(@"ImperialSystem", nil);
            cell.selecetImageView.image = self.isMetric ? nil : [UIImage imageNamed:@"unit_icon"];
            [cell.unitsLabel setTextColor:self.isMetric ? [UIColor blackColor] : [UIColor colorWithRed:37.0 / 255.0 green:154.0 / 255.0 blue:219.0 / 255.0 alpha:1]];
        }
        default:
            break;
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

//修改设置的公制英制属性
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([BLETool shareInstance].connectState == kBLEstateDidConnected) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isMetric"];
            [[BLETool shareInstance] writeUnitToPeripheral:NO];
        }else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isMetric"];
            [[BLETool shareInstance] writeUnitToPeripheral:YES];
        }
        [tableView reloadData];
    }
}

//判断是否是公制单位
- (BOOL)isMetricOrImperialSystem
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"]) {
        BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"];
        return isMetric;
    }else {
        return NO;
    }
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 102) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        [_tableView registerClass:[UnitsSettingTableViewCell class] forCellReuseIdentifier:@"unitsCell"];
        _tableView.rowHeight = 50;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:_tableView];
        
        [self.view addSubview:view];
    }
    
    return _tableView;
}

@end
