//
//  TemperatureWarningViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "TemperatureWarningViewController.h"

typedef enum : NSUInteger {
    DataArrTypeHigh = 0,
    DataArrTypeLow,
    DataArrTypeInterval,
} DataArrType;

@interface TemperatureWarningViewController () <UIPickerViewDelegate ,UIPickerViewDataSource >
{
    DataArrType _dataType;
    NSArray *_highArr;
    NSArray *_lowArr;
    NSArray *_intervalArr;
}
@property (weak, nonatomic) IBOutlet UILabel *highLabel;

@property (weak, nonatomic) IBOutlet UILabel *highRingLabel;

@property (weak, nonatomic) IBOutlet UILabel *highVibrateLabel;

@property (weak, nonatomic) IBOutlet UILabel *lowLabel;

@property (weak, nonatomic) IBOutlet UILabel *lowRingLabel;

@property (weak, nonatomic) IBOutlet UILabel *lowVibrateLabel;

@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;

@property (weak, nonatomic) IBOutlet UISwitch *highSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *highRingSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *highVibrateSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *lowSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *lowRingSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *lowVibrateSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *intervalSwitch;

@property (nonatomic ,weak) UIPickerView *temperaturePickView;

@end

@implementation TemperatureWarningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"报警设置";
    
    _highArr = @[@"35",@"36",@"37",@"38",@"39",@"40",@"41"];
    _lowArr = @[@"39",@"38",@"37",@"36",@"35",@"34",@"33"];
    _intervalArr = @[@"10",@"20",@"30",@"40",@"50",@"60"];
    
    UITapGestureRecognizer *highTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHighPickerView)];
    self.highLabel.userInteractionEnabled = YES;
    [self.highLabel addGestureRecognizer:highTap];
    
    UITapGestureRecognizer *lowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLowPickerView)];
    self.lowLabel.userInteractionEnabled = YES;
    [self.lowLabel addGestureRecognizer:lowTap];
    
    UITapGestureRecognizer *intervalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showIntervalPickerView)];
    self.intervalLabel.userInteractionEnabled = YES;
    [self.intervalLabel addGestureRecognizer:intervalTap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (_dataType) {
        case DataArrTypeHigh:
            return _highArr.count;
            break;
            
        case DataArrTypeLow:
            return _lowArr.count;
            break;
            
        case DataArrTypeInterval:
            return _intervalArr.count;
            break;
            
        default:
            break;
    }
}

#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (_dataType) {
        case DataArrTypeHigh:
            return _highArr[row];
            break;
            
        case DataArrTypeLow:
            return _lowArr[row];
            break;
            
        case DataArrTypeInterval:
            return _intervalArr[row];
            break;
            
        default:
            break;
    }
}

#pragma mark - Action
#pragma mark -UISwitchAcion
- (IBAction)highAction:(UISwitch *)sender {
    
    if (sender.isOn) {
        [self.highLabel setTextColor:[UIColor whiteColor]];
        
        self.highRingSwitch.enabled = YES;
        self.highVibrateSwitch.enabled = YES;
    }else {
        [self.highLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        [self.highRingLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        [self.highVibrateLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        
        [self.highRingSwitch setOn:NO animated:YES];
        [self.highVibrateSwitch setOn:NO animated:YES];
        
        self.highRingSwitch.enabled = NO;
        self.highVibrateSwitch.enabled = NO;
        
        [self.highRingLabel setText:@"关"];
        [self.highVibrateLabel setText:@"关"];
    }
    
    
}

- (IBAction)highRingAction:(UISwitch *)sender {
    
    if (self.highSwitch.isOn) {
        if (sender.isOn) {
            [self.highRingLabel setTextColor:[UIColor whiteColor]];
            [self.highRingLabel setText:@"开"];
        }else {
            [self.highRingLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
            [self.highRingLabel setText:@"关"];
        }
    }
}

- (IBAction)highVibrateAction:(UISwitch *)sender {
    
    if (self.highSwitch.isOn) {
        if (sender.isOn) {
            [self.highVibrateLabel setTextColor:[UIColor whiteColor]];
            [self.highVibrateLabel setText:@"开"];
        }else {
            [self.highVibrateLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
            [self.highVibrateLabel setText:@"关"];
        }
    }
}

- (IBAction)lowAction:(UISwitch *)sender {
    
    if (sender.isOn) {
        [self.lowLabel setTextColor:[UIColor whiteColor]];

        self.lowRingSwitch.enabled = YES;
        self.lowVibrateSwitch.enabled = YES;
    }else {
        [self.lowLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        [self.lowRingLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        [self.lowVibrateLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
        
        [self.lowRingSwitch setOn:NO animated:YES];
        [self.lowVibrateSwitch setOn:NO animated:YES];
        
        [self.lowRingSwitch setEnabled:NO];
        [self.lowVibrateSwitch setEnabled:NO];
        
        [self.lowRingLabel setText:@"关"];
        [self.lowVibrateLabel setText:@"关"];
    }
}

- (IBAction)lowRingAction:(UISwitch *)sender {
    
    if (self.lowSwitch.isOn) {
        if (sender.isOn) {
            [self.lowRingLabel setTextColor:[UIColor whiteColor]];
            [self.lowRingLabel setText:@"开"];
        }else {
            [self.lowRingLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
            [self.lowRingLabel setText:@"关"];
        }
    }
}

- (IBAction)lowVibrateAction:(UISwitch *)sender {
    
    if (self.lowVibrateSwitch.isOn) {
        if (sender.isOn) {
            [self.lowVibrateLabel setTextColor:[UIColor whiteColor]];
            [self.lowVibrateLabel setText:@"开"];
        }else {
            [self.lowVibrateLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
            [self.lowVibrateLabel setText:@"关"];
        }
    }
}

- (IBAction)intervalAction:(UISwitch *)sender {
    if (sender.isOn) {
        [self.intervalLabel setTextColor:[UIColor whiteColor]];
    }else {
        [self.intervalLabel setTextColor:[UIColor colorWithRed:191.0 / 255.0 green:191.0 / 255.0 blue:191.0 / 255.0 alpha:1]];
    }
}

#pragma mark -UITapGestureRecognizer Action
- (void)showHighPickerView
{
    if (self.highSwitch.isOn) {
        _dataType = DataArrTypeHigh;
        [self.temperaturePickView reloadAllComponents];
        self.temperaturePickView.hidden = NO;
    }
}

- (void)showLowPickerView
{
    if (self.lowSwitch.isOn) {
        _dataType = DataArrTypeLow;
        [self.temperaturePickView reloadAllComponents];
        self.temperaturePickView.hidden = NO;
    }
}

- (void)showIntervalPickerView
{
    if (self.intervalSwitch.isOn) {
        _dataType = DataArrTypeInterval;
        [self.temperaturePickView reloadAllComponents];
        [self.temperaturePickView setHidden:NO];
    }
}

#pragma mark -UIViewTouchBegin Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.temperaturePickView setHidden:YES];
}

#pragma mark - 懒加载
- (UIPickerView *)temperaturePickView
{
    if (!_temperaturePickView) {
        UIPickerView *view = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.center.x - 150, 200, 300, 200)];
        view.backgroundColor = [UIColor whiteColor];
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _temperaturePickView = view;
    }
    
    return _temperaturePickView;
}

@end
