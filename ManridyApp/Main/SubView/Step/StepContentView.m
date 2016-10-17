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
}

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,weak) JBLineChartView *stepChartView;

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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myBleTool writeMotionRequestToPeripheral];
    });
}

#pragma mark - JBLineChartViewDelegate && JBLineChartViewDataSource
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return 10;
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



//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    // 1.自己先处理事件...
//    NSLog(@"do somthing...");
//    // 2.再调用系统的默认做法，再把事件交给上一个响应者处理
//    [super touchesBegan:touches withEvent:event];
//}

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
