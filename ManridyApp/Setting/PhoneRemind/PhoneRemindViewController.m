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
#import "Remind.h"


@interface PhoneRemindViewController () <UITableViewDelegate ,UITableViewDataSource ,UIPickerViewDelegate ,UIPickerViewDataSource ,BleReceiveDelegate>
{
    NSArray *_funcArr;
    NSArray *_clockArr;
    NSArray *_imageArr;
    NSMutableArray *_sectionArr;
    
    NSMutableArray *_hourArr;
    NSMutableArray *_minArr;
    NSTimer *searchPer;
    int secondsCountDown; //倒计时总时长
    NSTimer *countDownTimer;
}
@property (nonatomic ,weak) UITableView *remindTableView;
@property (nonatomic ,strong) NSMutableArray *clockTimeArr;
@property (nonatomic ,weak) UIPickerView *timePicker;

@property (nonatomic ,weak) UIButton *selectButton;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;
@property (nonatomic ,strong) UIAlertController *searchVC;
@property (nonatomic ,strong) Remind *remindModel;
@property (nonatomic ,strong) UISwitch *phoneSwitch;
@property (nonatomic ,strong) UISwitch *messageSwitch;

@end

@implementation PhoneRemindViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sectionArr = [NSMutableArray array];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _funcArr = @[@[NSLocalizedString(@"phoneRemind", nil),NSLocalizedString(@"messageRemind", nil)],@[NSLocalizedString(@"lossRemind", nil),NSLocalizedString(@"findPer", nil)],@[NSLocalizedString(@"clockSet", nil)]];
    _imageArr = @[@[@"alert_call",@"alert_sms"],@[@"alert_lose",@"alert_find"],@[@"alert_clock"]];
    _clockArr = @[NSLocalizedString(@"clock1", nil),NSLocalizedString(@"clock2", nil),NSLocalizedString(@"clock3", nil)];
    
    [self getPickerViewDataSource];
    for (int i = 0; i < _funcArr.count; i ++) {
        SectionModel *sectionModel = [[SectionModel alloc] init];
        sectionModel.functionNameArr = (NSArray *)_funcArr[i];
        sectionModel.imageNameArr = (NSArray *)_imageArr[i];
        if (i == 2) {
            sectionModel.arrowImageName = @"all_next_icon";
            sectionModel.isExpanded = NO;
        }
        [_sectionArr addObject:sectionModel];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:NSLocalizedString(@"remindSet", nil)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    self.remindTableView.backgroundColor = [UIColor clearColor];
//    self.remindTableView.tableHeaderView = nil;
//    self.remindTableView.tableFooterView = nil;
    
    [self.myBleTool addObserver:self forKeyPath:@"connectState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.clockTimeArr = [NSMutableArray arrayWithArray:[self.myFmdbTool queryClockData]];
    if (self.clockTimeArr.count == 0) {
        for (int i = 0; i < 3; i ++) {
            ClockModel *model = [[ClockModel alloc] init];
            model.time = @"08:00";
            model.isOpen = NO;
            [self.clockTimeArr addObject:model];
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
    
    for (ClockModel *model in self.clockTimeArr) {
        [self.myFmdbTool insertClockModel:model];
    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change);
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
    [self.myBleTool removeObserver:self forKeyPath:@"connectState"];
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
        [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:self.clockTimeArr];
    }
    
}

- (void)findMyPeripheral:(UISwitch *)sender
{
    if (self.myBleTool.connectState == kBLEstateDidConnected) {
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"isFindMyPeripheral"];
    }else {
        [self presentAlertController:sender];
//        [sender setOn:!sender.on];
    }
    
}

- (void)searchPeripheral:(UIButton *)sender
{
    [self.myBleTool writeSearchPeripheralWithONorOFF:YES];
    [self presentViewController:self.searchVC animated:YES completion:nil];
    
    //设置倒计时总时长
    secondsCountDown = 10;//60秒倒计时
    //开始倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 timeFireMethod
}

-(void)timeFireMethod{
    //倒计时-1
    secondsCountDown--;
    //修改倒计时标签现实内容
    
    if (self.searchVC) {
        self.searchVC.message = [NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),secondsCountDown];
        //当倒计时到0时，做需要的操作，比如验证码过期不能提交
        if(secondsCountDown==0){
            [countDownTimer invalidate];
            [self.searchVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)SmsAndPhoneRemind:(UISwitch *)sender
{
    if (self.myBleTool.connectState == kBLEstateDidConnected) {
        self.remindModel = [[Remind alloc] init];
        if (sender == self.phoneSwitch) {
            self.remindModel.phone = self.phoneSwitch.on;
            [[NSUserDefaults standardUserDefaults] setBool:self.phoneSwitch.on forKey:@"isRemindPhone"];
        }
        if (sender == self.messageSwitch) {
            self.remindModel.message = self.messageSwitch.on;
            [[NSUserDefaults standardUserDefaults] setBool:self.messageSwitch.on forKey:@"isRemindMessage"];
        }
        
        [self.myBleTool writePhoneAndMessageRemindToPeripheral:self.remindModel];
    }else {
        
        [self presentAlertController:sender];
    }
}

- (void)presentAlertController:(UISwitch *)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"connectPerAndSet", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac = [UIAlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [sender setOn:!sender.on];
    }];
    [vc addAction:ac];
    [self presentViewController:vc animated:YES completion:nil];
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
    ClockModel *model = self.clockTimeArr[self.selectButton.tag];
    model.time = [NSString stringWithFormat:@"%@:%@",hour ,min];
    [self.clockTimeArr replaceObjectAtIndex:self.selectButton.tag withObject:model];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        SectionModel *model = _sectionArr[section];
        return model.functionNameArr.count;
    }else if (section == 1) {
        SectionModel *model = _sectionArr[section];
        return model.functionNameArr.count;
    }else if (section == 2) {
        SectionModel *model = _sectionArr[section];
        return model.isExpanded ? 3 : 0;
    }
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhoneRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneRemindCell"];
    NSArray *imgArr = _imageArr[indexPath.section];
    NSArray *funArr = _funcArr[indexPath.section];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.iconImageView.image = [UIImage imageNamed:imgArr[indexPath.row]];
            cell.functionName.text = funArr[indexPath.row];
            cell.timeButton.hidden = YES;
//            cell.timeSwitch.tag = indexPath.row + 100;
            BOOL isMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"];
            BOOL isPhone = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"];
            if (indexPath.row == 0) {
                [cell.timeSwitch setOn:isPhone];
                self.phoneSwitch = cell.timeSwitch;
            }
            if (indexPath.row == 1) {
                [cell.timeSwitch setOn:isMessage];
                self.messageSwitch = cell.timeSwitch;
            }
            [cell.timeSwitch addTarget:self action:@selector(SmsAndPhoneRemind:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 1:
        {
            cell.functionName.text = funArr[indexPath.row];
            cell.iconImageView.image = [UIImage imageNamed:imgArr[indexPath.row]];
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
                    cell.timeButton.hidden = YES;
                }
                    break;
                case 1:
                {
                    cell.timeButton.hidden = YES;
                    cell.timeSwitch.hidden = YES;
                    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    searchButton.frame = CGRectMake(self.view.frame.size.width - 150, 12, 140, 20);
                    searchButton.backgroundColor = [UIColor clearColor];
                    [searchButton setTitle:NSLocalizedString(@"startSearch", nil) forState:UIControlStateNormal];
                    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
                    [searchButton addTarget:self action:@selector(searchPeripheral:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:searchButton];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            cell.functionName.text = _clockArr[indexPath.row];
            if (self.clockTimeArr.count == 0) {
                [cell.timeButton setTitle:@"08:00" forState:UIControlStateNormal];
                [cell.timeSwitch setOn:NO];
                [cell.timeButton setTitleColor:cell.timeSwitch.on ? [UIColor whiteColor] : [UIColor grayColor] forState:UIControlStateNormal];
            }else {
                ClockModel *model = self.clockTimeArr[indexPath.row];
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
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    ClockModel *model = self.clockTimeArr[indexPath.row];
                    model.isOpen = weakCell.timeSwitch.on;
                    [self.clockTimeArr replaceObjectAtIndex:indexPath.row withObject:model];
                    [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:self.clockTimeArr];
                    [self.remindTableView reloadData];
                }else {
//                    [weakCell.timeSwitch setOn:!weakCell.timeSwitch.on];
                    [weakSelf presentAlertController:weakCell.timeSwitch];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44 * self.view.frame.size.width / 320;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 16;
    }else if (section == 1) {
        return 16;
    }else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 16)];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        return view;
    }
    
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 16)];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        return view;
    }
    
    if (section == 2) {
        PhoneRemindView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"phoneHead"];
        view.backgroundColor = [UIColor redColor];
        
        SectionModel *sectionModel = _sectionArr.lastObject;
        view.model = sectionModel;
        view.expandCallback = ^(BOOL isExpanded) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                     withRowAnimation:UITableViewRowAnimationFade];
        };
        
        return view;
    }
    
    return nil;
}

