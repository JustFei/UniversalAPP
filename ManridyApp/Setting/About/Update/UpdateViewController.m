//
//  UpdateViewController.m
//  ManridyApp
//
//  Created by Faith on 2017/4/5.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UpdateViewController.h"
#import "PNChart.h"

@interface UpdateViewController ()

@property (nonatomic, strong) UIImageView *updateArrow;
@property (nonatomic, strong) UILabel *updateStateLabel;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) PNCircleChart *updateCircle;
@property (nonatomic, strong) UILabel *currentLabel;

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:37.0 / 255.0 green:154.0 / 255.0 blue:219.0 / 255.0 alpha:1];
    [self createUI];
}

- (void)createUI
{
    //固件升级
    UILabel *firmwareLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, 55, 200, 30)];
    [firmwareLabel setText:@"固件升级"];
    [firmwareLabel setTextColor:[UIColor whiteColor]];
    firmwareLabel.textAlignment = NSTextAlignmentCenter;
    [firmwareLabel setFont:[UIFont systemFontOfSize:30]];
    [self.view addSubview:firmwareLabel];
    
    //升级中请勿使设备远离手机
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(firmwareLabel.frame.origin.x, 99, 200, 11)];
    [tipLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [tipLabel setText:@"升级中请勿使设备远离手机"];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipLabel setFont:[UIFont systemFontOfSize:11]];
    [self.view addSubview:tipLabel];
    
    //升级中的箭头
    self.updateArrow  = [[UIImageView alloc] initWithFrame:CGRectMake(self.updateCircle.center.x - 11.5, self.updateCircle.center.y - 12, 23, 24)];
    self.updateArrow.image = [UIImage imageNamed:@"about_updte_icon"];
    [self.view addSubview:self.updateArrow];
    
    [self.updateCircle strokeChart];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // Do something useful in the background and update the HUD periodically.
        [self doSomeWorkWithProgress];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.updateArrow.hidden = YES;
            self.updateStateLabel.text = @"升级成功!";
            [self.updateStateLabel setTextColor:[UIColor whiteColor]];
            self.sureButton.hidden = NO;
            self.currentLabel.hidden = YES;
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)backAction:(UIButton *)sender
{
    CATransition * animation = [CATransition animation];
    animation.duration = 0.5;    //  时间
    
    /**  type：动画类型
     *  pageCurl       向上翻一页
     *  pageUnCurl     向下翻一页
     *  rippleEffect   水滴
     *  suckEffect     收缩
     *  cube           方块
     *  oglFlip        上下翻转
     */
    animation.type = @"rippleEffect";
    
    /**  type：页面转换类型
     *  kCATransitionFade       淡出
     *  kCATransitionMoveIn     覆盖
     *  kCATransitionReveal     底部显示
     *  kCATransitionPush       推出
     */
    //animation.type = kCATransitionMoveIn;
    
    //PS：type 更多效果请 搜索： CATransition
    
    /**  subtype：出现的方向
     *  kCATransitionFromRight       右
     *  kCATransitionFromLeft        左
     *  kCATransitionFromTop         上
     *  kCATransitionFromBottom      下
     */
    //animation.subtype = kCATransitionFromBottom;
    
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doSomeWorkWithProgress
{
    float progress = 0.0f;
    while (progress < 1.0f) {
        //if (self.canceled) break;
        progress += 0.01f;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Instead we could have also passed a reference to the HUD
            // to the HUD to myProgressTask as a method parameter.
            [self.updateCircle updateChartByCurrent:@(progress)];
            int pro = progress * 100;
            DLog(@"%d",pro);
            self.currentLabel.text = [NSString stringWithFormat:@"已完成%d%%", pro];
        });
        usleep(50000);
    }
}

#pragma mark - lazy
- (PNCircleChart *)updateCircle
{
    if (!_updateCircle) {
        //进度环
        _updateCircle = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.view.center.x - 57.5, 205, 115, 115) total:@(1) current:@(0) clockwise:YES shadow:YES shadowColor:[UIColor colorWithWhite:1 alpha:0.5] displayCountingLabel:NO overrideLineWidth:@(3)];
        _updateCircle.backgroundColor = [UIColor clearColor];
        [_updateCircle setStrokeColor:[UIColor whiteColor]];
        //[_updateCircle setStrokeColorGradientStart:[UIColor colorWithWhite:1 alpha:0.5]];
        [self.view addSubview:_updateCircle];
    }
    
    return _updateCircle;
}

- (UILabel *)updateStateLabel
{
    if (!_updateStateLabel) {
        _updateStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.updateCircle.center.x - 30, self.updateCircle.center.y - 12, 60, 12)];
        [_updateStateLabel setFont:[UIFont systemFontOfSize:12]];
        _updateStateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:_updateStateLabel];
    }
    
    return _updateStateLabel;
}

- (UIButton *)sureButton
{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(self.updateCircle.center.x - 20, self.updateStateLabel.frame.origin.y + 29, 40, 12);
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"确定"];
        NSRange strRange = {0,[str length]};
        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 / 255.0 green:255.0 / 255.0 blue:252.0 / 255.0 alpha:1] range:strRange];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:strRange];
        [_sureButton setAttributedTitle:str forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_sureButton];
    }
    
    return _sureButton;
}

- (UILabel *)currentLabel
{
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 50, self.updateCircle.frame.origin.y + 133, 100, 11)];
        [_currentLabel setFont:[UIFont systemFontOfSize:11]];
        [_currentLabel setText:@"已完成0%"];
        [_currentLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_currentLabel];
    }
    
    return _currentLabel;
}

@end
