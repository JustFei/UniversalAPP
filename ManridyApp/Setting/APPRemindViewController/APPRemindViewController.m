//
//  APPRemindViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/6/20.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "APPRemindViewController.h"
#import "APPRemindTableViewCell.h"

static NSString *const APPRemindTableViewCellID = @"APPRemindTableViewCell";

@interface APPRemindViewController () < UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, strong) UITableView *appTableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation APPRemindViewController

- (void)viewDidLoad
{
    self.title = @"应用提醒";
//    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
//    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
//    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"保存", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
    self.appTableView.backgroundColor = CLEAR_COLOR;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(setPairNoti:) name:GET_PAIR object:nil];
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
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
 */

- (void)saveAction
{
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
//        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"设备尚未连接";
        [hud hideAnimated:YES afterDelay:2];
    }else {
        Remind *model = [[Remind alloc] init];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"]) {
            model.phone = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindPhone"];
        }else {
            model.phone = NO;
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"]) {
            model.message = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemindMessage"];
        }else {
            model.message = NO;
        }
        model.wechat = ((APPRemindModel *)self.dataArr[0]).isSelect;
        model.qq = ((APPRemindModel *)self.dataArr[1]).isSelect;
        model.whatsApp = ((APPRemindModel *)self.dataArr[2]).isSelect;
        model.facebook = ((APPRemindModel *)self.dataArr[3]).isSelect;
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        [[BLETool shareInstance] writePhoneAndMessageRemindToPeripheral:model];
    }
}

- (void)setPairNoti:(NSNotification *)noti
{
    [self.hud hideAnimated:YES];
    manridyModel *model = [noti object];
    if (model.isReciveDataRight) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"保存成功";
        [hud hideAnimated:YES afterDelay:2];
        [self saveSetting];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        if (model.pairSuccess) {
//            MDToast *sucToast = [[MDToast alloc] initWithText:@"保存成功" duration:1.5];
//            [sucToast show];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"保存成功";
            [hud hideAnimated:YES afterDelay:2];
            [self saveSetting];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"保存失败";
            [hud hideAnimated:YES afterDelay:2];
        }
    }
}

- (void)saveSetting
{
    //保存选项至本地
    NSMutableArray *saveMutArr = [NSMutableArray array];
    for (APPRemindModel *model in self.dataArr) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        [saveMutArr addObject:data];
    }
    //这里只能保存不可变数组，所以要转换
    NSArray *saveArr = [NSArray arrayWithArray:saveMutArr];
    [[NSUserDefaults standardUserDefaults] setObject:saveArr forKey:APP_REMIND_SETTING];
}

#pragma mark - UITableVIewDelegate
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
    APPRemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:APPRemindTableViewCellID];
    APPRemindModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    
    cell.appRemindSelectButtonClickBlock = ^(BOOL select) {
        model.isSelect = select;
        [self.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    APPRemindModel *model = self.dataArr[indexPath.row];
    model.isSelect = !model.isSelect;
    [self.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}


#pragma mark - lazy
- (UITableView *)appTableView
{
    if (!_appTableView) {
        _appTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_appTableView registerClass:NSClassFromString(APPRemindTableViewCellID) forCellReuseIdentifier:APPRemindTableViewCellID];
        _appTableView.delegate = self;
        _appTableView.dataSource = self;
        _appTableView.tableFooterView = [UIView new];
        
        [self.view addSubview:_appTableView];
        [_appTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    return _appTableView;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:APP_REMIND_SETTING]) {
            NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:APP_REMIND_SETTING];
            NSMutableArray *mutArr = [NSMutableArray array];
            for (NSData *data in arr) {
                APPRemindModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [mutArr addObject:model];
            }
            _dataArr = mutArr;
        }else {
            NSMutableArray *mutArr = [NSMutableArray array];
            NSArray *imageNameArr = @[@"appremind_wechat", @"appremind_qq", @"appremind_whatsapp", @"appremind_facebook"];
            NSArray *nameArr = @[@"微信", @"QQ", @"WhatsApp", @"Facebook"];
            for (int index = 0; index < imageNameArr.count; index ++) {
                APPRemindModel *model = [[APPRemindModel alloc] init];
                model.imageName = imageNameArr[index];
                model.name = nameArr[index];
                model.isSelect = NO;
                [mutArr addObject:model];
            }
            _dataArr = mutArr;
        }
    }
    
    return _dataArr;
}

@end
