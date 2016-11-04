//
//  StepViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MainViewController.h"
#import "HeartRateContentView.h"
#import "TemperatureContentView.h"
#import "SleepContentView.h"
#import "BloodPressureContentView.h"
#import "MenuContentView.h"
#import "BLETool.h"
#import "FMDBTool.h"
#import "StepDataModel.h"
#import "StepHistoryViewController.h"
#import "HeartRateHistoryViewController.h"
#import "SleepHistoryViewController.h"
#import "MBProgressHUD.h"

#import "SettingViewController.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

#define kCurrentStateOFF [UIColor colorWithRed:53.0 / 255.0 green:113.0 / 225.0 blue:161.0 / 255.0 alpha:1]

@interface MainViewController () <UIScrollViewDelegate ,BleReceiveDelegate>
{
    NSArray *_titleArr;
    
    BOOL isShowList;
    NSArray *_userArr;
    NSInteger _currentPage;
}
@property (nonatomic ,weak) UIScrollView *backGroundView;

@property (nonatomic ,weak) UIPageControl *pageControl;

@property (nonatomic ,assign) BOOL didEndDecelerating;

@property (nonatomic ,weak) MenuContentView *menuView;

@property (nonatomic ,strong) UIButton *titleButton;

//@property (nonatomic ,strong) UIButton *leftButton;

@property (nonatomic ,strong) UIButton *rightButton;

//@property (nonatomic ,strong) StepContentView *stepView;

@property (nonatomic ,strong) HeartRateContentView *heartRateView;

@property (nonatomic ,strong) TemperatureContentView *temperatureView;

@property (nonatomic ,strong) SleepContentView *sleepView;

@property (nonatomic ,strong) BloodPressureContentView  *bloodPressureView;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipeUp;

@property (nonatomic ,strong) MBProgressHUD *hud;

@end

@implementation MainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleArr = @[@"计步",@"心率",@"体温",@"睡眠",@"血压"];
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    [self createUI];
    
    self.stepView.dateArr = [self getWeekBeginAndEnd:[NSDate date]];
    self.temperatureView.dateArr = self.stepView.dateArr;
    
    
    [self hiddenFunctionView];
    _currentPage = 0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.receiveDelegate = self;
    
    _userArr = [self.myFmdbTool queryAllUserInfo];
    self.oneFingerSwipeUp =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeUp:)];
    [self.oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:self.oneFingerSwipeUp];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSMutableArray *dataArr = [NSMutableArray array];
    
    for (NSString *dateString in self.stepView.dateArr) {
//        NSString *dateStr = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        NSArray *queryArr = [self.myFmdbTool queryStepWithDate:dateString];
        
        SportModel *model = [[SportModel alloc] init];
        
        if (queryArr.count == 0) {
            [dataArr addObject:model];
        }else {
            model = queryArr.firstObject;
            
            [dataArr addObject:model];
        }
    }
    
    self.stepView.dataArr = dataArr;
    
    [self.stepView showChartView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    NSLog(@"会走这方法");
    [self.view removeGestureRecognizer:self.oneFingerSwipeUp];
}

- (void)dealloc
{
    [self.myFmdbTool CloseDataBase];
}

- (void)showFunctionView
{
    [self.stepView showChartView];
    self.stepView.weekStatisticsLabel.hidden = NO;
    self.stepView.mileageAndkCalLabel.hidden = NO;
    self.stepView.todayLabel.hidden = NO;
    
    self.stepView.stepLabel.userInteractionEnabled = NO;
    
    [self.stepView.stepLabel setText:@"0"];
    [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:50]];
}

