//
//  SleepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepContentView.h"
#import "SleepSettingViewController.h"


@interface SleepContentView ()
{
    NSMutableArray *_textArr;
}

@property (nonatomic ,weak) PNCircleChart *sleepCircleChart;

@end

@implementation SleepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"SleepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        _textArr = [NSMutableArray array];
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
        [self.sleepCircleChart strokeChart];
    });
    [self.sleepCircleChart updateChartByCurrent:@(progress * 100)];
}

- (void)showChartViewWithData:(BOOL)haveData
{
    if (haveData) {
        [_textArr removeAllObjects];
        for (NSInteger i = 0; i < self.sumDataArr.count; i ++) {
            [_textArr addObject:@(i + 1)];
            NSNumber *hightest = (NSNumber *)self.sumDataArr[i];
            DLog(@"%@",hightest);
            NSInteger hight = hightest.integerValue;
            if (hight > self.sumSleepChart.yMaxValue) {
                self.sumSleepChart.yMaxValue = hight + 10;
                self.deepSleepChart.yMaxValue = hight + 10;
            }
        }
        DLog(@"hightest == %f",self.sumSleepChart.yMaxValue);
        
        [self.deepSleepChart setXLabels:_textArr];
        [self.deepSleepChart setYValues:self.deepDataArr];
        [self.deepSleepChart strokeChart];
        
        [self.sumSleepChart setXLabels:_textArr];
        [self.sumSleepChart setYValues:self.sumDataArr];
        [self.sumSleepChart strokeChart];
        
    }else {
        //仅仅展示个坐标系
        [self.sumSleepChart setYLabels:@[@1,@2,@3,@4,@5,@6,@7,@8]];
        [self.sumSleepChart showLabel];
        [self.sumSleepChart strokeChart];
    }
}

- (IBAction)sleepTargetAction:(UIButton *)sender {
    SleepSettingViewController *vc = [[SleepSettingViewController alloc] initWithNibName:@"SleepSettingViewController" bundle:nil];
    
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSNumber *sumNum = self.sumDataArr[barIndex];
    NSNumber *deepNum = self.deepDataArr[barIndex];
    NSInteger low = sumNum.integerValue - deepNum.integerValue;
    NSString *start = [self.startDataArr[barIndex] substringFromIndex:11];
    NSString *end = [self.endDataArr[barIndex] substringFromIndex:11];
    self.currentSleepStateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"currentSleepData", nil),start ,end ,low / 60.f ,deepNum.integerValue / 60.f];
}

#pragma mark - 懒加载
- (PNBarChart *)deepSleepChart
{
    if (!_deepSleepChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
        [view setStrokeColor:[UIColor blackColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.barWidth = 20;
        view.yMinValue = 0;
        view.yMaxValue = 15;
        view.showLabel = YES;
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
        [view setStrokeColor:[UIColor grayColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.barWidth = 20;
        view.yMinValue = 0;
        view.yMaxValue = 15;
        view.showLabel = YES;
        view.showChartBorder = YES;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self.downView addSubview:view];
        _sumSleepChart = view;
    }
    
    return _sumSleepChart;
}

- (PNCircleChart *)sleepCircleChart
{
    if (!_sleepCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:COLOR_WITH_HEX(0x7b1fa2, 0.15) displayCountingLabel:NO overrideLineWidth:@8];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:COLOR_WITH_HEX(0x7b1fa2, 0.87)];
        [view setStrokeColorGradientStart:[UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1]];
        
        [self addSubview:view];
        _sleepCircleChart = view;
    }
    
    return _sleepCircleChart;
}

- (NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}

- (NSMutableArray *)sumDataArr
{
    if (!_sumDataArr) {
        _sumDataArr = [NSMutableArray array];
    }
    
    return _sumDataArr;
}

- (NSMutableArray *)deepDataArr
{
    if (!_deepDataArr) {
        _deepDataArr = [NSMutableArray array];
    }
    
    return _deepDataArr;
}

- (NSMutableArray *)startDataArr
{
    if (!_startDataArr) {
        _startDataArr = [NSMutableArray array];
    }
    
    return _startDataArr;
}

- (NSMutableArray *)endDataArr
{
    if (!_endDataArr) {
        _endDataArr = [NSMutableArray array];
    }
    
    return _endDataArr;
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
