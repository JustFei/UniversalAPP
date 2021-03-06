//
//  HeartRateHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateHistoryViewController.h"
#import "PNChart.h"
#import "FMDBTool.h"
#import "HeartRateModel.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"
#import "NSStringTool.h"


#define kStateOFF [UIColor colorWithRed:77.0 / 255.0 green:132.0 / 255.0 blue:195.0 / 255.0 alpha:1]

@interface HeartRateHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate ,PNChartDelegate>
{
    double sumHeartRate;
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_maxDataArr;
    NSMutableArray *_minDataArr;
}
@property (weak, nonatomic) IBOutlet UILabel *monthAverageLabel;

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (weak, nonatomic) IBOutlet UIView *state1;

@property (weak, nonatomic) IBOutlet UIView *state2;

@property (weak, nonatomic) IBOutlet UIView *state4;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@property (nonatomic ,weak) PNLineChart *heartLineChartView;
@property (nonatomic ,weak) PNCircleChart *heartCircleChart;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) UIButton *titleButton;
@property (nonatomic ,strong) NSArray *monthArr;

@end

@implementation HeartRateHistoryViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    //获取这个月的天数
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSCalendarUnitDay
                           inUnit:NSCalendarUnitMonth
                          forDate:today];
    
    _dateArr = [NSMutableArray array];
    _maxDataArr = [NSMutableArray array];
    _minDataArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:[NSString stringWithFormat:@"%d",i]];
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

- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    sumHeartRate = 0;
    haveDataDays = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger iCurYear = [components year] % 100;  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    //    _dataArr = [NSMutableArray array];
    [_maxDataArr removeAllObjects];
    [_minDataArr removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"20<%02ld%02ld%02ld>",(long)iCurYear ,iCurMonth ,i];
            
            NSInteger max = 0;
            NSInteger min = 0;
            
            NSArray *queryArr = [self.myFmdbTool queryHeartRateWithDate:dateStr];
            if (queryArr.count == 0) {
                [_maxDataArr addObject:@(max)];
                [_minDataArr addObject:@(min)];
            }else if (queryArr.count == 1) {
                HeartRateModel *model = queryArr.firstObject;
                haveDataDays ++;
                sumHeartRate += model.heartRate.integerValue;
                
//                if (self.heartLineChartView.yValueMax < model.heartRate.integerValue + 30) {
//                    self.heartLineChartView.yValueMax = model.heartRate.integerValue + 50;
//                }
                
                //如果只有一次心率数据的话，最大值和最小值都是该值
                [_minDataArr addObject:@(model.heartRate.integerValue)];
                [_maxDataArr addObject:@(model.heartRate.integerValue)];
            }else {
                HeartRateModel *model = queryArr.firstObject;
                
                if (model.heartRate != 0) {
                    min = model.heartRate.integerValue;
                }
                
                for (HeartRateModel *model in queryArr) {
                    haveDataDays ++;
                    sumHeartRate += model.heartRate.integerValue;
                    
                    if (model.heartRate.integerValue > max) {
                        max = model.heartRate.integerValue;
                    }
                    
                    if (model.heartRate.integerValue < min) {
                        min = model.heartRate.integerValue;
                    }
                }

                DLog(@"max == %ld",(long)max);
                DLog(@"min == %ld",(long)min);
                
//                if (self.heartLineChartView.yValueMax < max + 30) {
//                    self.heartLineChartView.yValueMax = max + 30;
//                }
                
                [_maxDataArr addObject:@(max)];
                [_minDataArr addObject:@(min)];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger averageNumber = sumHeartRate / haveDataDays;
            double doubleAverageNumber = sumHeartRate / haveDataDays;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self.heartCircleChart strokeChart];
            });
            [self.heartCircleChart updateChartByCurrent:@(doubleAverageNumber)];
            
            
            [self.heartRateLabel setText: [NSString stringWithFormat:@"%ld",(long)averageNumber]];
            self.monthAverageLabel.text = NSLocalizedString(@"averagerHR", nil);
            
            if (averageNumber < 60) {
                self.state1.backgroundColor = [UIColor redColor];
                self.state2.backgroundColor = kStateOFF;
                self.state4.backgroundColor = kStateOFF;
                self.stateLabel.text = NSLocalizedString(@"low", nil);
            }else if (averageNumber >= 60 && averageNumber <= 100) {
                self.state1.backgroundColor = kStateOFF;
                self.state2.backgroundColor = [UIColor greenColor];
                self.state4.backgroundColor = kStateOFF;
                self.stateLabel.text = NSLocalizedString(@"normal", nil);
            }else {
                self.state1.backgroundColor = kStateOFF;
                self.state2.backgroundColor = kStateOFF;
                self.state4.backgroundColor = [UIColor redColor];
                self.stateLabel.text = NSLocalizedString(@"high", nil);
            }
            
            // Line Chart #1
            NSArray * data01Array = _minDataArr;
            PNLineChartData *data01 = [PNLineChartData new];
            data01.color = PNBlue;
            data01.itemCount = data01Array.count;
            data01.lineWidth = 1;
            data01.inflexionPointColor = PNBlue;
            data01.inflexionPointStyle = PNLineChartPointStyleCircle;
            data01.inflexionPointWidth = 3;
            data01.getData = ^(NSUInteger index) {
                CGFloat yValue = [data01Array[index] floatValue];
                return [PNLineChartDataItem dataItemWithY:yValue];
            };
            
            // Line Chart #2
            NSArray * data02Array = _maxDataArr;
            PNLineChartData *data02 = [PNLineChartData new];
            data02.color = PNRed;
            data02.itemCount = data02Array.count;
            data02.lineWidth = 1;
            data02.inflexionPointColor = PNRed;
            data02.inflexionPointStyle = PNLineChartPointStyleCircle;
            data02.inflexionPointWidth = 3;
            data02.getData = ^(NSUInteger index) {
                CGFloat yValue = [data02Array[index] floatValue];
                return [PNLineChartDataItem dataItemWithY:yValue];
            };
            
            [self.heartLineChartView setXLabels:_dateArr];
            self.heartLineChartView.chartData = @[data01, data02];
            [self.heartLineChartView strokeChart];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DropdownMenuDelegate
