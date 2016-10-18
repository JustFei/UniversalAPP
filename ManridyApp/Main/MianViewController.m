//
//  StepViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MainViewController.h"
#import "StepContentView.h"
#import "HeartRateContentView.h"
#import "TemperatureContentView.h"
#import "SleepContentView.h"
#import "BloodPressureContentView.h"
#import "MenuContentView.h"
#import "BLETool.h"
#import "FMDBTool.h"
#import "StepDataModel.h"

#import "SettingViewController.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface MainViewController () <UIScrollViewDelegate ,BleReceiveDelegate>
{
    NSArray *_titleArr;
    
    BOOL isShowList;
    NSArray *_userArr;
}
@property (nonatomic ,weak) UIScrollView *backGroundView;

@property (nonatomic ,weak) UIPageControl *pageControl;

@property (nonatomic ,assign) BOOL didEndDecelerating;

@property (nonatomic ,weak) MenuContentView *menuView;

@property (nonatomic ,strong) UIButton *titleButton;

//@property (nonatomic ,strong) UIButton *leftButton;

@property (nonatomic ,strong) UIButton *rightButton;

@property (nonatomic ,strong) StepContentView *stepView;

@property (nonatomic ,strong) HeartRateContentView *heartRateView;

@property (nonatomic ,strong) TemperatureContentView *temperatureView;

@property (nonatomic ,strong) SleepContentView *sleepView;

@property (nonatomic ,strong) BloodPressureContentView  *bloodPressureView;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@end

@implementation MainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleArr = @[@"计步",@"心率",@"体温",@"睡眠",@"血压"];
    
    
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.receiveDelegate = self;
    
    _userArr = [self.myFmdbTool queryAllUserInfo];
    
}

- (void)writeData
{
    switch (self.pageControl.currentPage) {
        case 0:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 0) {
                    [self.myBleTool writeMotionRequestToPeripheral];
                }
            });
        }
            break;
        case 1:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 1) {
                    [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataLastData];
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
//    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 17, 20, 20)];
//    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftButton setImage:[UIImage imageNamed:@"all_data_icon"] forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(showHistoryView) forControlEvents:UIControlEventTouchUpInside];
//    leftButton.backgroundColor = [UIColor whiteColor];
//    [leftButton setTitle:@"fanhui" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"all_data_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showHistoryView)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //title
    self.titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setTitle:_titleArr[0] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleButton addTarget:self action:@selector(showTheList) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleButton;
    
    //right
//    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 17, 20, 20)];
//    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.rightButton setImage:[UIImage imageNamed:@"all_set_icon"] forState:UIControlStateNormal];
//    [self.rightButton addTarget:self action:@selector(showSettingView) forControlEvents:UIControlEventTouchUpInside];
//    self.rightButton.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"all_set_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingView)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    
    self.pageControl.tintColor = [UIColor clearColor];
    
    self.menuView.backgroundColor = [UIColor blueColor];
    

    
    
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
            [self.stepView.stepLabel setText:manridyModel.sportModel.stepNumber];
            [self.stepView.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%@公里/%@千卡",manridyModel.sportModel.mileageNumber ,manridyModel.sportModel.kCalNumber]];
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSArray *userArr = [self.myFmdbTool queryAllUserInfo];
                if (_userArr.count != 0) {
                    
                    UserInfoModel *model = _userArr.firstObject;
                    
                    if (model.stepTarget != 0) {
                        float progress = (float)manridyModel.sportModel.stepNumber.integerValue / model.stepTarget;
                        
                        NSLog(@"current progress = %f",progress);
                        
                        if (progress <= 1) {
                            [self.stepView drawProgress:progress];
                        }else if (progress >= 1) {
                            [self.stepView drawProgress:1];
                        }
                    }
                }
//            });
            
            //保存motion数据到数据库
            
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYY-MM-dd"];
            NSDate *currentDate = [NSDate date];
            NSString *currentDateString = [dateformatter stringFromDate:currentDate];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *stepArr = [self.myFmdbTool queryStepWithDate:currentDateString];
                
                StepDataModel *model = [StepDataModel modelWith:currentDateString step:manridyModel.sportModel.stepNumber kCal:manridyModel.sportModel.kCalNumber mileage:manridyModel.sportModel.mileageNumber];
                
                if (stepArr.count == 0) {
                    [self.myFmdbTool insertStepModel:model];
                }else {
                    [self.myFmdbTool modifyStepWithDate:currentDateString model:model];
                }
            });
            
            
        }
    }
}

//motion zero
- (void)receiveSetMotionZeroWithModel:(manridyModel *)manridyModel
{
    
}

//set heart rate test state
- (void)receiveHeartRateTestWithModel:(manridyModel *)manridyModel
{
    
}

//get heart rate data
- (void)receiveHeartRateDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeHeartRateModel) {
            [self.heartRateView.heartRateLabel setText:manridyModel.heartRateModel.heartRate];
        }
    }
}

//get sleepInfo
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSleepModel) {
            self.sleepView.sleepSumLabel.text = manridyModel.sleepModel.sumDataCount;
            [self.sleepView.sleepSumLabel setText:@"test"];
            self.sleepView.deepAndLowSleepLabel.text = [NSString stringWithFormat:@"深睡%@小时/浅睡%@小时",manridyModel.sleepModel.deepSleep ,manridyModel.sleepModel.lowSleep];
            
            NSInteger sleepSum = manridyModel.sleepModel.sumDataCount.integerValue;
            
            if (sleepSum <= 4) {
                [self.sleepView.sleepStateLabel setText:@"极度缺乏睡眠"];
                [self.sleepView.sleepStateLabel setTextColor:[UIColor redColor]];
                
                [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor redColor]];
                [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor blackColor]];
                
            }else if (sleepSum > 4 && sleepSum < 6) {
                [self.sleepView.sleepStateLabel setText:@"缺乏睡眠"];
                [self.sleepView.sleepStateLabel setTextColor:[UIColor orangeColor]];
                
                [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor orangeColor]];
                [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor blackColor]];
                
            }else if (sleepSum >= 6 && sleepSum < 8) {
                [self.sleepView.sleepStateLabel setText:@"睡眠良好"];
                [self.sleepView.sleepStateLabel setTextColor:[UIColor yellowColor]];
                
                [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor yellowColor]];
                [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor blackColor]];
                
            }else if (sleepSum >= 8) {
                [self.sleepView.sleepStateLabel setText:@"睡眠充足"];
                [self.sleepView.sleepStateLabel setTextColor:[UIColor greenColor]];
                
                [self.sleepView.sleepStateView1 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView2 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView3 setBackgroundColor:[UIColor blackColor]];
                [self.sleepView.sleepStateView4 setBackgroundColor:[UIColor greenColor]];
                
            }
        }
    }
}


#pragma mark - Action
- (void)showHistoryView
{
    
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

#warning 考虑写到subview里面去
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
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
    
    switch (self.pageControl.currentPage) {
        case 0:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 0) {
                    [self.myBleTool writeMotionRequestToPeripheral];
                }
            });
        }
            break;
        case 1:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.pageControl.currentPage == 1) {
                    [self.myBleTool writeHeartRateRequestToPeripheral:HeartRateDataLastData];
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
