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
#import "manridyBleDevice.h"


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
@property (nonatomic ,strong) AlertTool *searchVC;
@property (nonatomic ,strong) Remind *remindModel;
@property (nonatomic ,strong) UISwitch *phoneSwitch;
@property (nonatomic ,strong) UISwitch *messageSwitch;
@property (nonatomic ,strong) SectionModel *sedentaryModel;//用于修改开启久坐的model
@property (nonatomic ,strong) NSString *pickerString;
@property (nonatomic ,strong) SedentaryModel *sedModel; //用于查找本地保存的记录信息

@end

@implementation PhoneRemindViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sectionArr = [NSMutableArray array];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
        _funcArr = @[@[NSLocalizedString(@"phoneRemind", nil),NSLocalizedString(@"messageRemind", nil),NSLocalizedString(@"lossRemind", nil),NSLocalizedString(@"findPer", nil)],@[NSLocalizedString(@"sedentaryRemind", nil),NSLocalizedString(@"beginTime", nil),NSLocalizedString(@"endTime", nil),NSLocalizedString(@"unDisturb", nil)],@[NSLocalizedString(@"clockSet", nil)]];
        _imageArr = @[@[@"alert_call",@"alert_sms",@"alert_lose",@"alert_find"],@[@"alert_sedentary"],@[@"alert_clock"]];
    
    _clockArr = @[NSLocalizedString(@"clock1", nil),NSLocalizedString(@"clock2", nil),NSLocalizedString(@"clock3", nil)];
    
    //查找久坐提醒的本地存储
    NSArray *sedArr = [self.myFmdbTool querySedentary];
    if (sedArr.count == 0 && self.myBleTool.connectState == kBLEstateDidConnected) {
        //保存一个初始的状态
        [self.myFmdbTool insertSedentaryData:self.sedModel];
    }else {
        self.sedModel = sedArr.firstObject;
    }
    
    [self getPickerViewDataSource];
    for (int i = 0; i < _funcArr.count; i ++) {
        SectionModel *sectionModel = [[SectionModel alloc] init];
        sectionModel.functionNameArr = (NSArray *)_funcArr[i];
        sectionModel.imageNameArr = (NSArray *)_imageArr[i];
        if (i == 1) {
            if (self.sedModel.sedentaryAlert) {
                sectionModel.isExpanded = YES;
            }else {
                sectionModel.isExpanded = NO;
            }
            self.sedentaryModel = sectionModel;
        }
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
        if (self.myBleTool.connectState == kBLEstateDidConnected) {
            [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:self.clockTimeArr];
        }
    }
}

- (void)findMyPeripheral:(UISwitch *)sender
{
    if (self.myBleTool.connectState == kBLEstateDidConnected) {
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"isFindMyPeripheral"];
        [self.myBleTool writePeripheralShakeWhenUnconnectWithOforOff:sender.on];
    }else {
        [self presentAlertController:sender];
        [self.myBleTool writePeripheralShakeWhenUnconnectWithOforOff:!sender.on];
    }
    
}

- (void)searchPeripheral:(UIButton *)sender
{
    [self.myBleTool writeSearchPeripheralWithONorOFF:YES];
    [self.searchVC show];
    //[self presentViewController:self.searchVC animated:YES completion:nil];
    
    //设置倒计时总时长
    secondsCountDown = 10;//10秒倒计时
    //开始倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 timeFireMethod
}

//打开久坐提醒
- (void)openSedentary:(UISwitch *)sender
{
    if (sender.tag == 1000) {
        if (!sender.on) {
            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                [sender setOn:NO];
                self.sedentaryModel.isExpanded = NO;
                self.sedModel.sedentaryAlert = NO;
                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                [self.remindTableView reloadSections:[NSIndexSet indexSetWithIndex:1]withRowAnimation:UITableViewRowAnimationFade];
                //写入数据库
                [self.myFmdbTool modifySedentaryData:self.sedModel];
            }else {
                [self presentAlertController:sender];
            }
        }else {
            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                [sender setOn:YES];
                self.sedentaryModel.isExpanded = YES;
                self.sedModel.sedentaryAlert = YES;
                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                [self.remindTableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                    withRowAnimation:UITableViewRowAnimationFade];
                //写入数据库
                [self.myFmdbTool modifySedentaryData:self.sedModel];
            }else {
                [self presentAlertController:sender];
            }
        }
    }
}