#pragma mark - receiveDelegate
- (void)receivePairWitheModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypePairSuccess) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataFail) {
            if (manridyModel.pairSuccess == NO) {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"配对失败，请重试。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAC = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.phoneSwitch setOn:NO];
                    [self.messageSwitch setOn:NO];
                    [[NSUserDefaults standardUserDefaults] setBool:self.phoneSwitch.on forKey:@"isRemindPhone"];
                    [[NSUserDefaults standardUserDefaults] setBool:self.messageSwitch.on forKey:@"isRemindMessage"];
                }];
                [vc addAction:okAC];
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }
}

- (void)receiveSetClockDataWithModel:(manridyModel *)manridyModel
{
//    self.clockTimeArr = manridyModel.clockModelArr;
//    [self.remindTableView reloadData];
}

- (void)receiveSearchFeedback
{
    [self.searchVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 懒加载
- (UITableView *)remindTableView
{
    if (!_remindTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 16)];
        view.tableFooterView = [[UIView alloc] init];
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

- (UIAlertController *)searchVC
{
    if (!_searchVC) {
        _searchVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tips", nil) message:[NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),10] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ac = [UIAlertAction actionWithTitle:NSLocalizedString(@"stopSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.myBleTool writeSearchPeripheralWithONorOFF:NO];
        }];
        [_searchVC addAction:ac];
    }
    
    return _searchVC;
}

- (NSMutableArray *)clockTimeArr
{
    if (!_clockTimeArr) {
        _clockTimeArr = [NSMutableArray array];
    }
    
    return _clockTimeArr;
}

@end