- (void)hiddenFunctionView
{
    int currentPage = floor((self.backGroundView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1;
    
    if (currentPage != 0) {
        
        [self.backGroundView setContentOffset:CGPointMake(0 * WIDTH, -64) animated:YES];
        [self.titleButton setTitle:_titleArr[0] forState:UIControlStateNormal];
        self.pageControl.currentPage = 0;
    }
    
    //为了方便测试，可以将滚动调为YES
    self.stepView.weekStatisticsLabel.hidden = YES;
    self.stepView.mileageAndkCalLabel.hidden = YES;
    self.stepView.todayLabel.hidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"]) {
        BOOL isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
        
        if (isBind) {
            [self.stepView.stepLabel setText:@"设备连接中。。。"];
            [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:15]];
        }else {
            [self.stepView.stepLabel setText:@"未绑定设备，请前往设置绑定设备"];
            [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:11]];
        }
    }else {
        [self.stepView.stepLabel setText:@"未绑定设备，请前往设置绑定设备"];
        [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:11]];
    }
}

- (void)writeData
{
    switch (self.pageControl.currentPage) {
        case 0:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 0) {
                    
                    //刚进来先查询设备的数据条数
                    [self.myBleTool writeMotionRequestToPeripheralWithMotionType:MotionTypeDataInPeripheral];
                }
            });
        }
            break;
        case 1:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 1) {
                    [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
                }
            });
        }
            break;
        case 2:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 2) {
                    //读取当前体温
                }
            });
        }
            break;
        case 3:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 3) {
                    [self.myBleTool writeSleepRequestToperipheral:SleepDataLastData];
                }
            });
        }
            break;
        case 4:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 4) {
                    //读取血压数据
                }
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)createUI
{
    //left
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 20, 20)];
//    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"all_data_icon"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(showHistoryView) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [UIColor whiteColor];
    [leftButton setTitle:@"fanhui" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //title
    self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setTitle:_titleArr[0] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleButton addTarget:self action:@selector(showTheList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleButton;
    
    //right
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 17, 20, 20)];
//    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setImage:[UIImage imageNamed:@"all_set_icon"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.backGroundView.backgroundColor = [UIColor whiteColor];
//    [self hiddenFunctionView];
    
    self.pageControl.tintColor = [UIColor clearColor];
    
    self.menuView.backgroundColor = [UIColor blueColor];
}

- (NSMutableArray *)getWeekBeginAndEnd:(NSDate *)newDate
{
    //获取当前周的开始和结束日期
    int currentWeek = 0;
    NSTimeInterval appendDay = 24 * 60 * 60;
    NSTimeInterval secondsPerDay1 = 24 * 60 * 60 * (abs(currentWeek)*7);
    if (currentWeek > 0)
    {
        newDate = [newDate dateByAddingTimeInterval:+secondsPerDay1];//目标时间
    }else{
        newDate = [newDate dateByAddingTimeInterval:-secondsPerDay1];//目标时间
    }
    
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval - 1];
    }else {
        //        break;
    }
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    NSArray *dateArr = @[[myDateFormatter stringFromDate:beginDate],[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+appendDay]],[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 2]],[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 3]],[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 4]],[myDateFormatter stringFromDate:[beginDate dateByAddingTimeInterval:+ appendDay * 5]],[myDateFormatter stringFromDate:endDate]];
    
    return [NSMutableArray arrayWithArray:dateArr];
    
}

#pragma mark - BleReceiveDelegate
//不同数据类型的回调
//set time
- (void)receiveSetTimeDataWithModel:(manridyModel *)manridyModel
{
    
}

