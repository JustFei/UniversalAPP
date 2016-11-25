//
//  BloodPressureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodPressureContentView.h"
#import "PNChart.h"
#import "BloodModel.h"

@interface BloodPressureContentView ()
{
    NSMutableArray *_textArr;
}
@property (nonatomic ,weak) PNBarChart *lowBloodChart;
@property (nonatomic ,weak) PNBarChart *highBloodChart;
@property (nonatomic ,weak) PNCircleChart *hBloodCircleChart;

@end

@implementation BloodPressureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"BloodPressureContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        _textArr = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.hBloodCircleChart.backgroundColor = [UIColor clearColor];
}

- (void)drawProgress:(CGFloat )progress
{
    [self.hBloodCircleChart updateChartByCurrent:@(progress * 100)];
    [self.hBloodCircleChart strokeChart];
}

- (void)showChartViewWithData:(BOOL)haveData
{
    if (haveData) {
        [_textArr removeAllObjects];
        for (NSInteger i = 0; i < self.hbArr.count; i ++) {
            [_textArr addObject:@(i + 1)];
//            NSNumber *hightest = (NSNumber *)self.hbArr[i];
//            NSLog(@"%@",hightest);
//            NSInteger hight = hightest.integerValue;
//            if (hight > self.highBloodChart.yValueMax) {
//                self.highBloodChart.yValueMax = hight + 10;
//                self.lowBloodChart.yValueMax = hight + 10;
//            }
        }
        
        [self.lowBloodChart setXLabels:_textArr];
        [self.lowBloodChart setYValues:self.lbArr];
        [self.lowBloodChart strokeChart];
        
        [self.highBloodChart setXLabels:_textArr];
        [self.highBloodChart setYValues:self.hbArr];
        [self.highBloodChart strokeChart];
        
        [self.hbArr removeObjectAtIndex:self.hbArr.count - 1];
        [self.lbArr removeObjectAtIndex:self.lbArr.count - 1];
    }else {
        //仅仅展示个坐标系
        [self.highBloodChart setYLabels:@[@1,@2,@3,@4,@5,@6,@7,@8]];
        [self.highBloodChart showLabel];
        [self.highBloodChart strokeChart];
    }
    
}

- (void)queryBloodWithBloodArr:(NSArray *)bloodDataArr
{
    @autoreleasepool {
        //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
        
        
        if (bloodDataArr.count == 0) {
            [self showChartViewWithData:NO];
        }else {
            
            if (bloodDataArr.count > 5) {
                
                for (NSInteger index = bloodDataArr.count - 5; index < bloodDataArr.count; index ++) {
                    BloodModel *model = bloodDataArr[index];
                    [self.hbArr addObject:@(model.highBloodString.integerValue)];
                    [self.lbArr addObject:@(model.lowBloodString.integerValue)];
                }
            }else {
                for (BloodModel *model in bloodDataArr) {
                    [self.hbArr addObject:@(model.highBloodString.integerValue)];
                    [self.lbArr addObject:@(model.lowBloodString.integerValue)];
                }
            }
            
            BloodModel *model = bloodDataArr.lastObject;
            [self.bloodPressureLabel setText:[NSString stringWithFormat:@"%@/%@",model.highBloodString ,model.lowBloodString]];
            [self.heartRateLabel setText:[NSString stringWithFormat:@"心率:%@",model.bpmString]];
            
            float highProgress = model.highBloodString.floatValue / 200;
            
            if (highProgress <= 1) {
                [self drawProgress:highProgress];
            }else if (highProgress >= 1) {
                [self drawProgress:1];
            }
            [self showChartViewWithData:YES];
        }
        [self.hbArr removeAllObjects];
        [self.lbArr removeAllObjects];
    }
}

#pragma mark - 懒加载
- (PNBarChart *)lowBloodChart
{
    if (!_lowBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(self.downView.bounds.origin.x - 19, self.downView.bounds.origin.y, self.downView.bounds.size.width, self.downView.bounds.size.height)];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor blackColor]];
        view.barBackgroundColor = [UIColor clearColor];
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.yMinValue = 0;
        view.yMaxValue = 200;
        view.showLabel = NO;
        view.barWidth = 20;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;

        [self.downView addSubview:view];
        _lowBloodChart = view;
    }
    
    return _lowBloodChart;
}

- (PNBarChart *)highBloodChart
{
    if (!_highBloodChart) {
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
        view.yMaxValue = 200;
        view.barWidth = 20;
        view.showLabel = YES;
        view.showChartBorder = YES;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        
        [self.downView addSubview:view];
        _highBloodChart = view;
    }
    
    return _highBloodChart;
}

- (PNCircleChart *)hBloodCircleChart
{
    if (!_hBloodCircleChart) {
        [self layoutIfNeeded];
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:43.0 / 255.0 green:147.0 / 255.0 blue:190.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor blackColor]];
        [view setStrokeColorGradientStart:[UIColor blackColor]];
        
        [self addSubview:view];
        _hBloodCircleChart = view;
    }
    
    return _hBloodCircleChart;
}

- (NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}

- (NSMutableArray *)hbArr
{
    if (!_hbArr) {
        _hbArr = [NSMutableArray array];
    }
    
    return _hbArr;
}

- (NSMutableArray *)lbArr
{
    if (!_lbArr) {
        _lbArr = [NSMutableArray array];
    }
    
    return _lbArr;
}

@end
