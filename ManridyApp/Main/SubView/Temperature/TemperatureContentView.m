//
//  TemperatureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "TemperatureContentView.h"
#import "TemperatureWarningViewController.h"
#import "PNChart.h"

@interface TemperatureContentView ()

@property (nonatomic ,weak) PNLineChart *tempChart;

@end

@implementation TemperatureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"TemperatureContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)showChartView
{
    [self.tempChart setXLabels:self.dateArr];
    
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = self.tempChart.xLabels.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [self.dataArr[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.tempChart.chartData = @[data02];
    [self.tempChart strokeChart];
    
    self.tempChart.showSmoothLines = YES;
}

- (IBAction)temperatureWarningAction:(UIButton *)sender
{
    TemperatureWarningViewController *vc = [[TemperatureWarningViewController alloc] initWithNibName:@"TemperatureWarningViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}


#pragma mark - 懒加载
- (PNLineChart *)tempChart
{
    if (!_tempChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:CGRectMake(5, 5, self.downView.frame.size.width - 10, self.downView.frame.size.width - 10)];
        view.backgroundColor = [UIColor clearColor];
        
        [self.downView addSubview:view];
        _tempChart = view;
    }
    
    return _tempChart;
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
