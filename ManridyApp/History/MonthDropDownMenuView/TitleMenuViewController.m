//
//  TitleMenuViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/20.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "TitleMenuViewController.h"
#import "DropdownMenuView.h"

@interface TitleMenuViewController ()

@property (nonatomic, strong) NSMutableArray * data;

@end

@implementation TitleMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *mouthArr = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
    
    _data = [NSMutableArray arrayWithArray:mouthArr];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"statusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    NSString * name = _data[indexPath.row];
    cell.textLabel.text = name;
    [cell.textLabel setFont:[UIFont systemFontOfSize:11]];
    
    return cell;
}

#pragma mark Cell点击事件处理器
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dropdownMenuView) {
        [_dropdownMenuView dismiss];
    }
    
    if (_delegate) {
        [_delegate selectAtIndexPath:indexPath title:_data[indexPath.row]];
    }
    
}

@end
