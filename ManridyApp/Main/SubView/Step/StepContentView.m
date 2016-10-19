//
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"


@interface StepContentView () 



@end

@implementation StepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"StepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色
    self.shapeLayer.lineWidth = 5.0f;
    self.shapeLayer.strokeColor = [UIColor yellowColor].CGColor;
    
    CGPoint center = CGPointMake(self.progressImageView.center.x, self.progressImageView.center.y + 6.5);
    CGFloat radius = self.progressImageView.frame.size.width / 2 - 20;
    CGFloat startA = (M_PI * (- 90) / 180.0);  //圆起点位置
    CGFloat endA = (M_PI * (270) / 180.0);  //圆终点位置
    //设置stroke起始点
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];//上面说明过了用来构建圆形
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = path.CGPath;
    
    //添加并显示
    [self.layer addSublayer:self.shapeLayer];

}

- (void)drawProgress:(CGFloat )progress
{
    self.shapeLayer.strokeEnd = progress;
}

- (void)showChartView
{
    [self.stepChart setXLabels:self.dateArr];
    
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = self.stepChart.xLabels.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [self.dataArr[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.stepChart.chartData = @[data02];
    [self.stepChart strokeChart];
    
    self.stepChart.showSmoothLines = YES;
}


#pragma mark - Action
- (IBAction)setTargetAction:(UIButton *)sender
{
    StepTargetViewController *vc = [[StepTargetViewController alloc] initWithNibName:@"StepTargetViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 懒加载
- (PNLineChart *)stepChart
{
    if (!_stepChart) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame: CGRectMake(5, 5, self.downView.frame.size.width - 10, self.downView.frame.size.height - 10)];
        view.backgroundColor = [UIColor clearColor];
        
        [self.downView addSubview:view];
        _stepChart = view;
    }
    
    return _stepChart;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
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
