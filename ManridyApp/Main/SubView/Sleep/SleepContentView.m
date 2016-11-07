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
    NSMutableArray *_textArr;
}
@property (nonatomic ,weak) PNBarChart *deepSleepChart;
@property (nonatomic ,weak) PNBarChart *sumSleepChart;
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
    [self.sleepCircleChart updateChartByCurrent:@(progress * 100)];
    [self.sleepCircleChart strokeChart];
}

- (void)showChartViewWithData:(BOOL)haveData
{
    if (haveData) {
        [_textArr removeAllObjects];
        for (NSInteger i = 0; i < self.sumDataArr.count; i ++) {
            [_textArr addObject:@(i + 1)];
            NSNumber *hightest = (NSNumber *)self.sumDataArr[i];
            NSLog(@"%@",hightest);
            NSInteger hight = hightest.integerValue;
            if (hight > self.sumSleepChart.yMaxValue) {
                self.sumSleepChart.yMaxValue = hight + 10;
                self.deepSleepChart.yMaxValue = hight + 10;
            }
        }
        NSLog(@"hightest == %f",self.sumSleepChart.yMaxValue);
        
        [self.deepSleepChart setXLabels:_textArr];
        [self.deepSleepChart setYValues:self.deepDataArr];
        [self.deepSleepChart strokeChart];
        
        [self.sumSleepChart setXLabels:_textArr];
        [self.sumSleepChart setYValues:self.sumDataArr];
        [self.sumSleepChart strokeChart];
        
        [self.sumDataArr removeObjectAtIndex:self.sumDataArr.count - 1];
        [self.deepDataArr removeObjectAtIndex:self.deepDataArr.count - 1];
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
#pragma mark - 懒加载
- (PNBarChart *)deepSleepChart
{
    if (!_deepSleepChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:self.downView.bounds];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor blackColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 15;
        view.showLabel = YES;
//        view.showYLabel = YES;
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
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:43.0 / 255.0 green:147.0 / 255.0 blue:190.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1]];
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
