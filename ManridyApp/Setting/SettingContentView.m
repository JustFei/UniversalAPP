//
//  SettingContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SettingContentView.h"
#import "UserInfoViewController.h"
#import "BindPeripheralViewController.h"
#import "PhoneRemindViewController.h"
#import "AboutViewController.h"

#define WIDTH self.frame.size.width

@interface SettingContentView () <UITableViewDelegate ,UITableViewDataSource >
{
    NSArray *_dataArr;
    NSArray *_imageNameArr;
}

@property (nonatomic ,weak) UIImageView *headView;

@property (nonatomic ,weak) UILabel *userNameLabel;

@property (nonatomic ,weak) UILabel *batteryLabel;

@property (nonatomic ,weak) UITableView *functionTableView;

@end

@implementation SettingContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _dataArr = @[@"用户信息",@"信息提醒",@"防丢设置",@"查看电量",@"设备锁定",@"关于"];
        _dataArr = @[@"用户信息",@"信息提醒",@"设备绑定",@"关于"];
        _imageNameArr = @[@"set_user_icon",@"set_alart_icon",@"set_ble_icon",@"set_about_icon"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat headWidth = 125 * WIDTH / 320;
    self.headView.frame = CGRectMake(self.center.x - headWidth / 2, 80, headWidth, headWidth);
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.cornerRadius = headWidth / 2;
    self.headView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headView.layer.borderWidth = 1;
    
    self.batteryLabel.frame = CGRectMake(WIDTH - 70 * WIDTH / 320, 74, 50 * WIDTH / 320, 30 * WIDTH / 320);
    [self.batteryLabel setText:@"80%"];
    
    self.userNameLabel.frame = CGRectMake(self.center.x - 100 * WIDTH / 320, 215 * WIDTH / 320, 200 * WIDTH / 320, 34 * WIDTH / 320);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, WIDTH * 261 / 320, WIDTH, 13 * WIDTH / 320)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self addSubview:view];
    
    self.functionTableView.frame = CGRectMake(0, WIDTH * 274 / 320, WIDTH, self.frame.size.height - WIDTH * 274 / 320);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]) {
        [self.userNameLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"]) {
//        [self.headView setImage:[[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"]];
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"];
        [self.headView setImage:[UIImage imageWithData:imageData]];
    }
}

#pragma mark - UITabelViewDelegate && UITableViewDataSource
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setcell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setcell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.imageView.image = [UIImage imageNamed:_imageNameArr[indexPath.row]];
    cell.textLabel.text = _dataArr[indexPath.row];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
//    cell.contentView.backgroundColor = [UIColor colorWithRed:48.0 / 255.0 green:110.0 / 255.0 blue:187.0 / 255.0 alpha:0.7];
    UIView *view = [[UIView alloc] initWithFrame:cell.contentView.frame];
    
    view.backgroundColor = [UIColor colorWithRed:48.0 / 255.0 green:110.0 / 255.0 blue:187.0 / 255.0 alpha:0.7];//设置选中后cell的背景颜色
    
    cell.selectedBackgroundView = view;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    switch (indexPath.row) {
        case 0:
        {
            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
            [[self findViewController:self].navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            PhoneRemindViewController *vc = [[PhoneRemindViewController alloc] init];
            [[self findViewController:self].navigationController pushViewController:vc animated:YES];
        }
            break;
         
        case 2:
        {
            BindPeripheralViewController *vc = [[BindPeripheralViewController alloc] init];
            [[self findViewController:self].navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            AboutViewController *vc = [[AboutViewController alloc] init];
            [[self findViewController:self].navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 懒加载
- (UIImageView *)headView
{
    if (!_headView) {
        UIImageView *view = [[UIImageView alloc] init];
        view.image = [UIImage imageNamed:@""];
        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
        _headView = view;
    }
    
    return _headView;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"用户名";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:label];
        _userNameLabel = label;
    }
    
    return _userNameLabel;
}

- (UILabel *)batteryLabel
{
    //还没有获取到电量，先不显示吧
    if (_batteryLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:label];
        _batteryLabel = label;
    }
    
    return _batteryLabel;
}

- (UITableView *)functionTableView
{
    if (!_functionTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        view.tableFooterView = [[UIView alloc] init];
        
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = [UIColor clearColor];
        
        [self addSubview:view];
        _functionTableView = view;
    }
    
    return _functionTableView;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
