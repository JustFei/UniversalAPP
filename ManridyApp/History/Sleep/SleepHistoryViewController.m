//
//  SleepHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepHistoryViewController.h"

@interface SleepHistoryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *sleepLabel;

@property (weak, nonatomic) IBOutlet UIView *state1;

@property (weak, nonatomic) IBOutlet UIView *state2;

@property (weak, nonatomic) IBOutlet UIView *state3;

@property (weak, nonatomic) IBOutlet UIView *state4;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *downView;

@end

@implementation SleepHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
