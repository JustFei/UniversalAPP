//
//  HeartRateHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/21.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateHistoryViewController.h"
#import "PNBarChart.h"
#import "FMDBTool.h"

@interface HeartRateHistoryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (weak, nonatomic) IBOutlet UIView *state1;

@property (weak, nonatomic) IBOutlet UIView *state2;

@property (weak, nonatomic) IBOutlet UIView *state3;

@property (weak, nonatomic) IBOutlet UIView *state4;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *downView;

@property (nonatomic ,weak) PNBarChart *stepBarChart;

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
    
    //    NSArray *dataArr = [self getHistoryDataWithIntDays:days.length];
    
    NSMutableArray *dateArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [dateArr addObject:@(i)];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.view removeGestureRecognizer:self.oneFingerSwipedown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
