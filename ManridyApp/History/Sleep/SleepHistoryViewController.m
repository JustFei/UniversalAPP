//
//  SleepHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepHistoryViewController.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"
#import "PNChart.h"
#import "FMDBTool.h"
#import "SleepModel.h"
#import "UserInfoModel.h"
#import "NSStringTool.h"

#define kCurrentStateOFF [UIColor colorWithRed:53.0 / 255.0 green:113.0 / 225.0 blue:161.0 / 255.0 alpha:1]

@interface SleepHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate, PNChartDelegate>
{
    double deepSleep;
    double sumSleep;
    double lowSleep;
    double monthSumSleep;
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_sumDataArr;
    NSMutableArray *_deepDataArr;
    NSMutableArray *_lowDataArr;
}
@property (weak, nonatomic) IBOutlet UILabel *sleepLabel;

@property (weak, nonatomic) IBOutlet UIView *state1;

@property (weak, nonatomic) IBOutlet UIView *state2;

@property (weak, nonatomic) IBOutlet UIView *state3;

@property (weak, nonatomic) IBOutlet UIView *state4;
@property (nonatomic ,strong) NSArray *userArr;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *deepAndLowSleepLabel;

@property (nonatomic ,weak) PNBarChart *deepSleepChart;
@property (nonatomic ,weak) PNBarChart *sumSleepChart;
@property (nonatomic ,weak) PNCircleChart *sleepCircleChart;

@property (nonatomic ,strong) UIButton *titleButton;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;
@property (nonatomic ,strong) NSArray *monthArr;
@end

@implementation SleepHistoryViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    [self.downView layoutIfNeeded];
    
    self.userArr = [self.myFmdbTool queryAllUserInfo];
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setTitle:NSLocalizedString(@"history", nil) forState:UIControlStateNormal];
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
    self.deepAndLowSleepLabel.hidden = YES;
    
    //获取这个月的天数
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:today];
    _dateArr = [NSMutableArray array];
    _sumDataArr = [NSMutableArray array];
    _deepDataArr = [NSMutableArray array];
    _lowDataArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:@(i)];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger month = [components month];
    
    //TODO:判断中英文
    NSString *language = [NSStringTool getPreferredLanguage];
    if ([language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"zh-Hant"]) {
        [self.monthButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"currentMonth", nil),(long)month] forState:UIControlStateNormal];
    }else {
        [self.monthButton setTitle:NSLocalizedString(self.monthArr[month - 1], nil) forState:UIControlStateNormal];
    }
    
    [self.sumSleepChart setXLabels:_dateArr];
    [self.deepSleepChart setXLabels:_dateArr];
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
    [self getHistoryDataWithIntDays:_dateArr.count withDate:[NSDate date]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.view removeGestureRecognizer:self.oneFingerSwipedown];
}

#pragma mark - DB
- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    [_sumDataArr removeAllObjects];
    [_deepDataArr removeAllObjects];
    [_lowDataArr removeAllObjects];
    
    haveDataDays = 0;
    monthSumSleep = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld/%02ld",(long)iCurYear ,iCurMonth ,i];
            DLog(@"%@",dateStr);
            deepSleep = 0;
            sumSleep = 0;
            lowSleep = 0;
            NSArray *queryArr = [self.myFmdbTool querySleepWithDate:dateStr];
            if (queryArr.count == 0) {
                [_sumDataArr addObject:@0];
                [_deepDataArr addObject:@0];
                [_lowDataArr addObject:@0];
            }else {
                
                for (SleepModel *model in queryArr) {
                    deepSleep += model.deepSleep.integerValue;
                    sumSleep += model.sumSleep.integerValue;
                    lowSleep += model.lowSleep.integerValue;
                }
                double deep = deepSleep / 60;
                double sum = sumSleep / 60;
                double low = lowSleep / 60;
                
                [_deepDataArr addObject:[NSString stringWithFormat:@"%.2f",deep]];
                [_sumDataArr addObject:[NSString stringWithFormat:@"%.2f",sum]];
                [_lowDataArr addObject:[NSString stringWithFormat:@"%.2f",low]];
                
                monthSumSleep += sumSleep;
                haveDataDays ++;
                
                if (self.sumSleepChart.yMaxValue < sumSleep / 60) {
                    self.sumSleepChart.yMaxValue = sumSleep / 60 + 3;
                    self.deepSleepChart.yMaxValue = sumSleep / 60 + 3;
                }
            }
        }
        double averageSleep = monthSumSleep / haveDataDays / 60;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (monthSumSleep == 0) {
                [self.sleepLabel setText:@"0"];
                [self.sleepCircleChart updateChartByCurrent:@(0)];
            }else {
                [self.sleepLabel setText:[NSString stringWithFormat:@"%.2f",averageSleep]];
                [self drawCircle:averageSleep];
            }
            
            if (averageSleep <= 6) {
                [self.stateLabel setText:NSLocalizedString(@"lackofSleep", nil)];
                [self.stateLabel setTextColor:[UIColor redColor]];
                
                [self.state1 setBackgroundColor:[UIColor redColor]];
                [self.state2 setBackgroundColor:kCurrentStateOFF];
                [self.state3 setBackgroundColor:kCurrentStateOFF];
                [self.state4 setBackgroundColor:kCurrentStateOFF];
                
            }else if (averageSleep > 6 && averageSleep < 7) {
                [self.stateLabel setText:NSLocalizedString(@"lessofSleep", nil)];
                [self.stateLabel setTextColor:[UIColor orangeColor]];
                
                [self.state1 setBackgroundColor:kCurrentStateOFF];
                [self.state2 setBackgroundColor:[UIColor orangeColor]];
                [self.state3 setBackgroundColor:kCurrentStateOFF];
                [self.state4 setBackgroundColor:kCurrentStateOFF];
                
            }else if (averageSleep >= 7 && averageSleep < 8) {
                [self.stateLabel setText:NSLocalizedString(@"normalofSleep", nil)];
                [self.stateLabel setTextColor:[UIColor yellowColor]];
                
                [self.state1 setBackgroundColor:kCurrentStateOFF];
                [self.state2 setBackgroundColor:kCurrentStateOFF];
                [self.state3 setBackgroundColor:[UIColor yellowColor]];
                [self.state4 setBackgroundColor:kCurrentStateOFF];
                
            }else if (averageSleep >= 8) {
                [self.stateLabel setText:NSLocalizedString(@"moreofSleep", nil)];
                [self.stateLabel setTextColor:[UIColor greenColor]];
                
                [self.state1 setBackgroundColor:kCurrentStateOFF];
                [self.state2 setBackgroundColor:kCurrentStateOFF];
                [self.state3 setBackgroundColor:kCurrentStateOFF];
                [self.state4 setBackgroundColor:[UIColor greenColor]];
                
            }
            
            [self.sumSleepChart setYValues:_sumDataArr];
            [self.deepSleepChart setYValues:_deepDataArr];
            
            [self.sumSleepChart strokeChart];
            [self.deepSleepChart strokeChart];
        });
    });
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

