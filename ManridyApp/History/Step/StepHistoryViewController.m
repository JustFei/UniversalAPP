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
#import "SportModel.h"
#import "UserInfoModel.h"



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
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@property (nonatomic ,weak) PNBarChart *stepBarChart;
@property (nonatomic ,weak) PNCircleChart *stepCircleChart;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;

@end

@implementation StepHistoryViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    [self.downView layoutIfNeeded];
    
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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger month = [components month];
    [self.monthButton setTitle:[NSString stringWithFormat:@"%ld月",month] forState:UIControlStateNormal];
    
    [self.stepBarChart setXLabels:_dateArr];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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
    sumStep = 0;
    sumMileage = 0;
    sumkCal = 0;
    haveDataDays = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    //    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%ld/%02ld/%02ld",iCurYear ,iCurMonth ,i];
            NSLog(@"%@",dateStr);
            
            NSArray *queryArr = [self.myFmdbTool queryStepWithDate:dateStr];
            if (queryArr.count == 0) {
                [_dataArr addObject:@0];
            }else {
                SportModel *model = queryArr.firstObject;
                
                sumStep += model.stepNumber.integerValue;
                sumMileage += model.mileageNumber.integerValue;
                sumkCal += model.kCalNumber.integerValue;
                haveDataDays ++;
                
                if (self.stepBarChart.yMaxValue < model.stepNumber.integerValue) {
                    self.stepBarChart.yMaxValue = model.stepNumber.integerValue + 10;
                }
                
                [_dataArr addObject:@(model.stepNumber.integerValue)];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            double avergaeMileage = (sumMileage / haveDataDays);
            
            [self.sumStepAndMilAndkCal setText:[NSString stringWithFormat:@"本月计步统计：共（%ld步/%.1f公里/%ld卡）",sumStep ,(double)sumMileage / 1000 ,sumkCal]];
            [self.averageStepLabel setText:[NSString stringWithFormat:@"%ld",(sumStep / haveDataDays)]];
            [self.averagerMileageAndkCalLabel setText:[NSString stringWithFormat:@"%.1f公里/%ld卡",avergaeMileage / 1000 ,(sumkCal / haveDataDays)]];
            NSArray *_userArr = [self.myFmdbTool queryAllUserInfo];
            if (_userArr.count != 0) {
                
                UserInfoModel *model = _userArr.firstObject;
                
                if (model.stepTarget != 0) {
                    float progress = (double)(sumStep / haveDataDays) / model.stepTarget;
                    
                    if (progress <= 1) {
                        [self.stepCircleChart updateChartByCurrent:@(progress * 100)];
                    }else if (progress >= 1) {
                        [self.stepCircleChart updateChartByCurrent:@100];
                    }
                }else {
                    //如果用户没有设置目标步数的话，就默认为10000步
                    float progress = (double)(sumStep / haveDataDays) / 10000;
                    
                    if (progress <= 1) {
                        [self.stepCircleChart updateChartByCurrent:@(progress * 100 )];
                    }else if (progress >= 1) {
                        [self.stepCircleChart updateChartByCurrent:@100];
                    }
                }
            }else {
                //如果用户没有设置目标步数的话，就默认为10000步
                float progress = (double)(sumStep / haveDataDays) / 10000;
                
                if (progress <= 1) {
                    [self.stepCircleChart updateChartByCurrent:@(progress * 100 )];
                }else if (progress >= 1) {
                    [self.stepCircleChart updateChartByCurrent:@100];
                }
            }
            
            [self.stepCircleChart strokeChart];
            [self.stepBarChart setYValues:_dataArr];
            [self.stepBarChart strokeChart];
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
    NSLog(@"当前选择了%@", title);
    
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
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:date];
    
    [_dateArr removeAllObjects];
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [self.stepBarChart setXLabels:_dateArr];
    [self getHistoryDataWithIntDays:days.length withDate:date];
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
        view.yMaxValue = 10;
        view.yLabelSum = 10;
        [view setXLabelSkip:5];
        
        [self.downView addSubview:view];
        _stepBarChart = view;
    }
    
    return  _stepBarChart;
}

- (PNCircleChart *)stepCircleChart
{
    if (!_stepCircleChart) {
        PNCircleChart *view = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.progressImageView.frame.origin.x + 15, self.progressImageView.frame.origin.y + 27, self.progressImageView.frame.size.width - 30, self.progressImageView.frame.size.height - 40) total:@100 current:@0 clockwise:YES shadow:YES shadowColor:[UIColor colorWithRed:12.0 / 255.0 green:97.0 / 255.0 blue:158.0 / 255.0 alpha:1] displayCountingLabel:NO overrideLineWidth:@5];
        view.backgroundColor = [UIColor clearColor];
        [view setStrokeColor:[UIColor yellowColor]];
        [view setStrokeColorGradientStart:[UIColor yellowColor]];
        
        [self.view addSubview:view];
        _stepCircleChart = view;
    }
    
    return _stepCircleChart;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}
@end
