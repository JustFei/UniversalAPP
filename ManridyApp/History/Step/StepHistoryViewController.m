//
//  StepHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/20.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepHistoryViewController.h"
#import "PNChart.h"
#import "FMDBTool.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"
#import "StepDataModel.h"



@interface StepHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate>
{
    NSInteger sumStep;
    NSInteger sumMileage;
    NSInteger sumkCal;
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_dataArr;
}

@property (weak, nonatomic) IBOutlet UILabel *averageStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *averagerMileageAndkCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumStepAndMilAndkCal;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic ,weak) PNBarChart *stepBarChart;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;



@end

@implementation StepHistoryViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setTitle:@"历史记录" forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = self.titleButton;
    
    if (!self.navigationController) {
        [self.backButton setHidden:NO];
        [self.titleLabel setHidden:NO];
        [self.backButton addTarget:self action:@selector(oneFingerSwipeDown:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [self.backButton setHidden:YES];
        [self.titleLabel setHidden:YES];
    }

    //获取这个月的天数
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:today];
    _dateArr = [NSMutableArray array];
    _dataArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:@(i)];
    }
    
    //这里存在这样一个问题，当y轴数据都为0时，会出现显示很多很多个0在Y轴上
    [self.stepBarChart setXLabels:_dateArr];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.oneFingerSwipedown =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeDown:)];
    [self.oneFingerSwipedown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.oneFingerSwipedown];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //绘制图表放在这里不会造成UI卡顿
    [self getHistoryDataWithIntDays:_dateArr.count];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.view removeGestureRecognizer:self.oneFingerSwipedown];
}

- (void)getHistoryDataWithIntDays:(NSInteger)days
{
    sumStep = 0;
    sumMileage = 0;
    sumkCal = 0;
    haveDataDays = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
//    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%02ld",iCurYear ,iCurMonth ,i];
            NSLog(@"%@",dateStr);
            
            NSArray *queryArr = [self.myFmdbTool queryStepWithDate:dateStr];
            if (queryArr.count == 0) {
                [_dataArr addObject:@0];
            }else {
                StepDataModel *model = queryArr.firstObject;
                
                sumStep += model.step.integerValue;
                sumMileage += model.mileage.integerValue;
                sumkCal += model.kCal.integerValue;
                haveDataDays ++;
                
                if (self.stepBarChart.yMaxValue < model.step.integerValue) {
                    self.stepBarChart.yMaxValue = model.step.integerValue + 10;
                }
                
                [_dataArr addObject:@(model.step.integerValue)];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sumStepAndMilAndkCal setText:[NSString stringWithFormat:@"本月计步统计：共（%ld步/%ld公里/%ld千卡）",sumStep ,sumMileage ,sumkCal]];
            [self.averageStepLabel setText:[NSString stringWithFormat:@"%ld",(sumStep / haveDataDays)]];
            [self.averagerMileageAndkCalLabel setText:[NSString stringWithFormat:@"%ld公里/%ld千卡",(sumMileage / haveDataDays) ,(sumkCal / haveDataDays)]];
            
            [self.stepBarChart setYValues:_dataArr];
            
            [self.stepBarChart strokeChart];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)chooseMouthAction:(UIButton *)sender
{
    // 1.创建下拉菜单
    DropdownMenuView *dropdownMenuView = [[DropdownMenuView alloc] init];
    // 设置下拉菜单弹出、销毁事件的监听者
    dropdownMenuView.delegate = self;
    
    // 2.设置要显示的内容
    TitleMenuViewController *titleMenuVC = [[TitleMenuViewController alloc] init];
    titleMenuVC.dropdownMenuView = dropdownMenuView;
    titleMenuVC.delegate = self;
    
    CGRect temp = titleMenuVC.view.frame;
    
    temp.size.width = 57;
    temp.size.height = 250;
    
    titleMenuVC.view.frame = temp;
    
    dropdownMenuView.contentController = titleMenuVC;
    
    // 3.显示下拉菜单
    [dropdownMenuView showFrom:sender];
}

- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DropdownMenuDelegate
#pragma mark 下拉菜单被销毁了
- (void)dropdownMenuDidDismiss:(DropdownMenuView *)menu
{
    // 让指示箭头向下
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    titleButton.selected = NO;
}

#pragma mark 下拉菜单显示了
- (void)dropdownMenuDidShow:(DropdownMenuView *)menu
{
    // 让指示箭头向上
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    titleButton.selected = YES;
}

#pragma mark - TitleMenuDelegate
-(void)selectAtIndexPath:(NSIndexPath *)indexPath title:(NSString *)title
{
    NSLog(@"indexPath = %ld", indexPath.row);
    NSLog(@"当前选择了%@", title);
    
    // 修改导航栏的标题
    [self.monthButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark 弹出下拉菜单
-(void)pop
{
    NSLog(@"用户点击了右侧弹出下拉菜单按钮");
}

#pragma mark - 懒加载
- (PNBarChart *)stepBarChart
{
    if (!_stepBarChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.downView.frame.size.width, self.downView.frame.size.height)];
        view.backgroundColor = [UIColor clearColor];
        
        view.yChartLabelWidth = 20.0;
        view.chartMarginLeft = 30.0;
        view.chartMarginRight = 10.0;
        view.chartMarginTop = 5.0;
        view.chartMarginBottom = 10.0;
        view.isGradientShow = NO;
        view.isShowNumbers = NO;
        view.labelMarginTop = 5.0;
        view.showChartBorder = YES;
        view.showXLabel = YES;
        view.showYLabel = YES;
        [view setStrokeColor:[UIColor blackColor]];
        view.yMinValue = 0;
        view.yMaxValue = 10;
        view.yLabelSum = 10;
        [view setXLabelSkip:5];
        
        [self.downView addSubview:view];
        _stepBarChart = view;
    }
    
    return  _stepBarChart;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}
@end