//motion data
- (void)receiveMotionDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSportModel) {
            //保存motion数据到数据库
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy/MM/dd"];
            NSDate *currentDate = [NSDate date];
            NSString *currentDateString = [dateformatter stringFromDate:currentDate];
            
            switch (manridyModel.sportModel.motionType) {
                case MotionTypeStep:
                    //对获取的步数信息做操作
                    break;
                case MotionTypeStepAndkCal:
                {
                    [self.stepView.stepLabel setText:manridyModel.sportModel.stepNumber];
                    [self.stepView.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%@米/%@卡",manridyModel.sportModel.mileageNumber ,manridyModel.sportModel.kCalNumber]];
                    
                    if (_userArr.count != 0) {
                        
                        UserInfoModel *model = _userArr.firstObject;
                        
                        if (model.stepTarget != 0) {
                            float progress = (float)manridyModel.sportModel.stepNumber.integerValue / model.stepTarget;
                            
                            if (progress <= 1) {
                                [self.stepView drawProgress:progress];
                            }else if (progress >= 1) {
                                [self.stepView drawProgress:1];
                            }
                        }
                    }else {
                        //如果用户没有设置目标步数的话，就默认为10000步
                        float progress = (float)manridyModel.sportModel.stepNumber.integerValue / 10000;
                        
                        if (progress <= 1) {
                            [self.stepView drawProgress:progress];
                        }else if (progress >= 1) {
                            [self.stepView drawProgress:1];
                        }
                    }
                    
                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSArray *stepArr = [self.myFmdbTool queryStepWithDate:currentDateString];
                        
                        if (stepArr.count == 0) {
                            [self.myFmdbTool insertStepModel:manridyModel.sportModel];
                            
                        }else {
                            [self.myFmdbTool modifyStepWithDate:currentDateString model:manridyModel.sportModel];
                        }
                    });
                }
                    break;
                case MotionTypeCountOfData:
                    //对历史数据个数进行操作
                    break;
                case MotionTypeDataInPeripheral:
                {
                    if (manridyModel.sportModel.sumDataCount != 0 && manridyModel.sportModel.sumDataCount) {
                        //对具体的历史数据进行保存操作
                        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSArray *stepArr = [self.myFmdbTool queryStepWithDate:currentDateString];
                            
                            if (stepArr.count == 0) {
                                [self.myFmdbTool insertStepModel:manridyModel.sportModel];
                            }else {
                                [self.myFmdbTool modifyStepWithDate:currentDateString model:manridyModel.sportModel];
                            }
                            
                            if (manridyModel.sportModel.sumDataCount == manridyModel.sportModel.currentDataCount + 1) {
                                [self.myBleTool writeMotionRequestToPeripheralWithMotionType:MotionTypeStepAndkCal];
                            }
                            
                        });
                    }else {
                        [self.myBleTool writeMotionRequestToPeripheralWithMotionType:MotionTypeStepAndkCal];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            
        }
    }
}

//motion zero
- (void)receiveSetMotionZeroWithModel:(manridyModel *)manridyModel
{
    
}

//set heart rate test state
//- (void)receiveHeartRateTestWithModel:(manridyModel *)manridyModel
//{
//    
//}

