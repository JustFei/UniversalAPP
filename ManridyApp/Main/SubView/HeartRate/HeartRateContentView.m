//
//  HeartRateContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateContentView.h"


@interface HeartRateContentView ()


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
        
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = PNTwitterColor;
        data01.itemCount = self.dataArr.count;
        data01.inflexionPointColor = PNLightBlue;
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [self.dataArr[index] floatValue];
            DLog(@"1=======%f",yValue);
            
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        self.heartChart.chartData = @[data01];
        [self.heartChart strokeChart];
        
    }else {
        //仅仅展示个坐标系
        [self.heartChart strokeChart];
    }
}

#pragma mark - PNChartDelegate
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex
{
    NSString *date = self.dateArr[pointIndex];
    NSString *hr = self.dataArr[pointIndex];
    [self.currentHRStateLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentHRData", nil),[date substringFromIndex:6] ,hr]];
}

- (void)showHRStateLabel
{
    self.currentHRStateLabel.text = NSLocalizedString(@"lastTimesHRData", nil);
}

#pragma mark - 懒加载
- (PNLineChart *)heartChart
{
    if (!_heartChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
        view.showCoordinateAxis = YES;
//        view.yValueMin = 0;
//        view.yValueMax = 220;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        view.yGridLinesColor = [UIColor grayColor];
        
        
        [self.downView addSubview:view];
        _heartChart = view;
    }
    
    return _heartChart;
}

- (PNCircleChart *)heartCircleChart
{
    if (!_heartCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@220 current:@0 clockwise:YES shadow:YES shadowColor:COLOR_WITH_HEX(0xd32f2f, 0.15) displayCountingLabel:NO overrideLineWidth:@8];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:COLOR_WITH_HEX(0xd32f2f, 0.87)];
//        [view setStrokeColorGradientStart:[UIColor colorWithRed:127.0 / 255.0 green:71.0 / 255.0 blue:221.0 / 255.0 alpha:1]];
        
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
