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
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [self.dataArr[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.heartChart.chartData = @[data02];
    [self.heartChart strokeChart];
    
    self.heartChart.showSmoothLines = YES;
}

#pragma mark - 懒加载
- (PNLineChart *)heartChart
{
    if (!_heartChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:CGRectMake(5, 5, self.downView.frame.size.width - 10, self.downView.frame.size.width - 10)];
        view.backgroundColor = [UIColor clearColor];
        
        [self.downView addSubview:view];
        _heartChart = view;
    }
    
    return _heartChart;
}

@end
