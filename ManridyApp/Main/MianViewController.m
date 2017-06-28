//
//  StepViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MainViewController.h"
#import "MenuContentView.h"
#import "BLETool.h"
#import "FMDBTool.h"
#import "StepDataModel.h"
#import "StepHistoryViewController.h"
#import "HeartRateHistoryViewController.h"
#import "SleepHistoryViewController.h"
#import "MBProgressHUD.h"
#import "Remind.h"
#import "NSStringTool.h"
#import "BooldHistoryViewController.h"
#import "BOHistoryViewController.h"
#import "NSStringTool.h"
#import "UnitsTool.h"

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
    
    _titleArr = @[NSLocalizedString(@"Step", nil),NSLocalizedString(@"HeartHeart", nil),NSLocalizedString(@"Sleep", nil),NSLocalizedString(@"BloodPressure", nil),NSLocalizedString(@"BloodO2", nil)];
    self.haveNewStep = YES;
    self.haveNewHeartRate = YES;
    self.haveNewSleep = YES;
    self.haveNewBP = YES;
    self.haveNewBO = YES;
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    [self createUI];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.stepView.dateArr = [self getWeekBeginAndEnd:[NSDate date]];
    
    [self hiddenFunctionView];
    _currentPage = 0;
    
    Remind *model = [[Remind alloc] init];
    model.phone = 1;
    model.message = 1;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(writeSleepTest:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)writeSleepTest:(UILongPressGestureRecognizer *)ges
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.myBleTool writeSleepTest];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    @autoreleasepool {
        self.myBleTool = [BLETool shareInstance];
        self.myBleTool.receiveDelegate = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _userArr = [self.myFmdbTool queryAllUserInfo];
        });
        
        self.oneFingerSwipeUp =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeUp:)];
        [self.oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.view addGestureRecognizer:self.oneFingerSwipeUp];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSMutableArray *dataArr = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *dateString in self.stepView.dateArr) {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stepView showChartView];
        [self.stepView showStepStateLabel];
        [self.heartRateView showHRStateLabel];
    });
    });

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    DLog(@"会走这方法");
    [self.view removeGestureRecognizer:self.oneFingerSwipeUp];
}

- (void)dealloc
{
    [self.myFmdbTool CloseDataBase];
}

- (void)showFunctionView
{
    self.stepView.mileageAndkCalLabel.hidden = NO;
    self.stepView.todayLabel.hidden = NO;
    
    self.stepView.stepLabel.userInteractionEnabled = NO;
    
    [self.stepView.stepLabel setText:@"0"];
    [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:50]];
}

- (void)hiddenFunctionView
{
    @autoreleasepool {
    int currentPage = floor((self.backGroundView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1;
    
    if (currentPage != 0) {
        
        [self.backGroundView setContentOffset:CGPointMake(0 * WIDTH, -64) animated:YES];
        [self.titleButton setTitle:_titleArr[0] forState:UIControlStateNormal];
        self.pageControl.currentPage = 0;
    }
    
    //为了方便测试，可以将滚动调为YES
    self.stepView.mileageAndkCalLabel.hidden = YES;
    self.stepView.todayLabel.hidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"]) {
        BOOL isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
        
        if (isBind) {
            [self.stepView.stepLabel setText:NSLocalizedString(@"perConnecting", nil)];
            [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:15]];
        }else {
            [self.stepView.stepLabel setText:NSLocalizedString(@"haveNOBindPer", nil)];
            [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:11]];
        }
    }else {
        [self.stepView.stepLabel setText:NSLocalizedString(@"haveNOBindPer", nil)];
        [self.stepView.stepLabel setFont:[UIFont systemFontOfSize:11]];
    }
    }
}

