//
//  SleepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepContentView.h"
#import "SleepSettingViewController.h"
#import "PNChart.h"

@interface SleepContentView ()

@property (nonatomic ,strong) PNBarChart *sleepChart;

@end

@implementation SleepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"SleepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.sleepChart.backgroundColor = [UIColor redColor];
}

- (void)showChartView
{
    [self.sleepChart setXLabels:self.dateArr];
    [self.sleepChart setYLabels:@[@7,@6,@5.5,@8,@7.5,@9.5,@10]];
    [self.sleepChart strokeChart];
}

- (IBAction)sleepTargetAction:(UIButton *)sender {
    SleepSettingViewController *vc = [[SleepSettingViewController alloc] initWithNibName:@"SleepSettingViewController" bundle:nil];
    
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}
#pragma mark - 懒加载
- (PNBarChart *)sleepChart
{
    if (!_sleepChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(5, 5, self.downView.frame.size.width - 10, self.downView.frame.size.width - 10)];
        view.backgroundColor = [UIColor clearColor];
        
        [self.downView addSubview:view];
        _sleepChart = view;
    }
    
    return _sleepChart;
}

- (NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
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
