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
{
    NSArray *_textArr;
}
@property (nonatomic ,weak) PNBarChart *deepSleepChart;
@property (nonatomic ,weak) PNBarChart *sumSleepChart;

@end

@implementation SleepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"SleepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        _textArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)showChartView
{
    [self.sumSleepChart setXLabels:_textArr];
    [self.sumSleepChart setYValues:@[@6,@7,@8,@9,@10,@11,@12]];
    [self.sumSleepChart strokeChart];
    
    [self.deepSleepChart setXLabels:_textArr];
    [self.deepSleepChart setYValues:@[@5,@6,@7,@8,@9,@10,@11]];
    [self.deepSleepChart strokeChart];
    
}

- (IBAction)sleepTargetAction:(UIButton *)sender {
    SleepSettingViewController *vc = [[SleepSettingViewController alloc] initWithNibName:@"SleepSettingViewController" bundle:nil];
    
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}
#pragma mark - 懒加载
- (PNBarChart *)deepSleepChart
{
    if (!_deepSleepChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor yellowColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 15;
        view.showXLabel = YES;
        view.showYLabel = YES;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self.downView addSubview:view];
        _deepSleepChart = view;
    }
    
    return _deepSleepChart;
}

- (PNBarChart *)sumSleepChart
{
    if (!_sumSleepChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor redColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 15;
        view.showXLabel = YES;
        view.showYLabel = YES;
        view.showChartBorder = YES;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self.downView addSubview:view];
        _sumSleepChart = view;
    }
    
    return _sumSleepChart;
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
