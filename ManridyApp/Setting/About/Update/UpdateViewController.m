//
//  UpdateViewController.m
//  ManridyApp
//
//  Created by Faith on 2017/4/5.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UpdateViewController.h"
#import "PNChart.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>
#import <iOSDFULibrary/iOSDFULibrary-umbrella.h>
//#import "SyncTool.h"
#import "AppDelegate.h"

@interface UpdateViewController () <LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate, BleConnectDelegate >

@property (nonatomic, strong) UIImageView *updateArrow;
@property (nonatomic, strong) UILabel *updateStateLabel;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) PNCircleChart *updateCircle;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) DFUServiceController *controller;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:37.0 / 255.0 green:154.0 / 255.0 blue:219.0 / 255.0 alpha:1];
    
    [BLETool shareInstance].connectDelegate = self;
    [self createUI];
    
    [self downloadUpdate];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [((AppDelegate *)[UIApplication sharedApplication].delegate) resetDelegate];
}

- (void)dealloc
{
//    [((AppDelegate *)[UIApplication sharedApplication].delegate) resetDelegate];
}

- (void)downloadUpdate
{
    NSURL *url = [NSURL URLWithString:self.filePa];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:10.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        DLog(@"updateFile == %@", data);
        //4.写数据到沙盒中
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"update.zip"];
        BOOL result = [data writeToFile:filePath atomically:NO];
        if (result) {
            [self otaWithFile];
        }
    }];
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
//    self.myBleTool = [BLETool shareInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)otaWithFile
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"update.zip"];;
    DFUFirmware *firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:filePath]];
    // To start the DFU operation the DFUServiceInitiator must be used
    //1.创建 DFU 对象
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager: [BLETool shareInstance].myCentralManager target:[BLETool shareInstance].currentDev.peripheral];
    //2.选择刷入的固件
    [initiator withFirmware:firmware];
    
    initiator.logger = self;
    initiator.delegate = self;
    initiator.progressDelegate = self;
    
    self.controller = [initiator start];
    [self.controller pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.controller resume];
    });
}

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

#pragma mark - DFU Service delegate methods
#pragma mark -LoggerDelegate
-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"%ld: %@", (long) level, message);
}

#pragma mark -DFUServiceDelegate
- (void)dfuStateDidChangeTo:(enum DFUState)state
{
    switch (state) {
        case DFUStateConnecting:
            self.currentLabel.text = @"Connecting...";
            break;
        case DFUStateStarting:
            self.currentLabel.text = @"Starting DFU...";
            break;
        case DFUStateEnablingDfuMode:
            self.currentLabel.text = @"Enabling DFU Bootloader...";
            break;
        case DFUStateUploading:
            self.currentLabel.text = @"Uploading...";
            break;
        case DFUStateValidating:
            self.currentLabel.text = @"Validating...";
            break;
        case DFUStateDisconnecting:
            self.currentLabel.text = @"Disconnecting...";
            break;
        case DFUStateCompleted:
        {
            self.updateArrow.hidden = YES;
            self.updateStateLabel.text = @"升级成功!";
            [self.updateStateLabel setTextColor:[UIColor whiteColor]];
            self.currentLabel.hidden = YES;
            
            //此处需要重新设置下CentralManager 的代理方法，不然不会设置peripheral 的delegate
            [BLETool shareInstance].myCentralManager.delegate = [BLETool shareInstance];
            [[BLETool shareInstance] connectDevice:[BLETool shareInstance].currentDev];
            
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.label.text = @"正在同步设置";
            [self.hud showAnimated:YES];
        }
            break;
        case DFUStateAborted:
        {
            self.currentLabel.text = @"Upload aborted";
            //[self.hud hideAnimated:YES afterDelay:2];
        }
            break;
        default:
            break;
    }
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message
{
    NSLog(@"Error %ld: %@", (long) error, message);
    
    self.updateArrow.hidden = YES;
    self.updateStateLabel.text = @"升级失败!";
    [self.updateStateLabel setTextColor:[UIColor redColor]];
    self.sureButton.hidden = NO;
    self.currentLabel.hidden = YES;
    //[self.myBleTool connectDevice:self.myBleTool.currentDev];
}

#pragma mark - BleConnectDelegate
/**
 *  invoked when the device did connected by the centeral
 *
 *  @param device the device did connected
 */
- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[SyncTool shareInstance] syncSetting];
//        [SyncTool shareInstance].syncSettingSuccessBlock = ^(BOOL success) {
//            if (success) {
                self.hud.label.text = @"同步完成";
                [self.hud hideAnimated:YES afterDelay:1.5];
                self.sureButton.hidden = NO;
//            }else {
//                self.hud.label.text = @"同步失败";
//                [self.hud hideAnimated:YES afterDelay:1.5];
//                self.sureButton.hidden = NO;
//            }
//        };
    });
}

#pragma mark -DFUProgressDelegate
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    NSLog(@"Progress: %ld%% (part %ld/%ld). Speed: %f bps, Avg speed: %f bps", (long) progress, (long) part, (long) totalParts, currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
    
    [self.updateCircle updateChartByCurrent:@(progress)];
    self.currentLabel.text = [NSString stringWithFormat:@"已完成%ld%%", (long)progress];
}



#pragma mark - lazy
- (PNCircleChart *)updateCircle
{
    if (!_updateCircle) {
        //进度环
        _updateCircle = [[PNCircleChart alloc] initWithFrame:CGRectMake(self.view.center.x - 57.5, 205, 115, 115) total:@(100) current:@(0) clockwise:YES shadow:YES shadowColor:[UIColor colorWithWhite:1 alpha:0.5] displayCountingLabel:NO overrideLineWidth:@(3)];
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
