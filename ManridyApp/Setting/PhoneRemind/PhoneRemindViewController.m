//
//  PhoneRemindViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/17.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhoneRemindViewController.h"
#import "PhoneRemindTableViewCell.h"
#import "SectionModel.h"
#import "PhoneRemindView.h"


@interface PhoneRemindViewController () <UITableViewDelegate ,UITableViewDataSource >
{
    NSArray *_funcArr;
    NSArray *_clockArr;
    NSArray *_imageArr;
}
@property (nonatomic ,weak) UITableView *remindTableView;

@end

@implementation PhoneRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _funcArr = @[@"来电提醒",@"短信提醒",@"防丢提醒",@"闹钟设置"];
    _imageArr = @[@"alert_call",@"alert_sms",@"alert_lose",@"alert_clock"];
    _clockArr = @[@"闹钟1",@"闹钟2",@"闹钟3"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:@"提醒设置"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 16)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
    
    self.remindTableView.backgroundColor = [UIColor clearColor];
    self.remindTableView.tableHeaderView = nil;
    self.remindTableView.tableFooterView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0) {
        return 3;
    }else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneRemindCell"];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.iconImageView.image = [UIImage imageNamed:_imageArr[indexPath.row]];
            cell.functionName.text = _funcArr[indexPath.row];
            [cell.timeSwitch setOn:NO];
            cell.timeLabel.hidden = YES;
        }
            break;
        case 1:
        {
            cell.functionName.text = _clockArr[indexPath.row];
            cell.timeLabel.text = @"08:00";
            [cell.timeSwitch setOn:NO];
        }
            break;
            
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.timeSwitch.transform = CGAffineTransformMakeScale(0.85, 0.75);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }else {
        PhoneRemindView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"phoneHead"];
        view.backgroundColor = [UIColor clearColor];
        
        SectionModel *sectionModel = [[SectionModel alloc] init];
        sectionModel.functionName = _funcArr[3];
        sectionModel.imageName = _imageArr[3];
        sectionModel.arrowImageName = @"all_next_icon";
        view.model = sectionModel;
        view.expandCallback = ^(BOOL isExpanded) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                     withRowAnimation:UITableViewRowAnimationFade];
        };
        
        return view;
    }
}

#pragma mark - 懒加载
- (UITableView *)remindTableView
{
    if (!_remindTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 16)];
        
        view.backgroundColor = [UIColor clearColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _remindTableView = view;
        [_remindTableView registerNib:[UINib nibWithNibName:@"PhoneRemindTableViewCell" bundle:nil] forCellReuseIdentifier:@"phoneRemindCell"];
        [_remindTableView registerClass:[PhoneRemindView class] forHeaderFooterViewReuseIdentifier:@"phoneHead"];
    }
    
    return _remindTableView;
}

@end
