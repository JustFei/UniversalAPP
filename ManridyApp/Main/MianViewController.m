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

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface MainViewController () <UIScrollViewDelegate>
{
    NSArray *titleArr;
    UIButton *_titleButton;
    BOOL isShowList;
}
@property (nonatomic ,weak) UIScrollView *backGroundView;

@property (nonatomic ,weak) UIPageControl *pageControl;

@property (nonatomic ,assign) BOOL didEndDecelerating;

@property (nonatomic ,weak) MenuContentView *menuView;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    titleArr = @[@"计步",@"心率",@"体温",@"睡眠",@"血压"];
    
    [self createUI];
}

- (void)createUI
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(showHistoryView)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleButton setTitle:titleArr[0] forState:UIControlStateNormal];
    [_titleButton setTintColor:[UIColor whiteColor]];
    [_titleButton addTarget:self action:@selector(showTheList) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = _titleButton;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingView)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    
    self.pageControl.tintColor = [UIColor redColor];
    
    self.menuView.backgroundColor = [UIColor blueColor];
}

- (void)showHistoryView
{
    
}

- (void)showSettingView
{
    
}

- (void)showTheList
{
    if (!isShowList) {
        [UIView animateWithDuration:0.5 animations:^{
            self.menuView.frame = CGRectMake(30, 150, self.view.frame.size.width - 60, self.view.frame.size.width - 60);
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
    
    _titleButton.titleLabel.text = titleArr[i];
    self.pageControl.currentPage = i;
}


// 再次拖拽的时候，判断有没有因为滑动太快而没有调用结束减速的方法。
// 如果没有，四舍五入手动确定位置。这样就可以解决滑动过快的问题
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!self.didEndDecelerating) {
        // 先计算当期的page/index
        CGFloat index = scrollView.contentOffset.x/WIDTH;
        //再四舍五入推算本该减速时的scrollView的contentOffset。即：roundf(index)*self.screenWidth]
        
        int i = roundf(index);
        
        _titleButton.titleLabel.text = titleArr[i];
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
        
        StepContentView *stepView = [[StepContentView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [view addSubview:stepView];
        
        HeartRateContentView *heartRateView = [[HeartRateContentView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:heartRateView];
        
        TemperatureContentView *temperatureView = [[TemperatureContentView alloc] initWithFrame:CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:temperatureView];
        
        SleepContentView *sleepView = [[SleepContentView alloc] initWithFrame:CGRectMake(3 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:sleepView];
        
        BloodPressureContentView  *bloodPressureView = [[BloodPressureContentView alloc] initWithFrame:CGRectMake(4 * WIDTH, 0, WIDTH, HEIGHT)];
        [view addSubview:bloodPressureView];
        
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
        
        [self.view addSubview:view];
        _menuView = view;
    }
    
    return _menuView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *view = [[UIPageControl alloc] initWithFrame:CGRectMake(54, 338, 212, 37)];
        view.numberOfPages = 5;
        view.currentPage = 0;
        view.enabled = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenMenuView)];
        [view addGestureRecognizer:tap];
        
        [self.view addSubview:view];
        _pageControl = view;
    }
    
    return _pageControl;
}

@end