//get heart rate data
- (void)receiveHeartRateDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeHeartRateModel) {
            
            NSMutableString *mutableTime = [NSMutableString stringWithString:manridyModel.heartRateModel.time];
            [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
            NSLog(@"数据类型 == %lu",manridyModel.heartRateModel.heartRateState);
            if (manridyModel.heartRateModel.heartRateState == HeartRateDataHistoryData) {
                //当总数据为00时说明没有数据，可以不用存储
                if (![manridyModel.heartRateModel.sumDataCount isEqualToString:@"0"] && manridyModel.heartRateModel.sumDataCount != nil) {
                    
                    //如果当前数据为最后一条数据时，在屏幕上显示，其他的数据全部存储到数据库即可
                    [self.heartRateView.heartRateLabel setText:manridyModel.heartRateModel.heartRate];
                    
                    [self.myFmdbTool insertHeartRateModel:manridyModel.heartRateModel];
                }
                NSArray *heartRateArr = [self.myFmdbTool queryHeartRateWithDate:nil];
                
                if (heartRateArr.count >= 7) {
                    for (NSInteger index = heartRateArr.count - 7; index < heartRateArr.count; index ++) {
                        HeartRateModel *model = heartRateArr[index];
                        NSMutableString *mutableTime = [NSMutableString stringWithString:model.time];
                        [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
                        [self.heartRateView.dateArr addObject:mutableTime];
                        [self.heartRateView.dataArr addObject:model.heartRate];
                    }
                }else if (heartRateArr.count < 7) {
                    for (NSInteger index = 0; index < heartRateArr.count; index ++) {
                        HeartRateModel *model = heartRateArr[index];
                        
                        NSMutableString *mutableTime = [NSMutableString stringWithString:model.time];
                        [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
                        [self.heartRateView.dateArr addObject:mutableTime];
                        [self.heartRateView.dataArr addObject:model.heartRate];
                    }
                }else if (heartRateArr.count == 0) {
                    
                    for (NSString *dateString in self.stepView.dateArr) {
                        NSString *monthStr = [dateString substringWithRange:NSMakeRange(5, 2)];
                        NSString *dayStr = [dateString substringWithRange:NSMakeRange(8, 2)];
                        
                        [self.heartRateView.dateArr addObject:[NSString stringWithFormat:@"%@/%@",monthStr ,dayStr]];
                    }
                    
                    for (int i = 0; i < 7; i ++) {
                        [self.heartRateView.dataArr addObject:@"0"];
                    }
                }
            }else if (manridyModel.heartRateModel.heartRateState == HeartRateDataLastData) {
                if (self.heartRateView.dataArr.count == 7) {
                    //先移除掉前面的第一个数据
                    [self.heartRateView.dataArr removeObjectAtIndex:0];
                    [self.heartRateView.dateArr removeObjectAtIndex:0];
                    //再讲推送的数据添加到最后一个
                    
                    [self.heartRateView.dateArr addObject:mutableTime];
                    [self.heartRateView.dataArr addObject:manridyModel.heartRateModel.heartRate];
                }else if (self.heartRateView.dataArr.count < 7) {
                    [self.heartRateView.dateArr addObject:mutableTime];
                    [self.heartRateView.dataArr addObject:manridyModel.heartRateModel.heartRate];
                }
            }
            NSString *lastHeartRate = self.heartRateView.dataArr.lastObject;
                [self.heartRateView.heartRateLabel setText:lastHeartRate];
                
                NSInteger heart = lastHeartRate.integerValue;
                
                if (heart < 60) {
                    self.heartRateView.state1.backgroundColor = [UIColor redColor];
                    self.heartRateView.state2.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state3.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state4.backgroundColor = kCurrentStateOFF;
                    
                    self.heartRateView.heartStateLabel.text = @"偏低";
                }else if (heart >= 60 && heart <= 100) {
                    self.heartRateView.state1.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state2.backgroundColor = [UIColor greenColor];
                    self.heartRateView.state3.backgroundColor = [UIColor greenColor];
                    self.heartRateView.state4.backgroundColor = kCurrentStateOFF;
                    
                    self.heartRateView.heartStateLabel.text = @"正常";
                }else {
                    self.heartRateView.state1.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state2.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state3.backgroundColor = kCurrentStateOFF;
                    self.heartRateView.state4.backgroundColor = [UIColor redColor];
                    
                    self.heartRateView.heartStateLabel.text = @"偏高";
                }
            [self.heartRateView showChartView];
        }
    }
}

//get sleepInfo
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSleepModel) {
            
            //如果历史数据，插入数据库
            if (manridyModel.sleepModel.sleepState == SleepDataHistoryData) {
                NSDate *currentDate = [NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy/MM/dd";
                NSString *currentDateString = [formatter stringFromDate:currentDate];
                
                //如果历史数据总数不为空
                if (manridyModel.sleepModel.sumDataCount) {
                    
                    //插入历史睡眠数据，如果sumCount为0的话，就不做保存
                    [self.myFmdbTool insertSleepModel:manridyModel.sleepModel];
                    
                    //如果历史数据全部载入完成，写入当前睡眠数据
                    if (manridyModel.sleepModel.currentDataCount + 1 == manridyModel.sleepModel.sumDataCount) {
                        
                        [self querySleepDataBaseWithDateString:currentDateString];
                    }
                }else {
                    //这里不查询历史，直接查询数据库展示即可
                    [self querySleepDataBaseWithDateString:currentDateString];
                }
            }
#if 0
            else {
                NSString *deepStr;
                
                if (manridyModel.sleepModel.deepSleep.integerValue < 60) {
                    deepStr = [NSString stringWithFormat:@"深睡%@分钟",manridyModel.sleepModel.deepSleep];
                }else {
                    deepStr = [NSString stringWithFormat:@"深睡%.2ld小时",manridyModel.sleepModel.deepSleep.integerValue / 60 + manridyModel.sleepModel.deepSleep.integerValue % 60];
                }
                
                NSString *lowStr;
                
#warning need to test the lastSleepData endTime
                //查询当前睡眠时，会给最近一次的历史数据，而这个历史数据不会在上面的历史数据请求里请求到，所以这里如果endTime有值得话，就需要进行存储。
                if ([manridyModel.sleepModel.endTime isEqualToString:@"2000/00/00"]) {
                    [self.myFmdbTool insertSleepModel:manridyModel.sleepModel];
                }
                
                if (manridyModel.sleepModel.lowSleep.integerValue < 60) {
                    lowStr = [NSString stringWithFormat:@"浅睡%@分钟",manridyModel.sleepModel.lowSleep];
                }else {
                    lowStr = [NSString stringWithFormat:@"浅睡%.2ld小时",manridyModel.sleepModel.lowSleep.integerValue / 60 + manridyModel.sleepModel.lowSleep.integerValue % 60];
                }
                
                self.sleepView.sleepSumLabel.text = manridyModel.sleepModel.sumSleep;
                self.sleepView.deepAndLowSleepLabel.text = [NSString stringWithFormat:@"%@/%@",deepStr,lowStr];
                
                [self.hud hideAnimated:YES];
                
                //当前的数据传过来，就直接进行添加到数据源中进行图表的绘制
                [self.sleepView.sumDataArr addObject:@(manridyModel.sleepModel.sumSleep.integerValue)];
                [self.sleepView.deepDataArr addObject:@(manridyModel.sleepModel.deepSleep.integerValue)];
                
                [self.sleepView showChartView];
                
                
                
                [self.sleepView.sumDataArr removeAllObjects];
                [self.sleepView.deepDataArr removeAllObjects];
            }
#endif
        }
    }
}