- (void)writeData
{
    @autoreleasepool {
        [self.myBleTool writeRequestVersion];
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
}

- (void)createUI
{
    @autoreleasepool {
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
        self.titleButton.frame = CGRectMake(0, 0, 250, 44);
    [self.titleButton setTitle:_titleArr[0] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.titleButton addTarget:self action:@selector(showTheList) forControlEvents:UIControlEventTouchUpInside];
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
}

- (NSMutableArray *)getWeekBeginAndEnd:(NSDate *)newDate
{
    @autoreleasepool {
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
// MARK: 这里修改了NSCalendarUnitWeekday
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginDate interval:&interval forDate:newDate];
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
    @autoreleasepool {
        if (manridyModel.isReciveDataRight) {
            if (manridyModel.receiveDataType == ReturnModelTypeSportModel) {
                //保存motion数据到数据库
                NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"yyyy/MM/dd"];
                NSDate *currentDate = [NSDate date];
                NSString *currentDateString = [dateformatter stringFromDate:currentDate];
                self.haveNewStep = YES;
                switch (manridyModel.sportModel.motionType) {
                    case MotionTypeStep:
                        //对获取的步数信息做操作
                        break;
                    case MotionTypeStepAndkCal:
                    {
                        [self.stepView.stepLabel setText:manridyModel.sportModel.stepNumber];
                        double mileage = manridyModel.sportModel.mileageNumber.integerValue / 1000.f;
                        [self.stepView.mileageAndkCalLabel setText:[UnitsTool isMetricOrImperialSystem] ? [NSString stringWithFormat:NSLocalizedString(@"currentStepAndKCal", nil),mileage ,manridyModel.sportModel.kCalNumber] : [NSString stringWithFormat:NSLocalizedString(@"currentStepAndKCalImperial", nil),[UnitsTool kmAndMi:mileage withMode:MetricToImperial], manridyModel.sportModel.kCalNumber] ];

                        if (_userArr.count != 0) {
                            
                            UserInfoModel *model = _userArr.firstObject;
                            
                            if (model.stepTarget != 0) {
                                float progress = (float)manridyModel.sportModel.stepNumber.integerValue / model.stepTarget;
                                
                                if (progress <= 1) {
                                    [self.stepView drawProgress:progress];
                                }else if (progress >= 1) {
                                    [self.stepView drawProgress:1];
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
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSArray *stepArr = [self.myFmdbTool queryStepWithDate:manridyModel.sportModel.date];
                                float height;float weight;
                                _userArr = [self.myFmdbTool queryAllUserInfo];
                                if (_userArr.count == 0) {
                                    weight = 75.0;
                                    height = 180.0;
                                }else {
                                    //这里由于是单用户，所以取第一个值
                                    UserInfoModel *model = _userArr.firstObject;
                                    weight = model.weight;
                                    height = model.height;
                                }
                                manridyModel.sportModel.kCalNumber = [NSString stringWithFormat:@"%f",[NSStringTool getKcal:manridyModel.sportModel.stepNumber.integerValue withHeight:height andWeitght:weight]];
                                manridyModel.sportModel.mileageNumber = [NSString stringWithFormat:@"%f",[NSStringTool getMileage:manridyModel.sportModel.stepNumber.integerValue withHeight:height]];
                                
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
    @autoreleasepool {
        if (manridyModel.isReciveDataRight) {
            if (manridyModel.receiveDataType == ReturnModelTypeHeartRateModel) {
                
                NSMutableString *mutableTime = [NSMutableString stringWithString:manridyModel.heartRateModel.time];
                [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
                
                if (manridyModel.heartRateModel.heartRateState == HeartRateDataHistoryData) {
                    //当总数据为00时说明没有数据，可以不用存储
                    if (manridyModel.heartRateModel.sumDataCount.integerValue) {
                        
                        //如果当前数据为最后一条数据时，在屏幕上显示，其他的数据全部存储到数据库即可
                        [self.heartRateView.heartRateLabel setText:manridyModel.heartRateModel.heartRate];
                        
                        [self.myFmdbTool insertHeartRateModel:manridyModel.heartRateModel];
                    }
                    [self queryHeartDataAndShow];
                    self.haveNewHeartRate = NO;
                }else if (manridyModel.heartRateModel.heartRateState == HeartRateDataLastData) {
                    [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
                    self.haveNewHeartRate = YES;
                }
            }
        }
    }
}

//get sleepInfo
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel
{
    @autoreleasepool {
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
                self.haveNewSleep = NO;
            }else {
                [self.myBleTool writeSleepRequestToperipheral:SleepDataHistoryData];
                self.haveNewSleep = YES;
            }
        }
    }
    }
}

- (void)receiveBloodDataWithModel:(manridyModel *)manridyModel
{
    @autoreleasepool {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
        NSString *currentDateString = [formatter stringFromDate:currentDate];
        
        if (manridyModel.isReciveDataRight) {
            if (manridyModel.receiveDataType == ReturnModelTypeBloodModel) {
                
                //如果历史数据，插入数据库
                if (manridyModel.bloodModel.bloodState == BloodDataHistoryData) {
                    
                    //如果历史数据总数不为空
                    if (manridyModel.bloodModel.sumCount.integerValue) {
                        
                        //插入历史睡眠数据，如果sumCount为0的话，就不做保存
                        [self.myFmdbTool insertBloodModel:manridyModel.bloodModel];
                        
                        //如果历史数据全部载入完成，写入当前睡眠数据
                        if (manridyModel.bloodModel.currentCount.integerValue + 1 == manridyModel.bloodModel.sumCount.integerValue) {
                            NSArray *bloodDataArr = [self.myFmdbTool queryBloodWithDate:currentDateString];
                            
                            [self.bloodPressureView queryBloodWithBloodArr:bloodDataArr];
                        }
                    }else {
                        //这里不查询历史，直接查询数据库展示即可
                        NSArray *bloodDataArr = [self.myFmdbTool queryBloodWithDate:currentDateString];
                        
                        [self.bloodPressureView queryBloodWithBloodArr:bloodDataArr];
                    }
                    self.haveNewBP = NO;
                }else {
                    [self.myBleTool writeBloodToPeripheral:BloodDataHistoryData];
                    self.haveNewBP = YES;
                }
            }
        }
    }
}

- (void)receiveBloodO2DataWithModel:(manridyModel *)manridyModel
{
    @autoreleasepool {
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/MM/dd";
        NSString *currentDateString = [formatter stringFromDate:currentDate];
        
        if (manridyModel.isReciveDataRight) {
            if (manridyModel.receiveDataType == ReturnModelTypeBloodO2Model) {
                
                //如果历史数据，插入数据库
                if (manridyModel.bloodO2Model.bloodO2State == BloodO2DataHistoryData) {
                    
                    //如果历史数据总数不为空
                    if (manridyModel.bloodO2Model.sumCount.integerValue) {
                        
                        //插入历史睡眠数据，如果sumCount为0的话，就不做保存
                        [self.myFmdbTool insertBloodO2Model:manridyModel.bloodO2Model];
                        
                        //如果历史数据全部载入完成，写入当前睡眠数据
                        if (manridyModel.bloodO2Model.currentCount.integerValue + 1 == manridyModel.bloodO2Model.sumCount.integerValue) {
                            NSArray *bloodDataArr = [self.myFmdbTool queryBloodO2WithDate:currentDateString];
                            
                            [self.boView queryBOWithBloodArr:bloodDataArr];
                        }
                    }else {
                        //这里不查询历史，直接查询数据库展示即可
                        NSArray *bloodDataArr = [self.myFmdbTool queryBloodO2WithDate:currentDateString];
                        
                        [self.boView queryBOWithBloodArr:bloodDataArr];
                    }
                    self.haveNewBO = NO;
                }else {
                    [self.myBleTool writeBloodO2ToPeripheral:BloodO2DataHistoryData];
                    self.haveNewBO = YES;
                }
            }
        }
    }
}

- (void)receiveVersionWithVersionStr:(NSString *)versionStr
{
    [[NSUserDefaults standardUserDefaults] setObject:versionStr forKey:@"version"];
}

#pragma mark - DataBase
- (void)querySleepDataBaseWithDateString:(NSString *)currentDateString
{
    @autoreleasepool {
    //当历史数据查完并存储到数据库后，查询数据库当天的睡眠数据，并加入数据源
    NSArray *sleepDataArr = [self.myFmdbTool querySleepWithDate:currentDateString];
        [self.sleepView.sumDataArr removeAllObjects];
        [self.sleepView.deepDataArr removeAllObjects];
    for (SleepModel *model in sleepDataArr) {
        [self.sleepView.sumDataArr addObject:@(model.sumSleep.integerValue)];
        [self.sleepView.deepDataArr addObject:@(model.deepSleep.integerValue)];
        [self.sleepView.startDataArr addObject:model.startTime];
        [self.sleepView.endDataArr addObject:model.endTime];
    }
    if (sleepDataArr.count == 0) {
        [self.sleepView showChartViewWithData:NO];
    }else {
        [self.sleepView showChartViewWithData:YES];
        double deep = 0;
        double low = 0;
        double sum = 0;
        
        for (SleepModel *model in sleepDataArr) {
            deep += model.deepSleep.doubleValue / 60;
            low += model.lowSleep.doubleValue / 60;
            sum += model.sumSleep.doubleValue / 60;
        }
        
        DLog(@"dep == %0.2f, low == %.2f, sum == %.2f",deep ,low ,sum);
        
        NSString * lowStr = [NSString stringWithFormat:NSLocalizedString(@"lowSleepData", nil),low];
        NSString * deepStr = [NSString stringWithFormat:NSLocalizedString(@"deepSleepData", nil),deep];
        [self.sleepView.sleepSumLabel setText:[NSString stringWithFormat:@"%.2f",sum]];
        [self.sleepView.deepAndLowSleepLabel setText:[NSString stringWithFormat:@"%@/%@",deepStr ,lowStr]];
        
        if (_userArr.count != 0) {
            
            UserInfoModel *model = _userArr.firstObject;
            
            if (model.sleepTarget != 0) {
                float progress = sum / model.sleepTarget;
                
                if (progress <= 1) {
                    [self.sleepView drawProgress:progress];
                }else if (progress >= 1) {
                    [self.sleepView drawProgress:1];
                }
            }else {
                //如果用户没有设置目标睡眠的话，就默认为8h
                float progress = sum / 8;
                
                if (progress <= 1) {
                    [self.sleepView drawProgress:progress];
                }else if (progress >= 1) {
                    [self.sleepView drawProgress:1];
                }
            }
        }else {
            //如果用户没有设置目标睡眠的话，就默认为8h
            float progress = sum / 8;
            
            if (progress <= 1) {
                [self.sleepView drawProgress:progress];
            }else if (progress >= 1) {
                [self.sleepView drawProgress:1];
            }
        }
        
//        if (sum <= 6) {
//            [self.sleepView.sleepStateLabel setText:NSLocalizedString(@"lackofSleep", nil)];
//            [self.sleepView.sleepStateLabel setTextColor:[UIColor redColor]];
//            
//            [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor redColor]];
//            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
//            
//        }else if (sum > 6 && sum < 7) {
//            [self.sleepView.sleepStateLabel setText:NSLocalizedString(@"lessofSleep", nil)];
//            [self.sleepView.sleepStateLabel setTextColor:[UIColor orangeColor]];
//            
//            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor orangeColor]];
//            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
//            
//        }else if (sum >= 7 && sum < 8) {
//            [self.sleepView.sleepStateLabel setText:NSLocalizedString(@"normalofSleep", nil)];
//            [self.sleepView.sleepStateLabel setTextColor:[UIColor yellowColor]];
//            
//            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor yellowColor]];
//            [self.sleepView.sleepStateView4 setBackgroundColor:kCurrentStateOFF];
//            
//        }else if (sum >= 8) {
//            [self.sleepView.sleepStateLabel setText:NSLocalizedString(@"moreofSleep", nil)];
//            [self.sleepView.sleepStateLabel setTextColor:[UIColor greenColor]];
//            
//            [self.sleepView.sleepStateView1 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView2 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView3 setBackgroundColor:kCurrentStateOFF];
//            [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor greenColor]];
//            
//        }
    }
    
    }
}

- (void)queryHeartDataAndShow
{
    @autoreleasepool {
    NSArray *heartRateArr = [self.myFmdbTool queryHeartRateWithDate:nil];
    
    [self.heartRateView.dateArr removeAllObjects];
    [self.heartRateView.dataArr removeAllObjects];
    
    if (heartRateArr.count >= 7) {
        for (NSInteger index = heartRateArr.count - 7; index < heartRateArr.count; index ++) {
            HeartRateModel *model = heartRateArr[index];
            NSMutableString *mutableTime = [NSMutableString stringWithString:model.time];
            [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
            [self.heartRateView.dateArr addObject:mutableTime];
            [self.heartRateView.dataArr addObject:model.heartRate];
        }
        [self.heartRateView showChartViewWithData:YES];
    }else if (heartRateArr.count < 7 && heartRateArr.count > 0) {
        for (NSInteger index = 0; index < heartRateArr.count; index ++) {
            HeartRateModel *model = heartRateArr[index];
            
            NSMutableString *mutableTime = [NSMutableString stringWithString:model.time];
            [mutableTime replaceOccurrencesOfString:@"-" withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, mutableTime.length)];
            [self.heartRateView.dateArr addObject:mutableTime];
            [self.heartRateView.dataArr addObject:model.heartRate];
        }
        [self.heartRateView showChartViewWithData:YES];
    }else if (heartRateArr.count == 0) {
        [self.heartRateView showChartViewWithData:NO];
    }
    NSString *lastHeartRate = self.heartRateView.dataArr.lastObject;
        if (lastHeartRate) {
            [self.heartRateView.heartRateLabel setText:lastHeartRate];
        }else {
            [self.heartRateView.heartRateLabel setText:@"0"];
        }
    
    
    NSInteger heart = lastHeartRate.integerValue;
    double doubleHeart = lastHeartRate.doubleValue;
    [self.heartRateView drawProgress:doubleHeart];
    
//    if (heart < 60) {
//        self.heartRateView.state1.backgroundColor = [UIColor redColor];
//        self.heartRateView.state2.backgroundColor = kCurrentStateOFF;
//        self.heartRateView.state4.backgroundColor = kCurrentStateOFF;
//        
//        self.heartRateView.heartStateLabel.text = NSLocalizedString(@"low", nil);
//    }else if (heart >= 60 && heart <= 100) {
//        self.heartRateView.state1.backgroundColor = kCurrentStateOFF;
//        self.heartRateView.state2.backgroundColor = [UIColor greenColor];
//        self.heartRateView.state4.backgroundColor = kCurrentStateOFF;
//        
//        self.heartRateView.heartStateLabel.text = NSLocalizedString(@"normal", nil);
//    }else {
//        self.heartRateView.state1.backgroundColor = kCurrentStateOFF;
//        self.heartRateView.state2.backgroundColor = kCurrentStateOFF;
//        self.heartRateView.state4.backgroundColor = [UIColor redColor];
//        
//        self.heartRateView.heartStateLabel.text = NSLocalizedString(@"high", nil);
//    }
    }
}


#pragma mark - Action
- (void)showHistoryView
{
    @autoreleasepool {
    int currentPage = floor((self.backGroundView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1;
    switch (currentPage) {
        case 0:
        {
            StepHistoryViewController *vc = [[StepHistoryViewController alloc] initWithNibName:@"StepHistoryViewController" bundle:nil];
            [self presentViewController: vc animated:YES completion:nil];
        }
            break;
        case 1:
        {
            HeartRateHistoryViewController *vc = [[HeartRateHistoryViewController alloc] initWithNibName:@"HeartRateHistoryViewController" bundle:nil];
            [self presentViewController: vc animated:YES completion:nil];
        }
            break;
        case 2:
        {
            SleepHistoryViewController *vc = [[SleepHistoryViewController alloc] initWithNibName:@"SleepHistoryViewController" bundle:nil];
            [self presentViewController: vc animated:YES completion:nil];
        }
            break;
        case 3:
        {
            BooldHistoryViewController *vc = [[BooldHistoryViewController alloc] initWithNibName:@"BooldHistoryViewController" bundle:nil];
            [self presentViewController: vc animated:YES completion:nil];
        }
            break;
        case 4
        :
        {
            BOHistoryViewController *vc = [[BOHistoryViewController alloc] initWithNibName:@"BOHistoryViewController" bundle:nil];
            [self presentViewController: vc animated:YES completion:nil];
        }
            
        default:
            break;
    }
    }
}

- (void)oneFingerSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    @autoreleasepool {
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
            SleepHistoryViewController *vc = [[SleepHistoryViewController alloc] initWithNibName:@"SleepHistoryViewController" bundle:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 3:
        {
            BooldHistoryViewController *vc = [[BooldHistoryViewController alloc] initWithNibName:@"BooldHistoryViewController" bundle:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 4:
        {
            //血氧
            BOHistoryViewController *vc = [[BOHistoryViewController alloc] initWithNibName:@"BOHistoryViewController" bundle:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
    }
}

- (void)showSettingView
{
    SettingViewController *vc = [[SettingViewController alloc] init];
    

    
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
#if 0
    if (isShowList) {
        [UIView animateWithDuration:0.5 animations:^{
            self.menuView.frame = CGRectMake(30, - (self.view.frame.size.width - 60) - 50, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
            isShowList = NO;
        }];
    }
#endif
}

#pragma mark - UIScrollViewDelegate
// 开始减速的时候开始self.didEndDecelerating = NO;结束减速就会置为YES,如果滑动很快就还是NO。
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    self.didEndDecelerating = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    @autoreleasepool {
    self.didEndDecelerating = YES;
    CGFloat index = scrollView.contentOffset.x/WIDTH;
    //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
    
    int i = roundf(index);
    
    [self.titleButton setTitle:_titleArr[i] forState:UIControlStateNormal];
    self.pageControl.currentPage = i;
    
        switch (self.pageControl.currentPage) {
            case 0:
            {
                if (self.haveNewStep) {
                    self.haveNewStep = NO;
                    [self.stepView showStepStateLabel];
                }
            }
                break;
            case 1:
            {
                if (self.myBleTool.connectState == kBLEstateDidConnected ) {
                    if (self.haveNewHeartRate) {
                        [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataHistoryData];
                        [self.heartRateView showHRStateLabel];
                    }
                }else {
                    if (self.haveNewHeartRate) {
                        [self queryHeartDataAndShow];
                        self.haveNewHeartRate = NO;
                        [self.heartRateView showHRStateLabel];
                    }
                }
            }
                break;
            case 2:
            {
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    if (self.haveNewSleep) {
                        [self.myBleTool writeSleepRequestToperipheral:SleepDataHistoryData];
                        self.sleepView.currentSleepStateLabel.text = NSLocalizedString(@"lastTimeSleep", nil);
                    }
                }else {
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy/MM/dd";
                    NSString *currentDateString = [formatter stringFromDate:currentDate];
                    if (self.haveNewSleep) {
                        [self querySleepDataBaseWithDateString:currentDateString];
                        self.haveNewSleep = NO;
                        self.sleepView.currentSleepStateLabel.text = NSLocalizedString(@"lastTimeSleep", nil);
                    }
                }
            }
                break;
            case 3:
            {
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    if (self.haveNewBP) {
                        [self.myBleTool writeBloodToPeripheral:BloodDataHistoryData];
                        self.bloodPressureView.currentBPLabel.text = NSLocalizedString(@"todayBP", nil);
                    }
                }else {
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy/MM/dd";
                    NSString *currentDateString = [formatter stringFromDate:currentDate];
                    
                    if (self.haveNewBP) {
                        NSArray *bloodArr = [self.myFmdbTool queryBloodWithDate:currentDateString];
                        [self.bloodPressureView queryBloodWithBloodArr:bloodArr];
                        self.haveNewBP = NO;
                        self.bloodPressureView.currentBPLabel.text = NSLocalizedString(@"todayBP", nil);
                    }
                }
            }
                break;
            case 4:
            {
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    if (self.haveNewBO) {
                        [self.myBleTool writeBloodO2ToPeripheral:BloodO2DataHistoryData];
                        self.boView.currentBOLabel.text = NSLocalizedString(@"todayBO", nil);
                    }
                }else {
                    NSDate *currentDate = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy/MM/dd";
                    NSString *currentDateString = [formatter stringFromDate:currentDate];
                    if (self.haveNewBO) {
                        NSArray *bloodArr = [self.myFmdbTool queryBloodO2WithDate:currentDateString];
                        [self.boView queryBOWithBloodArr:bloodArr];
                        self.haveNewBO = NO;
                        self.boView.currentBOLabel.text = NSLocalizedString(@"todayBO", nil);
                    }
                }
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
        
//        self.temperatureView = [[TemperatureContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
//        [view addSubview:self.temperatureView];
        
        self.sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.sleepView];
        
        self.bloodPressureView = [[BloodPressureContentView alloc] initWithFrame:CGRectMake(3 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.bloodPressureView];
        
        self.boView = [[BloodO2ContentView alloc] initWithFrame:CGRectMake(4 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:self.boView];
        
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
        UIPageControl *view = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 274, self.view.frame.size.width, 37)];
        view.pageIndicatorTintColor = COLOR_WITH_HEX(0x1e88e5, 0.54);
        view.currentPageIndicatorTintColor =COLOR_WITH_HEX(0x1e88e5, 0.87);
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