#pragma mark -下拉菜单被销毁了
- (void)dropdownMenuDidDismiss:(DropdownMenuView *)menu
{
    // 让指示箭头向下
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    titleButton.selected = NO;
}

#pragma mark -下拉菜单显示了
- (void)dropdownMenuDidShow:(DropdownMenuView *)menu
{
    // 让指示箭头向上
    UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
    titleButton.selected = YES;
}

#pragma mark - TitleMenuDelegate
-(void)selectAtIndexPath:(NSIndexPath *)indexPath title:(NSString *)title
{
    DLog(@"选择了%ld月",indexPath.row + 1);
    // 修改导航栏的标题
    [self.monthButton setTitle:title forState:UIControlStateNormal];
    
    // 修改导航栏的标题
    [self.monthButton setTitle:title forState:UIControlStateNormal];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    currentFormatter.dateFormat = @"yyyy";
    NSString *yyyyStr = [currentFormatter stringFromDate:currentDate];
    
    NSString *string = [NSString stringWithFormat:@"%@-%ld-15", yyyyStr, indexPath.row + 1];
    currentFormatter.dateFormat = @"yyyy-MM-dd";
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
    
    [self getHistoryDataWithIntDays:days.length withDate:date];
}

#pragma mark -弹出下拉菜单
-(void)pop
{
//    DLog(@"用户点击了右侧弹出下拉菜单按钮");
}

#pragma mark - Action
- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
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

#pragma mark - PNChartDelegate
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
{
    DLog(@"点击了%ld根线",(long)lineIndex);
}

- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex
{
    DLog(@"当天最高 == %@，最低 == %@",_maxDataArr[pointIndex] ,_minDataArr[pointIndex]);
    NSInteger max = ((NSNumber *)_maxDataArr[pointIndex]).integerValue;
    NSInteger min = ((NSNumber *)_minDataArr[pointIndex]).integerValue;
    NSInteger average = (max + min) / 2;
    self.heartRateLabel.text = [NSString stringWithFormat:@"%ld",(long)average];
    self.monthAverageLabel.text = NSLocalizedString(@"currentDayAveragerHR", nil);
}

#pragma mark - 懒加载
- (PNLineChart *)heartLineChartView
{
    if (!_heartLineChartView) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.delegate = self;
        view.showCoordinateAxis = YES;
        view.yValueMin = 0;
        view.yValueMax = 200;
        if (self.view.frame.size.width == 320) {
            view.xLabelFont = [UIFont systemFontOfSize:5.5];
        }else {
            view.xLabelFont = [UIFont systemFontOfSize:8];
        }
        view.xLabelWidth = 15;
        view.chartMarginLeft = 30;
        view.chartMarginRight = 0;

        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        [self.downView addSubview:view];
        _heartLineChartView = view;
    }
    
    return _heartLineChartView;
}

- (PNCircleChart *)heartCircleChart
{
    if (!_heartCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@200 current:@0 clockwise:YES shadow:YES shadowColor:TEXT_WHITE_COLOR_LEVEL0 displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:WHITE_COLOR];
        
        [self.view addSubview:view];
        _heartCircleChart = view;
    }
    
    return _heartCircleChart;
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
