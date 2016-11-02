//
//  SleepHistoryViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/25.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepHistoryViewController.h"
#import "DropdownMenuView.h"
#import "TitleMenuViewController.h"

@interface SleepHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate>

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

@property (nonatomic ,strong) UIButton *titleButton;

@property (nonatomic ,strong) UISwipeGestureRecognizer *oneFingerSwipedown;

@end

@implementation SleepHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger month = [components month];
    [self.monthButton setTitle:[NSString stringWithFormat:@"%ld月",month] forState:UIControlStateNormal];
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
    NSLog(@"indexPath = %ld", indexPath.row);
    NSLog(@"当前选择了%@", title);
    
    // 修改导航栏的标题
    [self.monthButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark 弹出下拉菜单
-(void)pop
{
    NSLog(@"用户点击了右侧弹出下拉菜单按钮");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