- (void)openUnDisturb:(UISwitch *)sender
{
    if (sender.tag == 1001) {
        if (!sender.on) {
            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                [sender setOn:NO];
                //关闭勿扰模式
                self.sedModel.unDisturb = NO;
                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                //写入数据库
                [self.myFmdbTool modifySedentaryData:self.sedModel];
            }else {
                [self presentAlertController:sender];
            }
        }else {
            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                [sender setOn:YES];
                //打开勿扰模式
                self.sedModel.unDisturb = YES;
                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                //写入数据库
                [self.myFmdbTool modifySedentaryData:self.sedModel];
            }else {
                [self presentAlertController:sender];
            }
        }
    }
}

-(void)timeFireMethod{
    //倒计时-1
    secondsCountDown--;
    //修改倒计时标签现实内容
    DLog(@"%d",secondsCountDown);
    if (self.searchVC) {
        if (SYSTEM_VERSION >= 8.0) {
            self.searchVC.alertController.message = [NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),secondsCountDown];
        }else {
            self.searchVC.alertView.message = [NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),secondsCountDown];
        }
        //self.searchVC.message = [NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),secondsCountDown];
        //当倒计时到0时，做需要的操作
        if(secondsCountDown==0){
            [countDownTimer invalidate];
            secondsCountDown = 10;
            [self.searchVC dismissFromSuperview];
            //[self.searchVC dismissViewControllerAnimated:YES completion:nil];
            self.searchVC = nil;
        }
    }
}

- (void)SmsAndPhoneRemind:(UISwitch *)sender
{
    if (self.myBleTool.connectState == kBLEstateDidConnected) {
        self.remindModel = [[Remind alloc] init];
        if (sender == self.phoneSwitch) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"]) {
                self.remindModel.message = YES;
            }
            self.remindModel.phone = self.phoneSwitch.on;
            [[NSUserDefaults standardUserDefaults] setBool:self.phoneSwitch.on forKey:@"isRemindPhone"];
        }
        if (sender == self.messageSwitch) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"]) {
                self.remindModel.phone = YES;
            }
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
    AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"connectPerAndSet", nil) style:UIAlertControllerStyleAlert];
    [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        [sender setOn:!sender.on];
    }]];
    [aTool show];
}

- (void)startTimeChoose:(UIButton *)sender
{
    self.pickerString = sender.titleLabel.text;
    AlertTool *aTool ;
    if (iPhone4) {
        aTool = [AlertTool alertWithTitle:@"" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone5) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone6) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone6p) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }
    [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:AlertToolStyleDefault handler:nil]];
    [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        [sender setTitle:self.pickerString forState:UIControlStateNormal];
        //写入久坐提醒的开始时间
        self.sedModel.sedentaryStartTime = self.pickerString;
        [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
        //写入数据库
        [self.myFmdbTool modifySedentaryData:self.sedModel];
    }]];

    UIDatePicker *startTimePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.center.x - (self.view.frame.size.width - 50) / 2, self.view.frame.size.width - 50, self.view.frame.size.height / 3)];
    startTimePickerView.tag = 10000;
    startTimePickerView.datePickerMode = UIDatePickerModeTime;
    //[startTimePickerView setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    // 设置时区
    [startTimePickerView setTimeZone:[NSTimeZone localTimeZone]];
    // 设置当前显示时间
    NSDate *currentDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    if (self.pickerString) {
        currentDate = [formatter dateFromString:self.pickerString];
    }else {
        currentDate = [formatter dateFromString:@"09:00"];
    }
    [startTimePickerView setDate:currentDate];
    // 当值发生改变的时候调用的方法
    [startTimePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [aTool addSubviewToAlert:startTimePickerView];
    
   [aTool show];
}

