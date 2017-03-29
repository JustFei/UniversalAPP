//
//  BooldHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BooldHistoryViewController.h"
#import "PNChart.h"
#import "BloodModel.h"
#import "FMDBTool.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"
#import "NSStringTool.h"

@interface BooldHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate, PNChartDelegate>
{
    NSInteger highBlood;
    NSInteger lowBlood;
    NSInteger hr;
    NSInteger sumHb;
    NSInteger sumLb;
    NSInteger sumHr;
    
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_hbDataArr;
    NSMutableArray *_lbDataArr;
    NSMutableArray *_hrDataArr;
    NSMutableArray *_averageDataArr;
}
@property (nonatomic ,strong) UIScrollView *downScrollView;
@property (nonatomic ,weak) PNBarChart *lowBloodChart;
@property (nonatomic ,weak) PNBarChart *highBloodChart;
@property (nonatomic ,weak) PNCircleChart *hBloodCircleChart;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UILabel *hrLabel;
@property (weak, nonatomic) IBOutlet UILabel *bpLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *averageBPLabel;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic ,strong) UIButton *titleButton;
@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;
@property (nonatomic ,strong) NSArray *monthArr;

@end

@implementation BooldHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    [self.downView layoutIfNeeded];
    self.downScrollView = [[UIScrollView alloc] initWithFrame:self.downView.bounds];
    self.downScrollView.contentSize = CGSizeMake(2 * self.downView.bounds.size.width, 0);
    self.downScrollView.bounces = NO;
    self.downScrollView.showsHorizontalScrollIndicator = NO;
    [self.downView addSubview:self.downScrollView];
    
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
    _lbDataArr = [NSMutableArray array];
    _hbDataArr = [NSMutableArray array];
    _hrDataArr = [NSMutableArray array];
    _averageDataArr = [NSMutableArray array];
    
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
    
    [self.lowBloodChart setXLabels:_dateArr];
    [self.highBloodChart setXLabels:_dateArr];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DB
- (void)getHistoryDataWithIntDays:(NSInteger)days withDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    [_hbDataArr removeAllObjects];
    [_lbDataArr removeAllObjects];
    [_hrDataArr removeAllObjects];
    [_averageDataArr removeAllObjects];
    
    haveDataDays = 0;
    sumHb = 0;
    sumLb = 0;
    sumHr = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld/%02ld",(long)iCurYear ,iCurMonth ,i];
            DLog(@"%@",dateStr);
            highBlood = 0;
            lowBlood = 0;
            hr = 0;
            
            NSArray *queryArr = [self.myFmdbTool queryBloodWithDate:dateStr];
            if (queryArr.count == 0) {
                [_hbDataArr addObject:@0];
                [_lbDataArr addObject:@0];
                [_hrDataArr addObject:@0];
            }else {
                
                for (BloodModel *model in queryArr) {
                    highBlood += model.highBloodString.integerValue;
                    lowBlood += model.lowBloodString.integerValue;
                    hr += model.bpmString.integerValue;
                }
                sumHb += highBlood / queryArr.count;
                sumLb += lowBlood / queryArr.count;
                sumHr += hr / queryArr.count;
                //当天的平均高，低压
                [_hbDataArr addObject:[NSString stringWithFormat:@"%ld",highBlood / queryArr.count]];
                [_lbDataArr addObject:[NSString stringWithFormat:@"%ld",lowBlood / queryArr.count]];
                [_hrDataArr addObject:[NSString stringWithFormat:@"%ld",hr / queryArr.count]];
                haveDataDays ++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger averageHb = sumHb / haveDataDays;
            NSInteger averageLb = sumLb / haveDataDays;
            NSInteger averageHr = sumHr / haveDataDays;
            [self.bpLabel setText:[NSString stringWithFormat:@"%ld/%ld",averageHb , averageLb]];
            [self.hrLabel setText:[NSString stringWithFormat:NSLocalizedString(@"HRData", nil),averageHr]];
            [self.averageBPLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentMonthBPData", nil),averageHb ,averageLb ,averageHr]];
            double progress = averageHb / 200.000;
            
            if (progress <= 1) {
                [self.hBloodCircleChart updateChartByCurrent:@(progress * 100)];
            }else if (progress >= 1) {
                [self.hBloodCircleChart updateChartByCurrent:@(100)];
            }
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self.hBloodCircleChart strokeChart];
            });
            
            [self.highBloodChart setYValues:_hbDataArr];
            [self.lowBloodChart setYValues:_lbDataArr];
            
            [self.highBloodChart strokeChart];
            [self.lowBloodChart strokeChart];
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
    
    [self.highBloodChart setXLabels:_dateArr];
    [self.lowBloodChart setXLabels:_dateArr];
    [self getHistoryDataWithIntDays:days.length withDate:date];
}

#pragma mark 弹出下拉菜单
-(void)pop
{
    DLog(@"用户点击了右侧弹出下拉菜单按钮");
}

#pragma mark - PNChartDelegate
- (void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    DLog(@"点击了第%ld个bar",barIndex);
    NSNumber *hbNumber = _hbDataArr[barIndex];
    NSNumber *lbNumber = _lbDataArr[barIndex];
    NSNumber *hrNumber = _hrDataArr[barIndex];
    [self.bpLabel setText:[NSString stringWithFormat:@"%@/%@",hbNumber , lbNumber]];
    [self.hrLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentDayHRData", nil),hrNumber]];
    [self.dayLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentDayBPData", nil),_dateArr[barIndex]]];
    double progress = hbNumber.integerValue / 200.000;
    
    if (progress <= 1) {
        [self.hBloodCircleChart updateChartByCurrent:@(progress * 100)];
    }else if (progress >= 1) {
        [self.hBloodCircleChart updateChartByCurrent:@(100)];
    }
    
    [self.hBloodCircleChart strokeChart];
}

#pragma mark - 懒加载
- (PNBarChart *)lowBloodChart
{
    if (!_lowBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(self.downScrollView.bounds.origin.x - 9, self.downScrollView.bounds.origin.y, self.downScrollView.contentSize.width, self.downScrollView.bounds.size.height)];
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
        view.yLabelSum = 5;
        view.showLabel = NO;
        view.barWidth = 10;
        view.showChartBorder = NO;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.delegate = self;
        
        [self.downScrollView addSubview:view];
        _lowBloodChart = view;
    }
    
    return _lowBloodChart;
}

- (PNBarChart *)highBloodChart
{
    if (!_highBloodChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.downScrollView.contentSize.width, self.downScrollView.bounds.size.height)];
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
        view.barWidth = 10;
        view.yLabelSum = 5;
        view.showLabel = YES;
        view.showChartBorder = YES;
        view.isShowNumbers = NO;
        view.isGradientShow = NO;
        view.delegate = self;
        
        [self.downScrollView addSubview:view];
        _highBloodChart = view;
    }
    
    return _highBloodChart;
}

- (PNCircleChart *)hBloodCircleChart
{
    if (!_hBloodCircleChart) {
        [self.view layoutIfNeeded];
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:43.0 / 255.0 green:147.0 / 255.0 blue:190.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor blackColor]];
        [view setStrokeColorGradientStart:[UIColor blackColor]];
        
        [self.view addSubview:view];
        _hBloodCircleChart = view;
    }
    
    return _hBloodCircleChart;
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