#pragma mark - DataBase
- (void)querySleepDataBaseWithDateString:(NSString *)currentDateString
{
    //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
    NSArray *sleepDataArr = [self.myFmdbTool querySleepWithDate:currentDateString];
    
    for (SleepModel *model in sleepDataArr) {
        [self.sleepView.sumDataArr addObject:@(model.sumSleep.integerValue)];
        [self.sleepView.deepDataArr addObject:@(model.deepSleep.integerValue)];
    }
    if (sleepDataArr.count == 0) {
        [self.sleepView showChartViewWithData:NO];
    }else {
        [self.sleepView showChartViewWithData:YES];
        SleepModel *model = sleepDataArr.lastObject;
        
        double deep = model.deepSleep.doubleValue / 60;
        double low = model.lowSleep.doubleValue / 60;
        double sum = model.sumSleep.doubleValue / 60;
        
        NSLog(@"dep == %0.2f, low == %.2f, sum == %.2f",deep ,low ,sum);
        
        NSString * lowStr = [NSString stringWithFormat:@"浅睡%0.2f小时",low];
        NSString * deepStr = [NSString stringWithFormat:@"深睡%.2f小时",deep];
        [self.sleepView.sleepSumLabel setText:[NSString stringWithFormat:@"%.2f",sum]];
        [self.sleepView.deepAndLowSleepLabel setText:[NSString stringWithFormat:@"%@/%@",deepStr ,lowStr]];
        
        if (sum <= 6) {
            [self.sleepView.sleepStateLabel setText:@"睡眠不足"];
            [self.sleepView.sleepStateLabel setTextColor:[UIColor redColor]];
            
            [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor redColor]];
            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
            
        }else if (sum > 6 && sum < 7) {
            [self.sleepView.sleepStateLabel setText:@"睡眠偏少"];
            [self.sleepView.sleepStateLabel setTextColor:[UIColor orangeColor]];
            
            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor orangeColor]];
            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
            
        }else if (sum >= 7 && sum < 8) {
            [self.sleepView.sleepStateLabel setText:@"睡眠正常"];
            [self.sleepView.sleepStateLabel setTextColor:[UIColor yellowColor]];
            
            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor yellowColor]];
            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
            
        }else if (sum >= 8) {
            [self.sleepView.sleepStateLabel setText:@"睡眠充足"];
            [self.sleepView.sleepStateLabel setTextColor:[UIColor greenColor]];
            
            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
            [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor greenColor]];
            
        }
    }
    [self.sleepView.sumDataArr removeAllObjects];
    [self.sleepView.deepDataArr removeAllObjects];
}


