
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "AppDelegate.h"
#import "StepHistoryViewController.h"
#import "BindPeripheralViewController.h"
#import "UnitsTool.h"

@interface StepContentView () 
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    BOOL _isMetric;
}
@end

@implementation StepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"StepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        sumStep = 0;
        sumMileage = 0;
        sumkCal = 0;
        
        self.dateArr = [NSMutableArray array];
        self.dataArr = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reScanPeripheral)];
    self.stepLabel.userInteractionEnabled = YES;
    [self.stepLabel addGestureRecognizer:tap];
    
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.stepCircleChart strokeChart];
    });
    [self.stepCircleChart updateChartByCurrent:@(progress)];
}

- (void)showChartView
{
    NSMutableArray *xLabelArr = [NSMutableArray array];
    
    for (__strong NSString *dateStr in self.dateArr) {
        dateStr = [dateStr substringFromIndex:5];
        DLog(@"querystring == %@",dateStr);
        
        [xLabelArr addObject:dateStr];
    }
    
    [self.stepChart setXLabels:xLabelArr];
    
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = self.stepChart.xLabels.count;
    data02.inflexionPointColor = PNLightBlue;
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.getData = ^(NSUInteger index) {
        
        SportModel *model = self.dataArr[index];
        CGFloat yValue;
        if (model.stepNumber != 0) {
            yValue = model.stepNumber.integerValue;

        }else {
            yValue = 0;
        }
        
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.stepChart.chartData = @[data02];
    [self.stepChart strokeChart];
}

- (void)showStepStateLabel
{
    for (int i = 0; i < self.dataArr.count; i ++) {
        SportModel *model = self.dataArr[i];
        
        if (model.stepNumber != 0) {
            sumStep += model.stepNumber.integerValue;
            sumMileage += model.mileageNumber.integerValue;
            sumkCal += model.kCalNumber.integerValue;
        }
    }
    //    double mileage = sumMileage;
    _isMetric = [UnitsTool isMetricOrImperialSystem];
    //判断单位是英制还是公制
    //TODO: 这里翻译还要改一下
    [self.weekStatisticsLabel setText:[NSString stringWithFormat:_isMetric ?  NSLocalizedString(@"currentWeekStepData", nil) : NSLocalizedString(@"currentWeekStepDataImperial", nil),sumStep ,_isMetric ?  sumMileage / 1000.f : [UnitsTool kmAndMi:sumMileage / 1000.f withMode:ImperialToMetric] ,sumkCal]];
    sumStep = sumMileage = sumkCal = 0;
}

#pragma mark - PNChartDelegate
//- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
//{
//    DLog(@"点击了%ld根线",lineIndex);
//}


- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex
{
    SportModel *model = self.dataArr[pointIndex];
    NSString *date = self.dateArr[pointIndex];
    if (model.stepNumber) {
        [self.weekStatisticsLabel setText:[NSString stringWithFormat:NSLocalizedString(@"step", nil),date ,model.stepNumber]];
    }else {
        [self.weekStatisticsLabel setText:[NSString stringWithFormat:NSLocalizedString(@"step", nil),date ,@(0) ]];
    }
    
}


#pragma mark - Action
- (IBAction)setTargetAction:(UIButton *)sender
{
    StepTargetViewController *vc = [[StepTargetViewController alloc] initWithNibName:@"StepTargetViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
}

//重新扫描的点击动作
- (void)reScanPeripheral
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    BOOL isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    if (isBind) {
        [delegate.myBleTool scanDevice];
        [delegate.mainVc.stepView.stepLabel setText:NSLocalizedString(@"perConnecting", nil)];
        delegate.myBleTool.isReconnect = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [delegate.myBleTool stopScan];
            if (delegate.myBleTool.connectState == kBLEstateDisConnected) {
                [delegate.mainVc.stepView.stepLabel setText:NSLocalizedString(@"canNotConnectPer", nil)];
            }
        });
    }else {
        BindPeripheralViewController *vc = [[BindPeripheralViewController alloc] init];
        [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 懒加载
- (PNLineChart *)stepChart
{
    if (!_stepChart) {
        [self.downView layoutIfNeeded];
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.delegate = self;
        view.backgroundColor = [UIColor clearColor];
        view.showCoordinateAxis = YES;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        [self.downView addSubview:view];
        _stepChart = view;
    }
    
    return _stepChart;
}

- (PNCircleChart *)stepCircleChart
{
    if (!_stepCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@1 current:@0 clockwise:YES shadow:YES shadowColor:COLOR_WITH_HEX(0xf5a816, 0.15) displayCountingLabel:NO overrideLineWidth:@8];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:COLOR_WITH_HEX(0xf5a816, 0.87)];
        [view setStrokeColorGradientStart:[UIColor colorWithRed:1 green:1 blue:0 alpha:1]];
        
        [self addSubview:view];
        _stepCircleChart = view;
    }
    
    return _stepCircleChart;
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