- (void)endTimeChoose:(UIButton *)sender
{
    self.pickerString = sender.titleLabel.text;
    AlertTool *aTool ;
    if (iPhone4) {
        aTool = [AlertTool alertWithTitle:@"" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone5) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone6) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }else if (iPhone6p) {
        aTool = [AlertTool alertWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil style:UIAlertControllerStyleActionSheet];
    }
    
    [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:AlertToolStyleDefault handler:nil]];
    [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        
        if (self.myBleTool.connectState == kBLEstateDidConnected) {
            [sender setTitle:self.pickerString forState:UIControlStateNormal];
            //写入久坐提醒的结束时间
            self.sedModel.sedentaryEndTime = self.pickerString;
            [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
            //写入数据库
            [self.myFmdbTool modifySedentaryData:self.sedModel];
        }
        
    }]];

    UIDatePicker *startTimePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.center.x - (self.view.frame.size.width - 50) / 2, self.view.frame.size.width - 50, self.view.frame.size.height / 3)];
    startTimePickerView.tag = 10000;
    startTimePickerView.datePickerMode = UIDatePickerModeTime;
    //[startTimePickerView setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    // 设置时区
    [startTimePickerView setTimeZone:[NSTimeZone localTimeZone]];
    // 设置当前显示时间
    NSDate *currentDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    if (self.pickerString) {
        currentDate = [formatter dateFromString:self.pickerString];
    }else {
        currentDate = [formatter dateFromString:@"18:00"];
    }
    [startTimePickerView setDate:currentDate];
    // 当值发生改变的时候调用的方法
    [startTimePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [aTool addSubviewToAlert:startTimePickerView];
    
    [aTool show];
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
        if (self.haveSedentary) {
            return self.sedentaryModel.isExpanded ? 3 : 1;
        }else {
            return 0;
        }
        
    }else {
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
            cell.timeSwitch.hidden = NO;
            cell.iconImageView.hidden = NO;
            cell.iconImageView.image = [UIImage imageNamed:imgArr[indexPath.row]];
            cell.functionName.text = funArr[indexPath.row];
            cell.timeButton.hidden = YES;
            cell.startLabel.hidden = YES;
            cell.startButton.hidden = YES;
            cell.endLabel.hidden = YES;
            cell.endButton.hidden = YES;
            cell.bolanghaolabel.hidden = YES;
//            cell.timeSwitch.tag = indexPath.row + 100;
            BOOL isMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"];
            BOOL isPhone = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"];
            
            switch (indexPath.row) {
                case 0:     //来电提醒
                {
                    [cell.timeSwitch setOn:isPhone];
                    self.phoneSwitch = cell.timeSwitch;
                    [cell.timeSwitch addTarget:self action:@selector(SmsAndPhoneRemind:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 1:     //短信提醒
                {
                    [cell.timeSwitch setOn:isMessage];
                    self.messageSwitch = cell.timeSwitch;
            
                    [cell.timeSwitch addTarget:self action:@selector(SmsAndPhoneRemind:) forControlEvents:UIControlEventValueChanged];
                }
                    break;
                case 2:     //防丢提醒
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
                case 3:     //查找设备
                {
                    cell.timeSwitch.hidden = YES;
                    cell.endButton.hidden = NO;
                    [cell.endButton addTarget:self action:@selector(searchPeripheral:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.endButton setTitle:NSLocalizedString(@"startSearch", nil) forState:UIControlStateNormal];
                }
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell.timeButton.hidden = YES;
            cell.halvingLine.hidden = YES;
            cell.startLabel.hidden = YES;
            cell.startButton.hidden = YES;
            cell.endLabel.hidden = YES;
            cell.endButton.hidden = YES;
            cell.bolanghaolabel.hidden = YES;
            switch (indexPath.row) {
                case 0:
                {
                    cell.functionName.text = funArr[indexPath.row];
                    DLog(@"1-0 == %@",cell.functionName.text);
                    cell.iconImageView.image = [UIImage imageNamed:imgArr[indexPath.row]];
                    cell.timeSwitch.hidden = NO;
                    [cell.timeSwitch setOn:self.sedModel.sedentaryAlert];
//                    [cell.timeSwitch addTarget:self action:@selector(openSedentary:) forControlEvents:UIControlEventValueChanged];
                    __weak typeof(cell) weakCell = cell;
                    cell.clockSwitchValueChangeBlock = ^ {
                        if (!weakCell.timeSwitch.on) {
                            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                                [weakCell.timeSwitch setOn:NO];
                                self.sedentaryModel.isExpanded = NO;
                                self.sedModel.sedentaryAlert = NO;
                                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                                [self.remindTableView reloadSections:[NSIndexSet indexSetWithIndex:1]withRowAnimation:UITableViewRowAnimationFade];
                                //写入数据库
                                [self.myFmdbTool modifySedentaryData:self.sedModel];
                            }else {
                                [self presentAlertController:weakCell.timeSwitch];
                            }
                        }else {
                            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                                [weakCell.timeSwitch setOn:YES];
                                self.sedentaryModel.isExpanded = YES;
                                self.sedModel.sedentaryAlert = YES;
                                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                                [self.remindTableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                    withRowAnimation:UITableViewRowAnimationFade];
                                //写入数据库
                                [self.myFmdbTool modifySedentaryData:self.sedModel];
                            }else {
                                [self presentAlertController:weakCell.timeSwitch];
                            }
                        }
                    };
                    cell.timeSwitch.tag = 1000;
                }
                    break;
                case 1:
                {
                    cell.timeSwitch.hidden = YES;
                    cell.functionName.text = @"";
                    cell.startLabel.hidden = NO;
                    cell.startButton.hidden = NO;
                    [cell.startButton setTitle:self.sedModel.sedentaryStartTime forState:UIControlStateNormal];
                    cell.endLabel.hidden = NO;
                    cell.endButton.hidden = NO;
                    [cell.endButton setTitle:self.sedModel.sedentaryEndTime forState:UIControlStateNormal];
                    cell.bolanghaolabel.hidden = NO;
                    cell.bolanghaolabel.text = @"~";
#warning cancel start time and end time
                    //[cell.startButton addTarget:self action:@selector(startTimeChoose:) forControlEvents:UIControlEventTouchUpInside];
                    //[cell.endButton addTarget:self action:@selector(endTimeChoose:) forControlEvents:UIControlEventTouchUpInside];
                }
                    break;
                case 2:
                {
                    cell.bolanghaolabel.hidden = NO;
                    cell.bolanghaolabel.text = [NSString stringWithFormat:@"%@~%@",self.sedModel.disturbStartTime,self.sedModel.disturbEndTime];
                    [cell.bolanghaolabel setFont:[UIFont systemFontOfSize:13]];
                    [cell.bolanghaolabel setTextColor:[UIColor whiteColor]];
                    cell.iconImageView.hidden = YES;
                    cell.functionName.text = funArr[indexPath.row + 1];
                    NSLog(@"1-2 == %@",cell.functionName.text);
                    cell.timeSwitch.hidden = NO;
                    [cell.timeSwitch setOn:self.sedModel.unDisturb];
//                    [cell.timeSwitch addTarget:self action:@selector(openUnDisturb:) forControlEvents:UIControlEventValueChanged];
                    __weak typeof(cell) weakCell = cell;
                    cell.clockSwitchValueChangeBlock = ^ {
                        if (!weakCell.timeSwitch.on) {
                            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                                [weakCell.timeSwitch setOn:NO];
                                //关闭勿扰模式
                                self.sedModel.unDisturb = NO;
                                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                                //写入数据库
                                [self.myFmdbTool modifySedentaryData:self.sedModel];
                            }else {
                                [self presentAlertController:weakCell.timeSwitch];
                            }
                        }else {
                            if (self.myBleTool.connectState == kBLEstateDidConnected) {
                                [weakCell.timeSwitch setOn:YES];
                                //打开勿扰模式
                                self.sedModel.unDisturb = YES;
                                [self.myBleTool writeSedentaryAlertWithSedentaryModel:self.sedModel];
                                //写入数据库
                                [self.myFmdbTool modifySedentaryData:self.sedModel];
                            }else {
                                [self presentAlertController:weakCell.timeSwitch];
                            }
                        }
                    };
                    cell.timeSwitch.tag = 1001;
                }
                    break;
                    
                default:
                    break;
                }
        }
            break;
        case 2:     //闹钟
        {
            cell.startLabel.hidden = YES;
            cell.startButton.hidden = YES;
            cell.endLabel.hidden = YES;
            cell.endButton.hidden = YES;
            cell.bolanghaolabel.hidden = YES;
            cell.iconImageView.hidden = YES;
            cell.functionName.text = _clockArr[indexPath.row];
            cell.halvingLine.hidden = YES;
            cell.timeButton.hidden = NO;
            cell.timeSwitch.hidden = NO;
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
            
            cell.clockSwitchValueChangeBlock =^{
                if (self.myBleTool.connectState == kBLEstateDidConnected) {
                    ClockModel *model = self.clockTimeArr[indexPath.row];
                    model.isOpen = weakCell.timeSwitch.on;
                    [self.clockTimeArr replaceObjectAtIndex:indexPath.row withObject:model];
                    [self.myBleTool writeClockToPeripheral:ClockDataSetClock withClockArr:self.clockTimeArr];
                    [self.remindTableView reloadData];
                }else {
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
        return 0;
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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 1)];
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


#pragma mark - datePickerDelegate
- (void)datePickerValueChanged:(UIDatePicker *)sender
{
    DLog(@"%@",sender.date);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    self.pickerString = [formatter stringFromDate:sender.date];
}

#pragma mark - receiveDelegate
- (void)receivePairWitheModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypePairSuccess) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataFail) {
            if (manridyModel.pairSuccess == NO) {
                AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:@"配对失败，请重试。" style:UIAlertControllerStyleAlert];
                [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
                    [self.phoneSwitch setOn:NO];
                    [self.messageSwitch setOn:NO];
                    [[NSUserDefaults standardUserDefaults] setBool:self.phoneSwitch.on forKey:@"isRemindPhone"];
                    [[NSUserDefaults standardUserDefaults] setBool:self.messageSwitch.on forKey:@"isRemindMessage"];
                }]];
                [aTool show];
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
    [countDownTimer invalidate];
    secondsCountDown = 10;
    [self.searchVC dismissFromSuperview];
    //[self.searchVC dismissViewControllerAnimated:YES completion:nil];
    self.searchVC = nil;
}

