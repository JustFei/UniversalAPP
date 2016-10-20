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



@interface StepHistoryViewController () <DropdownMenuDelegate, TitleMenuDelegate>
@property (weak, nonatomic) IBOutlet UILabel *averageStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *averagerMileageAndkCalLabel;
@property (weak, nonatomic) IBOutlet UIButton *mouthButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,weak) PNBarChart *stepBarChart;

@end

@implementation StepHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //获取这个月的天数
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:today];
    
    NSArray *dataArr = [self getHistoryDataWithIntDays:days.length];
    
    
    NSMutableArray *dateArr = [NSMutableArray array];
    
    for (int i = 1; i <= days.length; i ++) {
        [dateArr addObject:@(i)];
    }
    
    //这里存在这样一个问题，当y轴数据都为0时，会出现显示很多很多个0在Y轴上
    [self.stepBarChart setXLabels:dateArr];
    [self.stepBarChart setYValues:dataArr];
    
    [self.stepBarChart strokeChart];
}

- (NSArray *)getHistoryDataWithIntDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger iCurYear = [components year];  //当前的年份
    
    NSInteger iCurMonth = [components month];  //当前的月份
    
    NSMutableArray *dataArr = [NSMutableArray array];
    
    for (NSInteger i = 1; i <= days; i ++) {
        NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%02ld",iCurYear ,iCurMonth ,i];
        NSLog(@"%@",dateStr);
        
        if ([self.myFmdbTool queryStepWithDate:dateStr].count == 0) {
            [dataArr addObject:@0];
        }else {
            [dataArr addObject:[self.myFmdbTool queryStepWithDate:dateStr].firstObject];
        }
    }
    
    return dataArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    temp.size.width = self.view.frame.size.width/2;
    temp.size.height = self.view.frame.size.height/2;
    
    titleMenuVC.view.frame = temp;
    
    dropdownMenuView.contentController = titleMenuVC;
    
    // 3.显示下拉菜单
    [dropdownMenuView showFrom:sender];
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
    [self.mouthButton setTitle:title forState:UIControlStateNormal];
    
    // 调用根据搜索条件返回相应的微博数据
    // ...
}

#pragma mark 打开好友关注动态控制器
-(void)friendsearch
{
    NSLog(@"用户点击了左侧按钮");
    
//    FriendAttentionStatusViewController *friendAttentionStatusVC = [[FriendAttentionStatusViewController alloc]init];
//    [self.navigationController pushViewController:friendAttentionStatusVC animated:YES];
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
        PNBarChart *view = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.downView.frame.size.width, self.downView.frame.size.height)];
        view.backgroundColor = [UIColor yellowColor];
        
        [self.downView addSubview:view];
        _stepBarChart = view;
    }
    
    return  _stepBarChart;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}
@end
