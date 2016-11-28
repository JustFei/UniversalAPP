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
@property (nonatomic ,weak) PNCircleChart *heartCircleChart;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;


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

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.heartCircleChart strokeChart];
    });
    [self.heartCircleChart updateChartByCurrent:@(progress)];
}

- (void)showChartViewWithData:(BOOL)haveData
{
    if (haveData) {
        [self.heartChart setXLabels:self.dateArr];
        
        PNLineChartData *data02 = [PNLineChartData new];
        data02.color = PNTwitterColor;
        data02.itemCount = self.heartChart.xLabels.count;
        data02.inflexionPointColor = PNLightBlue;
        data02.inflexionPointStyle = PNLineChartPointStyleCircle;
//        data02.showPointLabel = YES;
//        data02.pointLabelColor = [UIColor redColor];
//        data02.pointLabelFont = [UIFont systemFontOfSize:15];
        data02.getData = ^(NSUInteger index) {
            CGFloat yValue = [self.dataArr[index] floatValue];
            NSLog(@"%f",yValue);
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        self.heartChart.chartData = @[data02];
        
        [self.heartChart strokeChart];
    }else {
        //仅仅展示个坐标系
        [self.heartChart strokeChart];
    }
    
    
}

#pragma mark - 懒加载
- (PNLineChart *)heartChart
{
    if (!_heartChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        view.showCoordinateAxis = YES;
        view.yValueMin = 0;
        view.yValueMax = 200;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        
        [self.downView addSubview:view];
        _heartChart = view;
    }
    
    return _heartChart;
}

- (PNCircleChart *)heartCircleChart
{
    if (!_heartCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@200 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:43.0 / 255.0 green:147.0 / 255.0 blue:190.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor colorWithRed:127.0 / 255.0 green:71.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
        [view setStrokeColorGradientStart:[UIColor colorWithRed:127.0 / 255.0 green:71.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
        
        [self addSubview:view];
        _heartCircleChart = view;
    }
    
    return _heartCircleChart;
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
