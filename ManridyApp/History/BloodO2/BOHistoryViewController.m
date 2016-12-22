//
//  BOHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/19.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BOHistoryViewController.h"
#import "PNChart.h"
#import "BloodO2Model.h"
#import "FMDBTool.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"
#import "NSStringTool.h"

@interface BOHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate, PNChartDelegate>
{
    NSInteger bo;
    NSInteger sumBo;
    
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_boArr;
}
@property (weak, nonatomic) IBOutlet UILabel *boLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic ,strong) UIButton *titleButton;
@property (nonatomic ,weak) PNBarChart *boBarChart;
@property (nonatomic ,weak) PNCircleChart *boCircleChart;
@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;
@property (nonatomic ,strong) NSArray *monthArr;
@end

@implementation BOHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    [self.downView layoutIfNeeded];
    
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
    _boArr = [NSMutableArray array];
    _dateArr = [NSMutableArray array];
    
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
    
    [self.boBarChart setXLabels:_dateArr];
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
    
    [_boArr removeAllObjects];
    
    haveDataDays = 0;
    sumBo = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%02ld/%02ld/%02ld",iCurYear ,iCurMonth ,i];
            DLog(@"%@",dateStr);
            bo = 0;
            
            NSArray *queryArr = [self.myFmdbTool queryBloodO2WithDate:dateStr];
            if (queryArr.count == 0) {
                [_boArr addObject:@0];
            }else {
                
                for (BloodO2Model *model in queryArr) {
                    bo += model.integerString.integerValue;
                }
                sumBo += bo / queryArr.count;
                //当天的平均高，低压
                [_boArr addObject:[NSString stringWithFormat:@"%ld",bo / queryArr.count]];
                haveDataDays ++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger averageBo = sumBo / haveDataDays;
            [self.boLabel setText:[NSString stringWithFormat:@"%ld",averageBo]];
            double progress = averageBo / 100.000;
            
            if (progress <= 1) {
                [self.boCircleChart updateChartByCurrent:@(progress * 100)];
            }else if (progress >= 1) {
                [self.boCircleChart updateChartByCurrent:@(100)];
            }
            
            [self.boCircleChart strokeChart];
            
            [self.boBarChart setYValues:_boArr];
            [self.boBarChart strokeChart];
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
    
    [self.boBarChart setXLabels:_dateArr];
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
    DLog(@"点击了第%ld个bar",barIndex + 1);
    NSNumber *boNumber = _boArr[barIndex];
    [self.boLabel setText:[NSString stringWithFormat:@"%@",boNumber]];
    [self.dateLabel setText:[NSString stringWithFormat:NSLocalizedString(@"currentDayBOData", nil),_dateArr[barIndex]]];
    self.dateLabel.hidden = NO;
    double progress = boNumber.integerValue / 100.000;
    
    if (progress <= 1) {
        [self.boCircleChart updateChartByCurrent:@(progress * 100)];
    }else if (progress >= 1) {
        [self.boCircleChart updateChartByCurrent:@(100)];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.boCircleChart strokeChart];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (PNBarChart *)boBarChart
{
    if (!_boBarChart) {
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:self.downView.bounds];
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
        view.showLabel = YES;
        [view setStrokeColor:[UIColor blackColor]];
        view.yMinValue = 0;
        view.yMaxValue = 100;
        view.yLabelSum = 10;
        [view setXLabelSkip:5];
        view.delegate = self;
        
        [self.downView addSubview:view];
        _boBarChart = view;
    }
    
    return  _boBarChart;
}

- (PNCircleChart *)boCircleChart
{
    if (!_boCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:12.0 / 255.0 green:97.0 / 255.0 blue:158.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor colorWithRed:191.0 / 255.0 green:41.0 / 255.0 blue:50.0 / 255.0 alpha:1]];
        [view setStrokeColorGradientStart:[UIColor colorWithRed:191.0 / 255.0 green:41.0 / 255.0 blue:50.0 / 255.0 alpha:1]];
        
        [self.view addSubview:view];
        _boCircleChart = view;
    }
    
    return _boCircleChart;
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
