//
//  HeartRateContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateContentView.h"
#import "PNChart.h"

@interface HeartRateContentView ()

@property (nonatomic ,weak) PNLineChart *heartChart;
@property (weak, nonatomic) IBOutlet UIView *downView;

@end

@implementation HeartRateContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"HeartRateContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)showChartView
{
    [self.heartChart setXLabels:self.dateArr];
    
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = self.heartChart.xLabels.count;
    data02.inflexionPointColor = PNLightBlue;
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [self.dataArr[index] floatValue];
        NSLog(@"%f",yValue);
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.heartChart.chartData = @[data02];
    
    [self.heartChart strokeChart];
    
}

#pragma mark - 懒加载
- (PNLineChart *)heartChart
{
    if (!_heartChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        view.showCoordinateAxis = YES;
        view.yValueMin = 0;
        view.yValueMax = 10;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        
        [self.downView addSubview:view];
        _heartChart = view;
    }
    
    return _heartChart;
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

@end