#pragma mark - Action
- (void)showHistoryView
{
    int currentPage = floor((self.backGroundView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1;
    switch (currentPage) {
        case 0:
        {
            StepHistoryViewController *vc = [[StepHistoryViewController alloc] initWithNibName:@"StepHistoryViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            HeartRateHistoryViewController *vc = [[HeartRateHistoryViewController alloc] initWithNibName:@"HeartRateHistoryViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            SleepHistoryViewController *vc = [[SleepHistoryViewController alloc] initWithNibName:@"SleepHistoryViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)oneFingerSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    int currentPage = floor((self.backGroundView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1;
    switch (currentPage) {
        case 0:
        {
            StepHistoryViewController *vc = [[StepHistoryViewController alloc] initWithNibName:@"StepHistoryViewController" bundle:nil];
            //  添加动作
            [self presentViewController: vc animated:YES completion:nil];
        }
            break;
        case 1:
        {
            HeartRateHistoryViewController *vc = [[HeartRateHistoryViewController alloc] initWithNibName:@"HeartRateHistoryViewController" bundle:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 2:
        {
            //体温
        }
            break;
        case 3:
        {
            SleepHistoryViewController *vc = [[SleepHistoryViewController alloc] initWithNibName:@"SleepHistoryViewController" bundle:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 4:
        {
            //血压
        }
            break;
            
        default:
            break;
    }
    
    
}

- (void)showSettingView
{
    SettingViewController *vc = [[SettingViewController alloc] init];
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"all_back_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showTheList
{
    if (!isShowList) {
        [UIView animateWithDuration:0.5 animations:^{
            self.menuView.frame = CGRectMake(30, 100, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
            isShowList = YES;
            
            self.backGroundView.scrollEnabled = NO;
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            self.menuView.frame = CGRectMake(30, - (self.view.frame.size.width - 60) - 50, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
            isShowList = NO;
            
            self.backGroundView.scrollEnabled = YES;
        }];
    }
    
}

- (void)touchesScrollViewAction
{
    if (isShowList) {
        [UIView animateWithDuration:0.5 animations:^{
            self.menuView.frame = CGRectMake(30, - (self.view.frame.size.width - 60) - 50, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
            isShowList = NO;
        }];
    }
}

#pragma mark - UIScrollViewDelegate
// 开始减速的时候开始self.didEndDecelerating = NO;结束减速就会置为YES,如果滑动很快就还是NO。
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.didEndDecelerating = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.didEndDecelerating = YES;
    // 调用方法A，传scrollView.contentOffset
    
    CGFloat index = scrollView.contentOffset.x/WIDTH;
    //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
    
    int i = roundf(index);
    
    [self.titleButton setTitle:_titleArr[i] forState:UIControlStateNormal];
    self.pageControl.currentPage = i;
    
    if (_currentPage != self.pageControl.currentPage) {
        switch (self.pageControl.currentPage) {
            case 0:
            {
                _currentPage = 0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.pageControl.currentPage == 0) {
                        [self.myBleTool writeMotionRequestToPeripheralWithMotionType:MotionTypeStepAndkCal];
                    }
                });
            }
                break;
            case 1:
            {
                _currentPage = 1;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                    if (self.pageControl.currentPage == 1) {
                        [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
                        [self.heartRateView.dateArr removeAllObjects];
                        [self.heartRateView.dataArr removeAllObjects];
                    }
                });
            }
                break;
            case 2:
            {
                _currentPage = 2;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.pageControl.currentPage == 2) {
                        //读取当前体温
                    }
                });
            }
                break;
            case 3:
            {
                _currentPage = 3;
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    [self.myBleTool writeSleepRequestToperipheral:SleepDataHistoryData];
                }else {
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy/MM/dd";
                    NSString *currentDateString = [formatter stringFromDate:currentDate];
                    [self querySleepDataBaseWithDateString:currentDateString];
                }
            }
                break;
            case 4:
            {
                _currentPage = 4;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.pageControl.currentPage == 4) {
                        //读取血压数据
                    }
                });
            }
                break;
                
            default:
                break;
        }
    }
}

// 再次拖拽的时候，判断有没有因为滑动太快而没有调用结束减速的方法。
// 如果没有，四舍五入手动确定位置。这样就可以解决滑动过快的问题
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!self.didEndDecelerating) {
        // 先计算当期的page/index
        CGFloat index = scrollView.contentOffset.x/WIDTH;
        //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
        
        int i = roundf(index);
        
        [self.titleButton setTitle:_titleArr[i] forState:UIControlStateNormal];
        self.pageControl.currentPage = i;
    }
}

