
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "AppDelegate.h"
#import "StepHistoryViewController.h"


@interface StepContentView () 
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
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
    [self.stepCircleChart updateChartByCurrent:@(progress * 100)];
    [self.stepCircleChart strokeChart];
}

- (void)showChartView
{
    NSMutableArray *xLabelArr = [NSMutableArray array];
    
    for (__strong NSString *dateStr in self.dateArr) {
        dateStr = [dateStr substringFromIndex:5];
        NSLog(@"querystring == %@",dateStr);
        
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
    
    for (int i = 0; i < self.dataArr.count; i ++) {
        SportModel *model = self.dataArr[i];
        
        if (model.stepNumber != 0) {
            sumStep += model.stepNumber.integerValue;
            sumMileage += model.mileageNumber.integerValue;
            sumkCal += model.kCalNumber.integerValue;
        }
    }
    
    [self.weekStatisticsLabel setText:[NSString stringWithFormat:@"本周计步统计：%ld步（%ld公里/%ld千卡）",sumStep ,sumMileage ,sumkCal]];
    sumStep = sumMileage = sumkCal = 0;
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
        [delegate.mainVc.stepView.stepLabel setText:@"设备连接中。。。"];
        delegate.myBleTool.isReconnect = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [delegate.myBleTool stopScan];
            if (delegate.myBleTool.connectState == kBLEstateDisConnected) {
                [delegate.mainVc.stepView.stepLabel setText:@"未连接上设备，点击重试"];
            }
        });
    }
}

#pragma mark - 懒加载
- (PNLineChart *)stepChart
{
    if (!_stepChart) {
        [self.downView layoutIfNeeded];
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
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
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:35.0 / 255.0 green:146.0 / 255.0 blue:192.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor clearColor]];
        [view setStrokeColorGradientStart:[UIColor yellowColor]];
        
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
