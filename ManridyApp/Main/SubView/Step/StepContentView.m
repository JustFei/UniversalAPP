//
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "StepTargetViewController.h"
#import "BLETool.h"
#import "JBChartView.h"
#import "JBLineChartView.h"

@interface StepContentView () <JBLineChartViewDelegate ,JBLineChartViewDataSource >
{
    NSArray *_dataArr;
    double add;
}
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,weak) JBLineChartView *stepChartView;

@property (nonatomic, assign) CGFloat progress;

//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation StepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"StepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        _dataArr = @[@3,@6,@3,@5,@7,@9,@3];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.stepChartView.frame = CGRectMake(10, 10, self.downView.frame.size.width - 20, self.downView.frame.size.height - 20);
    
    [self.stepChartView setState:JBChartViewStateCollapsed];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myBleTool writeMotionRequestToPeripheral];
    });
    
    //创建出CAShapeLayer
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //设置线条的宽度和颜色
    self.shapeLayer.lineWidth = 2.0f;
    self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    
    CGPoint center = CGPointMake(self.progressImageView.center.x, self.progressImageView.center.y + 5);
    CGFloat radius = self.progressImageView.frame.size.width / 2 - 10;
    CGFloat startA = (M_PI * (- 90) / 180.0);  //圆起点位置
    CGFloat endA = (M_PI * (270) / 180.0);  //圆终点位置
    //设置stroke起始点
    self.shapeLayer.strokeStart = 0;
    self.shapeLayer.strokeEnd = 0;
    add = 0.1;
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

- (void)circleAnimationTypeOne
{
    if (self.shapeLayer.strokeEnd > 1 && self.shapeLayer.strokeStart < 1) {
        self.shapeLayer.strokeStart += add;
    }else if(self.shapeLayer.strokeStart == 0){
        self.shapeLayer.strokeEnd += add;
    }
     
    if (self.shapeLayer.strokeEnd == 0) {
        self.shapeLayer.strokeStart = 0;
    }
    
    if (self.shapeLayer.strokeStart == self.shapeLayer.strokeEnd) {
        self.shapeLayer.strokeEnd = 0;
    }
}

- (void)circleAnimationTypeTwo
{
    CGFloat valueOne = arc4random() % 100 / 100.0f;
    CGFloat valueTwo = arc4random() % 100 / 100.0f;
    
    self.shapeLayer.strokeStart = valueOne < valueTwo ? valueOne : valueTwo;
    self.shapeLayer.strokeEnd = valueTwo > valueOne ? valueTwo : valueOne;
}

#pragma mark - JBLineChartViewDelegate && JBLineChartViewDataSource
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [_dataArr[horizontalIndex] floatValue];
}

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 7;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return (unsigned long)_dataArr[lineIndex];
}

#pragma mark - Action
- (IBAction)setTargetAction:(UIButton *)sender
{
    StepTargetViewController *vc = [[StepTargetViewController alloc] initWithNibName:@"StepTargetViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 懒加载
- (JBLineChartView *)stepChartView
{
    if (!_stepChartView) {
        JBLineChartView *view = [[JBLineChartView alloc] init];
        view.backgroundColor = [UIColor redColor];
        
        view.dataSource = self;
        view.delegate = self;
        
        [self.downView addSubview:view];
        _stepChartView = view;
    }
    
    return _stepChartView;
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