#pragma mark - 懒加载
- (UIScrollView *)backGroundView
{
    if (!_backGroundView) {
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -64, WIDTH, HEIGHT + 64)];
        view.showsVerticalScrollIndicator = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesScrollViewAction)];
        [view addGestureRecognizer:tap];
        
        view.contentSize = CGSizeMake(5 * WIDTH, 0);
        view.pagingEnabled = YES;
        view.delegate = self;
        view.bounces = NO;
        
        self.stepView = [[StepContentView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [view addSubview:self.stepView];
        
        self.heartRateView = [[HeartRateContentView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.heartRateView];
        
        self.temperatureView = [[TemperatureContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.temperatureView];
        
        self.sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake(3 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.sleepView];
        
        self.bloodPressureView = [[BloodPressureContentView alloc] initWithFrame:CGRectMake(4 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.bloodPressureView];
        
        [self.view addSubview:view];
        _backGroundView = view;
    }

    return _backGroundView;
}

- (MenuContentView *)menuView
{
    if (!_menuView) {
        MenuContentView *view = [[MenuContentView alloc] initWithFrame:CGRectMake(30, - (self.view.frame.size.width - 60) - 50, self.view.frame.size.width - 60, self.view.frame.size.width - 60)];
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = true;
        
        view.goToTargetViewBlcok = ^(NSInteger row) {
            [self.backGroundView setContentOffset:CGPointMake(row * WIDTH, -64) animated:YES];
            
            //修改title和pagecontrol
            [self.titleButton setTitle:_titleArr[row] forState:UIControlStateNormal];
            self.pageControl.currentPage = row;
            
            //修改menuView的frame
            [UIView animateWithDuration:0.5 animations:^{
                self.menuView.frame = CGRectMake(30, - (self.view.frame.size.width - 60) - 50, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
                
                self.backGroundView.scrollEnabled = YES;
                isShowList = NO;
            }];
        };
        
        [self.view addSubview:view];
        _menuView = view;
    }
    
    return _menuView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *view = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 338, self.view.frame.size.width, 37)];
        view.numberOfPages = 5;
        view.currentPage = 0;
        view.enabled = NO;
        
        [self.view addSubview:view];
        _pageControl = view;
    }
    
    return _pageControl;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
        
    }
    
    return _myFmdbTool;
}

@end