#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

#pragma mark - 懒加载
- (UITableView *)remindTableView
{
    if (!_remindTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height  - 60)];
        view.tableFooterView = [[UIView alloc] init];
        view.allowsSelection = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan)];
        [view addGestureRecognizer:tap];
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
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

- (AlertTool *)searchVC
{
    if (!_searchVC) {
        _searchVC = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:[NSString stringWithFormat:NSLocalizedString(@"searchingPer", nil),10] style:UIAlertControllerStyleAlert];
        AlertAction *ac = [AlertAction actionWithTitle:NSLocalizedString(@"stopSearch", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
            [countDownTimer invalidate];
            secondsCountDown = 10;
            [self.myBleTool writeSearchPeripheralWithONorOFF:NO];
            _searchVC = nil;
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

- (SedentaryModel *)sedModel
{
    if (!_sedModel) {
        _sedModel = [[SedentaryModel alloc] init];
        _sedModel.sedentaryAlert = NO;
        _sedModel.unDisturb = NO;
        _sedModel.timeInterval = 60;
        _sedModel.sedentaryStartTime = @"09:00";
        _sedModel.sedentaryEndTime = @"18:00";
        _sedModel.disturbStartTime = @"12:00";
        _sedModel.disturbEndTime = @"14:00";
        _sedModel.stepInterval = 100;
    }
    
    return _sedModel;
}

- (SectionModel *)sedentaryModel
{
    if (!_sedentaryModel) {
        _sedentaryModel = [[SectionModel alloc] init];
    }
    
    return _sedentaryModel;
}

@end
