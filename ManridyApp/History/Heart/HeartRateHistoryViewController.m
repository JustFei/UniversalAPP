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

@interface HeartRateHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate>
{
    NSInteger sumHeartRate;
    NSInteger haveDataDays;
    NSMutableArray *_dateArr;
    NSMutableArray *_maxDataArr;
    NSMutableArray *_minDataArr;
}

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (weak, nonatomic) IBOutlet UIView *state1;

@property (weak, nonatomic) IBOutlet UIView *state2;

@property (weak, nonatomic) IBOutlet UIView *state3;

@property (weak, nonatomic) IBOutlet UIView *state4;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *mouthButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *downView;

@property (nonatomic ,weak) PNLineChart *heartLineChartView;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) UIButton *titleButton;

@end

@implementation HeartRateHistoryViewController

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
    _maxDataArr = [NSMutableArray array];
    _minDataArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [_dateArr addObject:[NSString stringWithFormat:@"%d",i]];
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
    [self getHistoryDataWithIntDays:_dateArr.count];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.view removeGestureRecognizer:self.oneFingerSwipedown];
}

- (void)getHistoryDataWithIntDays:(NSInteger)days
{
    sumHeartRate = 0;
    haveDataDays = 0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    //    _dataArr = [NSMutableArray array];
    [_maxDataArr removeAllObjects];
    [_minDataArr removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 1; i <= days; i ++) {
            NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%02ld",iCurYear ,iCurMonth ,i];
            NSLog(@"%@",dateStr);
            
            NSArray *queryArr = [self.myFmdbTool queryHeartRateWithDate:dateStr];
            if (queryArr.count == 0) {
                [_maxDataArr addObject:@0];
                [_minDataArr addObject:@0];
            }else if (queryArr.count == 1) {
                HeartRateModel *model = queryArr.firstObject;
                haveDataDays ++;
                sumHeartRate += model.heartRate.integerValue;
                
                if (self.heartLineChartView.yValueMax < model.heartRate.integerValue) {
                    self.heartLineChartView.yValueMax = model.heartRate.integerValue + 10;
                }
                
                //如果只有一次心率数据的话，最大值和最小值都是该值
                [_minDataArr addObject:@(model.heartRate.integerValue)];
                [_maxDataArr addObject:@(model.heartRate.integerValue)];
            }else {
                
                NSInteger max = 0;
                NSInteger min = 0;
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

                [_maxDataArr addObject:@(max)];
                [_minDataArr addObject:@(min)];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.heartRateLabel setText: [NSString stringWithFormat:@"%ld",sumHeartRate / haveDataDays]];
            
            // Line Chart #1
            NSArray * data01Array = _minDataArr;
            PNLineChartData *data01 = [PNLineChartData new];
            data01.color = PNBlue;
            data01.itemCount = data01Array.count;
            data01.getData = ^(NSUInteger index) {
                CGFloat yValue = [data01Array[index] floatValue];
                return [PNLineChartDataItem dataItemWithY:yValue];
            };
            
            // Line Chart #2
            NSArray * data02Array = _maxDataArr;
            PNLineChartData *data02 = [PNLineChartData new];
            data02.color = PNRed;
            data02.itemCount = data02Array.count;
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
    NSLog(@"indexPath = %ld", indexPath.row);
    NSLog(@"当前选择了%@", title);
    
    // 修改导航栏的标题
    [self.mouthButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark -弹出下拉菜单
-(void)pop
{
    NSLog(@"用户点击了右侧弹出下拉菜单按钮");
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

#pragma mark - 懒加载
- (PNLineChart *)heartLineChartView
{
    if (!_heartLineChartView) {
        PNLineChart *view = [[PNLineChart alloc] initWithFrame:self.downView.bounds];
        view.showCoordinateAxis = YES;
        view.yValueMin = 0;
        view.yValueMax = 10;
        view.chartMarginTop = 5.0;
        
        view.yGridLinesColor = [UIColor clearColor];
        view.showYGridLines = YES;
        
        
        [self.downView addSubview:view];
        _heartLineChartView = view;
    }
    
    return _heartLineChartView;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}

@end
