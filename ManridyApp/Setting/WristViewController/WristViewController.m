//
//  WristViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/7/3.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "WristViewController.h"
#import "SedentaryReminderTableViewCell.h"

static NSString * const LoseReminderTableViewCellID = @"LoseReminderTableViewCell";

@interface WristViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation WristViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"翻腕亮屏";
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveLoseAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.tableView.backgroundColor = CLEAR_COLOR;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(wheatherSuccess:) name:WRIST_SETTING_NOTI object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveLoseAction
{
    if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        [self.hud showAnimated:YES];
        
        [[BleManager shareInstance] writeWristFunWithOff:((SedentaryReminderModel *)self.dataArr.firstObject).switchIsOpen];
    }
}

- (void)wheatherSuccess:(NSNotification *)noti
{
    BOOL isFirst = noti.userInfo[@"success"];//success 里保存这设置是否成功
    NSLog(@"isFirst:%d",isFirst);
    //这里不能直接写 if (isFirst),必须如下写法
    if (isFirst == 1) {
        //保存设置到本地
        SedentaryReminderModel *model = self.dataArr.firstObject;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:WRIST_SETTING];
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
        [sucToast show];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        MDToast *sucToast = [[MDToast alloc] initWithText:@"保存失败" duration:1.5];
        [sucToast show];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SedentaryReminderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoseReminderTableViewCellID];
    
    SedentaryReminderModel *model = self.dataArr[indexPath.row];
    cell.switchChangeBlock = ^{
        model.switchIsOpen = !model.switchIsOpen;
        [tableView reloadData];
    };
    
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *lineView = [UIView new];
//    lineView.backgroundColor = CLEAR_COLOR;
//
//    return lineView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 8;
//}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:VIEW_CONTROLLER_BOUNDS style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(@"SedentaryReminderTableViewCell") forCellReuseIdentifier:LoseReminderTableViewCellID];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = nil;
        /** 偏移掉表头的 64 个像素 */
        //_tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:WRIST_SETTING]) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:WRIST_SETTING];
            SedentaryReminderModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            _dataArr = @[model];
        }else {
            SedentaryReminderModel *model = [[SedentaryReminderModel alloc] init];
            model.title = @"开启翻腕提醒";
            model.switchIsOpen = NO;
            model.whetherHaveSwitch = YES;
            model.subTitle = @"抬手翻腕时亮屏";
            _dataArr = @[model];
        }
    }
    
    return _dataArr;
}

@end
