//
//  SleepSettingViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepSettingViewController.h"

@interface SleepSettingViewController () < UIPickerViewDelegate , UIPickerViewDataSource >
{
    NSMutableArray *_timeArr;
}

@property (weak, nonatomic) IBOutlet UILabel *sleepTargetLabel;

@property (nonatomic ,weak) UIPickerView *timePickerView;

@end

@implementation SleepSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _timeArr = [NSMutableArray array];
    
    for (float f = 24; f > 0; f = f - 0.5) {
        [_timeArr addObject:[NSString stringWithFormat:@"%0.1f",f]];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimePickerView)];
    self.sleepTargetLabel.userInteractionEnabled = YES;
    [self.sleepTargetLabel addGestureRecognizer:tap];
    
    [self.timePickerView setHidden:YES];
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
    return _timeArr.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _timeArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.sleepTargetLabel setText:_timeArr[row]];
}

#pragma mark - Action
#pragma mark -UITapGestureRecognizer Action
- (void)showTimePickerView
{
    [self.timePickerView setHidden:NO];
}

#pragma mark -UIViewTouchBegin Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.timePickerView.hidden) {
        [self.timePickerView setHidden:YES];
    }
}

#pragma mark - 懒加载
- (UIPickerView *)timePickerView
{
    if (!_timePickerView) {
        UIPickerView *view = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.center.x - self.view.frame.size.width * 150 / 320, self.view.center.y - self.view.frame.size.width * 100 / 320, self.view.frame.size.width * 300 / 320, self.view.frame.size.width * 200 / 320)];
        view.backgroundColor = [UIColor whiteColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _timePickerView = view;
    }
    
    return _timePickerView;
}

@end
