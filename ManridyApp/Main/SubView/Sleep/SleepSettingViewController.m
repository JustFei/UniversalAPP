//
//  SleepSettingViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "SleepSettingViewController.h"
#import "FMDBTool.h"
#import "UserInfoModel.h"

@interface SleepSettingViewController () < UIPickerViewDelegate , UIPickerViewDataSource >
{
    NSMutableArray *_timeArr;
    NSArray *_userArr;
}

@property (weak, nonatomic) IBOutlet UILabel *sleepTargetLabel;

@property (nonatomic ,weak) UIPickerView *timePickerView;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _userArr = [self.myFmdbTool queryAllUserInfo];
        //这里由于是单用户，所以取第一个值
        UserInfoModel *model = _userArr.firstObject;
        
        if (model.sleepTarget != 0) {
            self.sleepTargetLabel.text = [NSString stringWithFormat:@"%ld",(long)model.sleepTarget];
        }
    });
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
    if (_userArr.count != 0) {
        [self.sleepTargetLabel setText:_timeArr[row]];
        [self.myFmdbTool modifySleepTargetWithID:1 model:self.sleepTargetLabel.text.integerValue];
        
    }else {
        AlertTool *vc = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"plzSetUserInfoFirst", nil) style:UIAlertControllerStyleAlert];
        [vc addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:nil]];
        
        [vc show];
    }
    
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

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}

@end
