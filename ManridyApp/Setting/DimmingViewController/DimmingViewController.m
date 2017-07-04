//
//  DimmingViewController.m
//  New_iwear
//
//  Created by Faith on 2017/5/6.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "DimmingViewController.h"

@interface DimmingViewController ()
{
    float _currentDim;
}
@property (nonatomic, strong) UILabel *currentDimLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *subtractBtn;
@property (nonatomic, strong) UIButton *plusBtn;

@end

@implementation DimmingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:NSLocalizedString(@"LightAdjust", nil)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(weatheSuccess:) name:SET_FIRMWARE object:nil];
    
    [self createUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI
{
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setText:NSLocalizedString(@"SetPerLight", nil)];
    [infoLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
    [infoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_top).offset(25);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(infoLabel.mas_bottom).offset(18);
        make.height.equalTo(@1);
    }];
    
    _currentDimLabel = [[UILabel alloc] init];
    
    [_currentDimLabel setTextColor:COLOR_WITH_HEX(0x2196f3, 1)];
    [_currentDimLabel setFont:[UIFont systemFontOfSize:16]];
    [self.view addSubview:_currentDimLabel];
    [_currentDimLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(lineView.mas_top).offset(29);
    }];
    
    _slider = [[UISlider alloc] init];
    _slider.minimumValue = 0;
    _slider.maximumValue = 2;
//    _slider.step = 10;
//    _slider.enabledValueLabel = YES;
    [self.view addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_currentDimLabel.mas_bottom).offset(40);
        make.width.equalTo(@(225 * VIEW_CONTROLLER_FRAME_WIDTH / 375));
        make.height.equalTo(@10);
    }];
    
    if ([[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING]) {
        float value = [[NSUserDefaults standardUserDefaults] floatForKey:DIMMING_SETTING];
        int index = value;
        [self changeDimLabel:index];
        _slider.value = value;
    }else {
        [_currentDimLabel setText:NSLocalizedString(@"mid", nil)];
        _slider.value = 1;
    }
    _slider.continuous = NO;
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _currentDim = _slider.value;

    _subtractBtn = [[UIButton alloc] init];
    [_subtractBtn setTitle:@"-" forState:UIControlStateNormal];
    [_subtractBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [_subtractBtn setTitleColor:COLOR_WITH_HEX(0x1e1e1e, 1) forState:UIControlStateNormal];
//    _subtractBtn.backgroundColor = CLEAR_COLOR;
    _subtractBtn.layer.masksToBounds = YES;
    _subtractBtn.layer.cornerRadius = 12;
    [_subtractBtn addTarget:self action:@selector(subtractAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_subtractBtn];
    [_subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_slider.mas_left).offset(-10);
        make.centerY.equalTo(_slider.mas_top).offset(52);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
    
    _plusBtn = [[UIButton alloc] init];
    [_plusBtn setTitle:@"+" forState:UIControlStateNormal];
    [_plusBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [_plusBtn setTitleColor:COLOR_WITH_HEX(0x1e1e1e, 1) forState:UIControlStateNormal];
//    _plusBtn.backgroundColor = CLEAR_COLOR;
    _plusBtn.layer.masksToBounds = YES;
    _plusBtn.layer.cornerRadius = 12;
    [_plusBtn addTarget:self action:@selector(plusAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_plusBtn];
    [_plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_slider.mas_right).offset(10);
        make.centerY.equalTo(_slider.mas_top).offset(52);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSLog(@"slider.value == %.3f", self.slider.value);
    if (sender.value <= 0.5) {
        [sender setValue:0];
    }else if (sender.value <= 1.5) {
        [sender setValue:1];
    }else {
        [sender setValue:2];
    }
    
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
        sender.value = _currentDim;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"NoConnectToSave", nil);
        [hud hideAnimated:YES afterDelay:2];
    }else {
        [self writeVlaueToPer:sender.value];
    }
}

- (void)subtractAction:(UIButton *)sender
{
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
        self.slider.value = _currentDim;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"NoConnectToSave", nil);
        [hud hideAnimated:YES afterDelay:2];
    }else {
        if (self.slider.value == 0) {
            return;
        }else {
            self.slider.value = self.slider.value - 1;
            [self writeVlaueToPer:self.slider.value];
        }
    }
}

- (void)plusAction:(UIButton *)sender
{
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
        self.slider.value = _currentDim;
        //        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"NoConnectToSave", nil);
        [hud hideAnimated:YES afterDelay:2];
    }else {
        if (self.slider.value == 2) {
            return;
        }else {
            self.slider.value = self.slider.value + 1;
            [self writeVlaueToPer:self.slider.value];
        }
    }
}

- (void)writeVlaueToPer:(float)value
{
    _currentDim = value;
    int index = value;
    [self changeDimLabel:index];
    [[BLETool shareInstance] writeDimmingToPeripheral:value];
}

- (void)changeDimLabel:(NSInteger )index
{
    switch (index) {
        case 0:
            self.currentDimLabel.text = NSLocalizedString(@"low", nil);
            break;
        case 1:
            self.currentDimLabel.text = NSLocalizedString(@"mid", nil);
            break;
        case 2:
            self.currentDimLabel.text = NSLocalizedString(@"lightHight", nil);
            break;
            
        default:
            break;
    }
}

- (void)weatheSuccess:(NSNotification *)noti
{
    manridyModel *model = [noti object];
    if (model.receiveDataType == ReturnModelTypeFirwmave){
        //这里不能直接写 if (isFirst),必须如下写法
        if (model.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            [[NSUserDefaults standardUserDefaults] setFloat:self.slider.value forKey:DIMMING_SETTING];

            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"saveSuccess", nil);
            [hud hideAnimated:YES afterDelay:2];
        }else {
            //做失败处理
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"saveFail", nil);
            [hud hideAnimated:YES afterDelay:2];
        }
    }
}

@end
