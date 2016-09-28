//
//  SettingContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SettingContentView.h"
#import "UserInfoViewController.h"

@interface SettingContentView () <UITableViewDelegate ,UITableViewDataSource >
{
    NSArray *_dataArr;
    NSArray *_imageNameArr;
}

@property (nonatomic ,weak) UIImageView *headView;

@property (nonatomic ,weak) UILabel *userNameLabel;

@property (nonatomic ,weak) UITableView *functionTableView;

@end

@implementation SettingContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataArr = @[@"用户信息",@"信息提醒",@"防丢设置",@"查看电量",@"设备锁定",@"关于"];
        _imageNameArr = @[@"set_user_icon",@"set_alart_icon",@"set_lost_icon",@"set_bty_icon",@"set_ble_icon",@"set_about_icon"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.headView.frame = CGRectMake(self.center.x - 62.5, 80, 125, 125);
    self.userNameLabel.frame = CGRectMake(self.center.x - 100, 215, 200, 34);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 261, self.frame.size.width, 13)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self addSubview:view];
    
    self.functionTableView.frame = CGRectMake(0, 274, self.frame.size.width, self.frame.size.height - 274);
    
    self.headView.layer.cornerRadius = self.headView.frame.size.width / 2;
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
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
        view.backgroundColor = [UIColor redColor];
        
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
        label.tintColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:label];
        _userNameLabel = label;
    }
    
    return _userNameLabel;
}

- (UITableView *)functionTableView
{
    if (!_functionTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
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