- (void)drawCircle:(double)averageSleep
{
    if (self.userArr.count != 0) {
        
        UserInfoModel *model = self.userArr.firstObject;
        
        if (model.sleepTarget != 0) {
            double progress = averageSleep / model.sleepTarget;
            
            if (progress <= 1) {
                [self.sleepCircleChart updateChartByCurrent:@(progress * 100)];
            }else if (progress >= 1) {
                [self.sleepCircleChart updateChartByCurrent:@(100)];
            }
        }else {
            //如果用户没有设置目标睡眠的话，就默认为8h
            float progress = averageSleep / 8;
            
            if (progress <= 1) {
                [self.sleepCircleChart updateChartByCurrent:@(progress * 100)];
            }else if (progress >= 1) {
                [self.sleepCircleChart updateChartByCurrent:@(100)];
            }
        }
    }else {
        //如果用户没有设置目标睡眠的话，就默认为8h
        float progress = averageSleep / 8;
        
        if (progress <= 1) {
            [self.sleepCircleChart updateChartByCurrent:@(progress * 100)];
        }else if (progress >= 1) {
            [self.sleepCircleChart updateChartByCurrent:@(100)];
        }
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.sleepCircleChart strokeChart];
    });
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
    DLog(@"当前选择了%@", title);
    
    // 修改导航栏的标题
    [self.monthButton setTitle:title forState:UIControlStateNormal];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    currentFormatter.dateFormat = @"yyyy";
    NSString *yyyyStr = [currentFormatter stringFromDate:currentDate];
    
    NSString *string = [NSString stringWithFormat:@"%@/%ld/15", yyyyStr, indexPath.row + 1];
    currentFormatter.dateFormat = @"yyyy/MM/dd";
    NSDate *date=[currentFormatter dateFromString:string];
    
    //获取这个月的天数
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:date];
    
    [_dateArr removeAllObjects];
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [self.sumSleepChart setXLabels:_dateArr];
    [self.deepSleepChart setXLabels:_dateArr];
    [self getHistoryDataWithIntDays:days.length withDate:date];
}

#pragma mark 弹出下拉菜单
-(void)pop
{
    DLog(@"用户点击了右侧弹出下拉菜单按钮");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSNumber *sumSleepNumber = _sumDataArr[barIndex];
    NSNumber *deepSleepNumber = _deepDataArr[barIndex];
    NSNumber *lowSleepNumber = _lowDataArr[barIndex];
    self.deepAndLowSleepLabel.hidden = NO;
    if (sumSleepNumber.floatValue != 0) {
        [self.deepAndLowSleepLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentDaySleepData", nil),sumSleepNumber ,deepSleepNumber ,lowSleepNumber]];
    }else {
        [self.deepAndLowSleepLabel setText:NSLocalizedString(@"currentDayNOSleepData", nil)];
    }
    [self drawCircle:sumSleepNumber.doubleValue];
}

#pragma mark - 懒加载
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
        view.yMaxValue = 4;
        view.showLabel = YES;
        view.yLabelSum = 5;
        view.showChartBorder = YES;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.delegate = self;
        [view setXLabelSkip:5];
        
        [self.downView addSubview:view];
        _sumSleepChart = view;
    }
    
    return _sumSleepChart;
}

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
        view.yMaxValue = 4;
        view.showLabel = YES;
        view.yLabelSum = 5;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.delegate = self;
        [view setXLabelSkip:5];
        
        [self.downView addSubview:view];
        _deepSleepChart = view;
    }
    
    return _deepSleepChart;
}

- (PNCircleChart *)sleepCircleChart
{
    if (!_sleepCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:TEXT_WHITE_COLOR_LEVEL0 displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:WHITE_COLOR];
        
        [self.view addSubview:view];
        _sleepCircleChart = view;
    }
    
    return _sleepCircleChart;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    return _myFmdbTool;
}

- (NSArray *)monthArr
{
    if (!_monthArr) {
        _monthArr = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    }
    
    return _monthArr;
}

@end
