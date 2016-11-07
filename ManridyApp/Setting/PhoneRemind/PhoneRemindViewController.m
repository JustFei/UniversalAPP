//
//  PhoneRemindViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/17.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhoneRemindViewController.h"
#import "PhoneRemindTableViewCell.h"
#import "SectionModel.h"
#import "PhoneRemindView.h"
#import "ClockModel.h"
#import "FMDBTool.h"
#import "BLETool.h"


@interface PhoneRemindViewController () <UITableViewDelegate ,UITableViewDataSource ,UIPickerViewDelegate ,UIPickerViewDataSource ,BleReceiveDelegate>
{
    NSArray *_funcArr;
    NSArray *_clockArr;
    NSArray *_imageArr;
    NSMutableArray *_sectionArr;
    
    NSMutableArray *_hourArr;
    NSMutableArray *_minArr;
    NSMutableArray *_clockTimeArr;
}
@property (nonatomic ,weak) UITableView *remindTableView;

@property (nonatomic ,weak) UIPickerView *timePicker;

@property (nonatomic ,weak) UIButton *selectButton;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@end

@implementation PhoneRemindViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sectionArr = [NSMutableArray array];
    
//    _funcArr = @[@"来电提醒",@"短信提醒",@"防丢提醒",@"闹钟设置"];
//    _imageArr = @[@"alert_call",@"alert_sms",@"alert_lose",@"alert_clock"];
    _funcArr = @[@"防丢提醒",@"闹钟设置"];
    _imageArr = @[@"alert_lose",@"alert_clock"];
    _clockArr = @[@"闹钟1",@"闹钟2",@"闹钟3"];
    
    [self getPickerViewDataSource];
    
    SectionModel *sectionModel = [[SectionModel alloc] init];
    sectionModel.functionName = _funcArr[1];
    sectionModel.imageName = _imageArr[1];
    sectionModel.arrowImageName = @"all_next_icon";
    sectionModel.isExpanded = NO;
    [_sectionArr addObject:sectionModel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:@"提醒设置"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 16)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
    
    self.remindTableView.backgroundColor = [UIColor clearColor];
    self.remindTableView.tableHeaderView = nil;
    self.remindTableView.tableFooterView = nil;
    _clockTimeArr = [NSMutableArray array];
    
    [self.myBleTool addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _clockTimeArr = [NSMutableArray arrayWithArray:[self.myFmdbTool queryClockData]];
    if (_clockTimeArr.count == 0) {
        for (int i = 0; i < 3; i ++) {
            ClockModel *model = [[ClockModel alloc] init];
            model.time = @"08:00";
            model.isOpen = NO;
            [_clockTimeArr addObject:model];
        }
    }
    if (self.myBleTool.connectState == kBLEstateDidConnected) {
        [self.myBleTool writeClockToPeripheral:ClockDataGetClock withClockArr:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.myBleTool.receiveDelegate = nil;
    [self.myFmdbTool deleteClockData:4];
    
    for (ClockModel *model in _clockTimeArr) {
        [self.myFmdbTool insertClockModel:model];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change);
    NSString *new = change[@"new"];
    if (new.integerValue == kBLEstateDidConnected) {
        [self.myBleTool writeClockToPeripheral:ClockDataGetClock withClockArr:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - GetData
- (void)getPickerViewDataSource
{
    _hourArr = [NSMutableArray array];
    _minArr = [NSMutableArray array];
    
    for (int i = 0; i < 24; i ++ ) {
        [_hourArr addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    for (int min = 0; min < 60; min ++) {
        [_minArr addObject:[NSString stringWithFormat:@"%02d",min]];
    }
}

#pragma mark - Action
- (void)presentPickerView:(UIButton *)sender
{
    NSString *selectButtonTitle = sender.titleLabel.text;
    
    NSArray *time = [selectButtonTitle componentsSeparatedByString:@":"];
    NSString *hour = time.firstObject;
    NSString *min = time.lastObject;
    
    [self.timePicker selectRow:hour.integerValue inComponent:0 animated:NO];
    [self.timePicker selectRow:min.integerValue inComponent:1 animated:NO];
    
    self.timePicker.hidden = NO;
    self.selectButton = sender;
    
}

- (void)touchesBegan
{
    if (!self.timePicker.hidden) {
        self.timePicker.hidden = YES;
    }
    [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:_clockTimeArr];
}

- (void)findMyPeripheral:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"isFindMyPeripheral"];
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDateSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return _hourArr.count;
    }else {
        return _minArr.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return _hourArr[row];
    }else {
        return _minArr[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectButtonTitle = self.selectButton.titleLabel.text;
    
    NSArray *time = [selectButtonTitle componentsSeparatedByString:@":"];
    NSString *hour = time.firstObject;
    NSString *min = time.lastObject;
    
    if (component == 0) {
        hour = _hourArr[row];
    }else if (component == 1){
        min = _minArr[row];
    }
    
    [self.selectButton setTitle:[NSString stringWithFormat:@"%@:%@",hour ,min] forState:UIControlStateNormal];
    ClockModel *model = _clockTimeArr[self.selectButton.tag];
    model.time = [NSString stringWithFormat:@"%@:%@",hour ,min];
    [_clockTimeArr replaceObjectAtIndex:self.selectButton.tag withObject:model];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else {
        SectionModel *model = _sectionArr.firstObject;
        return model.isExpanded ? 3 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneRemindCell"];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.iconImageView.image = [UIImage imageNamed:_imageArr[indexPath.row]];
            cell.functionName.text = _funcArr[indexPath.row];
            [cell.timeSwitch setOn:NO];
            cell.timeButton.hidden = YES;
            
            switch (indexPath.row) {
                case 0:
                {
                    BOOL isRemind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"];
                    if (isRemind) {
                        [cell.timeSwitch setOn:YES];
                    }else {
                        [cell.timeSwitch setOn:NO];
                    }
                    
                    [cell.timeSwitch addTarget:self action:@selector(findMyPeripheral:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell.functionName.text = _clockArr[indexPath.row];
            if (_clockTimeArr.count == 0) {
                [cell.timeButton setTitle:@"08:00" forState:UIControlStateNormal];
                [cell.timeSwitch setOn:NO];
                [cell.timeButton setTitleColor:cell.timeSwitch.on ? [UIColor whiteColor] : [UIColor grayColor] forState:UIControlStateNormal];
            }else {
                ClockModel *model = _clockTimeArr[indexPath.row];
                [cell.timeButton setTitle:model.time forState:UIControlStateNormal];
                [cell.timeSwitch setOn:model.isOpen];
                [cell.timeButton setTitleColor:cell.timeSwitch.on ? [UIColor whiteColor] : [UIColor grayColor] forState:UIControlStateNormal];
            }
            cell.timeButton.tag = indexPath.row;
            [cell.timeButton addTarget:self action:@selector(presentPickerView:) forControlEvents:UIControlEventTouchUpInside];
            cell.timeButton.enabled = cell.timeSwitch.on;
            __weak typeof(cell) weakCell = cell;
            __weak typeof(self) weakSelf = self;
            
            cell._clockSwitchValueChangeBlock =^{
                if (weakSelf.myBleTool.connectState == kBLEstateDidConnected) {
                    ClockModel *model = _clockTimeArr[indexPath.row];
                    model.isOpen = weakCell.timeSwitch.on;
                    [_clockTimeArr replaceObjectAtIndex:indexPath.row withObject:model];
                    [weakSelf.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:_clockTimeArr];
                }else {
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请连接上设备后再设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ac = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakCell.timeSwitch setOn:!weakCell.timeSwitch.on];
                    }];
                    [vc addAction:ac];
                    [weakSelf presentViewController:vc animated:YES completion:nil];
                }
            };
        }
            break;
            
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.timeSwitch.transform = CGAffineTransformMakeScale(0.85, 0.75);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }else {
        PhoneRemindView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"phoneHead"];
//        view.backgroundColor = [UIColor redColor];
        
        SectionModel *sectionModel = _sectionArr.firstObject;
        view.model = sectionModel;
        view.expandCallback = ^(BOOL isExpanded) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                     withRowAnimation:UITableViewRowAnimationFade];
        };
        
        return view;
    }
}

#pragma mark - receiveDelegate
- (void)receiveSetClockDataWithModel:(manridyModel *)manridyModel
{
    _clockTimeArr = manridyModel.clockModelArr;
    [self.remindTableView reloadData];
}

#pragma mark - 懒加载
- (UITableView *)remindTableView
{
    if (!_remindTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 16)];
        view.allowsSelection = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan)];
        [view addGestureRecognizer:tap];
        
        view.backgroundColor = [UIColor clearColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _remindTableView = view;
        [_remindTableView registerNib:[UINib nibWithNibName:@"PhoneRemindTableViewCell" bundle:nil] forCellReuseIdentifier:@"phoneRemindCell"];
        [_remindTableView registerClass:[PhoneRemindView class] forHeaderFooterViewReuseIdentifier:@"phoneHead"];
    }
    
    return _remindTableView;
}

- (UIPickerView *)timePicker
{
    if (!_timePicker) {
        UIPickerView *view = [[UIPickerView alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width - 40, 200)];
        
        view.delegate = self;
        view.dataSource = self;
        
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        _timePicker = view;
    }
    
    return _timePicker;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}

- (BLETool *)myBleTool
{
    if (!_myBleTool) {
        _myBleTool = [BLETool shareInstance];
        _myBleTool.receiveDelegate = self;
    }
    
    return _myBleTool;
}

@end
