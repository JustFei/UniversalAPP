//
//  BloodO2ContentView.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/19.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BloodO2ContentView.h"
#import "BloodO2Model.h"

@interface BloodO2ContentView ()
{
    NSMutableArray *_textArr;
}
//@property (nonatomic ,weak) PNBarChart *BOChart;

@property (nonatomic ,weak) PNCircleChart *BOCircleChart;
@property (nonatomic ,strong) NSMutableArray *boArr;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation BloodO2ContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"BloodO2ContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        _textArr = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.BOCircleChart.backgroundColor = [UIColor clearColor];
}

- (void)drawProgress:(CGFloat )progress
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.BOCircleChart strokeChart];
    });
    [self.BOCircleChart updateChartByCurrent:@(progress * 100)];
}

- (void)showChartViewWithData:(BOOL)haveData
{
    if (haveData) {
        [_textArr removeAllObjects];

        [self.BOChart setXLabels:self.dateArr];
        PNLineChartData *data02 = [PNLineChartData new];
        data02.color = PNTwitterColor;
        data02.itemCount = self.BOChart.xLabels.count;
        data02.inflexionPointColor = PNLightBlue;
        data02.inflexionPointStyle = PNLineChartPointStyleCircle;
//        data02.showPointLabel = YES;
//        data02.pointLabelColor = [UIColor redColor];
//        data02.pointLabelFont = [UIFont systemFontOfSize:15];
        data02.getData = ^(NSUInteger index) {
            //TODO:数组越界出现在这里
            CGFloat yValue;
            if (index < self.boArr.count) {
                yValue = [self.boArr[index] floatValue];
                DLog(@"%f",yValue);
            }
            
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        self.BOChart.chartData = @[data02];
        [self.BOChart strokeChart];
    }else {
        [self.BOChart strokeChart];
    }
}

- (void)queryBOWithBloodArr:(NSArray *)BODataArr
{
    @autoreleasepool {
        //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
        [self.boArr removeAllObjects];
        [self.dateArr removeAllObjects];
        [self.timeArr removeAllObjects];
        
        if (BODataArr.count == 0) {
            [self showChartViewWithData:NO];
        }else {
            
            if (BODataArr.count >= 7) {
                
                for (NSInteger index = BODataArr.count - 7; index < BODataArr.count; index ++) {
                    BloodO2Model *model = BODataArr[index];
                    float bo = [model.integerString stringByAppendingString:[NSString stringWithFormat:@".%@",model.floatString]].floatValue;
                    [self.boArr addObject:@(bo)];
                    NSString *day = [model.dayString substringFromIndex:5];
                    NSString *time = [model.timeString substringToIndex:5];
                    [self.dateArr addObject:[NSString stringWithFormat:@"%@\n%@",day , time]];
                    [self.timeArr addObject:model.timeString];
                }
            }else {
                for (BloodO2Model *model in BODataArr) {
                    float bo = [model.integerString stringByAppendingString:[NSString stringWithFormat:@".%@",model.floatString]].floatValue;
                    [self.boArr addObject:@(bo)];
                    NSString *day = [model.dayString substringFromIndex:5];
                    NSString *time = [model.timeString substringToIndex:5];
                    [self.dateArr addObject:[NSString stringWithFormat:@"%@\n%@",day , time]];
                    [self.timeArr addObject:model.timeString];
                }
            }
            
            BloodO2Model *model = BODataArr.lastObject;
            //这里暂时只显示整数部分
            float bo = [model.integerString stringByAppendingString:[NSString stringWithFormat:@".%@",model.floatString]].floatValue;
//            [self.BOLabel setText:[NSString stringWithFormat:@"%.2f",bo]];
            [self.BOLabel setText:model.integerString];
            [self.dateLabel setText:[NSString stringWithFormat:@"%@\n%@",model.dayString ,model.timeString]];
            self.dateLabel.hidden = NO;
            
            float highProgress = bo / 100;
            
            if (highProgress <= 1) {
                [self drawProgress:highProgress];
            }else if (highProgress >= 1) {
                [self drawProgress:1];
            }
            [self showChartViewWithData:YES];
        }
    }
}

- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex
{
    if (pointIndex < self.timeArr.count) {
        NSString *time = [self.timeArr[pointIndex] substringToIndex:5];
        NSString *bo = self.boArr[pointIndex];
        
        [self.currentBOLabel setText:[NSString stringWithFormat:@"%@：%ld%%",time ,(long)bo.integerValue]];
    }
}

#pragma mark - 懒加载
- (PNLineChart *)BOChart
{
    if (!_BOChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.delegate = self;
        view.backgroundColor = [UIColor clearColor];
        view.showCoordinateAxis = YES;
        view.yFixedValueMin = 70;
        view.yFixedValueMax = 100;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        [self.downView addSubview:view];
        _BOChart = view;
    }
    
    return _BOChart;
}

- (PNCircleChart *)BOCircleChart
{
    if (!_BOCircleChart) {
        [self layoutIfNeeded];
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:43.0 / 255.0 green:147.0 / 255.0 blue:190.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor colorWithRed:191.0 / 255.0 green:41.0 / 255.0 blue:50.0 / 255.0 alpha:1]];
//        [view setStrokeColorGradientStart:[UIColor blackColor]];
        
        [self addSubview:view];
        _BOCircleChart = view;
    }
    
    return _BOCircleChart;
}

- (NSMutableArray *)boArr
{
    if (!_boArr) {
        _boArr = [NSMutableArray array];
    }
    
    return _boArr;
}

- (NSMutableArray *)dateArr
{
    if (!_dateArr) {
        _dateArr = [NSMutableArray array];
    }
    
    return _dateArr;
}

- (NSMutableArray *)timeArr
{
    if (!_timeArr) {
        _timeArr = [NSMutableArray array];
    }
    
    return _timeArr;
}

@end
