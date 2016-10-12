//
//  BindPeripheralViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BindPeripheralViewController.h"
#import "BLETool.h"
#import "manridyBleDevice.h"
#import "MBProgressHUD.h"

@interface BindPeripheralViewController () <UITableViewDelegate ,UITableViewDataSource ,BleDiscoverDelegate ,BleConnectDelegate ,UIAlertViewDelegate>
{
    NSMutableArray *_dataArr;
    NSInteger index;
    BOOL _isConnected;
}

@property (nonatomic ,weak) UIView *downView;
@property (nonatomic ,weak) UITableView *peripheralList;

@property (nonatomic ,weak) UIButton *bindButton;

@property (nonatomic ,weak) UIButton *disbindButton;

@property (nonatomic ,strong) UIImageView *lockImageView;

@property (nonatomic ,weak) UIImageView *connectImageView;

@property (nonatomic ,strong) UIImageView *refreshImageView;

@property (nonatomic ,strong) UILabel *bindStateLabel;

@property (nonatomic ,strong) UILabel *perNameLabel;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) MBProgressHUD *hud;

@end

@implementation BindPeripheralViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArr = [NSMutableArray array];
    
    index = -1;
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.discoverDelegate = self;
    self.myBleTool.connectDelegate = self;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchPeripheral)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    BOOL isBinded = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    if (isBinded) {
        [self createBindView];
    }else {
       [self creatUnBindView];
    }
    
    self.navigationItem.title = @"设备绑定";
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    UIImageView *bluetoothImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 80, self.view.frame.size.width * 120 / 320, 30, 46)];
    [self.view addSubview:bluetoothImageView];
    [bluetoothImageView setImage:[UIImage imageNamed:@"ble_icon"]];
    
    self.lockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x + 50, self.view.frame.size.width * 120 / 320, 30, 46)];
    [self.view addSubview:self.lockImageView];
    [self.lockImageView setImage:[UIImage imageNamed:@"ble_lock_oper"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 261 / 320, self.view.frame.size.width, 13)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBindView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.connectImageView setImage:[UIImage imageNamed:@"ble_connect"]];
    
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    [self.refreshImageView setHidden:YES];
    
    [self.bindStateLabel setText:@"已绑定设备"];
    
    [self.perNameLabel setHidden:NO];
    [self.perNameLabel setAlpha:0.5];
    [self.perNameLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralName"]];
    
    [self.disbindButton setHidden:NO];
    [self.disbindButton setAlpha:1];
}

- (void)creatUnBindView
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.connectImageView setImage: [UIImage imageNamed:@"ble_break_icon"]];
    
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    [self.refreshImageView setHidden:NO];
    
    [self.bindStateLabel setText:@"未绑定设备"];
}

#pragma mark - Action
- (void)searchPeripheral
{
    NSLog(@"search peripheral.");
    
    [self deletAllRowsAtTableView];
    
    [self.myBleTool scanDevice];
    
    
    [self.peripheralList setHidden:NO];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.refreshImageView.alpha = 0;
        [self.refreshImageView setHidden:YES];
        
        [self.bindButton setHidden:NO];
        self.bindButton.alpha = 1;
    }];
}

- (void)bindPeripheral
{
    if (index != -1) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        manridyBleDevice *device = _dataArr[index];
        [self.myBleTool connectDevice:device];
        self.myBleTool.isReconnect = YES;
        _isConnected = YES;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.mode = MBProgressHUDModeIndeterminate;
        [self.hud.label setText:@"正在连接设备..."];
    }
}

- (void)disbindPeripheral
{
    _isConnected = NO;
    self.myBleTool.isReconnect = NO;
    [self.myBleTool unConnectDevice];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isBind"];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已成功解除绑定" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    view.tag = 102;
    [view show];
}

- (void)deletAllRowsAtTableView
{
    //移除cell
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int row = 0; row < _dataArr.count; row ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    [_dataArr removeAllObjects];
    [self.peripheralList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bindcell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bindcell"];
    }
    manridyBleDevice *device = _dataArr[indexPath.row];
    
    cell.textLabel.text = device.deviceName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isConnected) {
        index = indexPath.row;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
        {
            [self deletAllRowsAtTableView];
            [self.peripheralList setHidden:YES];
            
            [UIView animateWithDuration:1 animations:^{
                [self.disbindButton setHidden:NO];
                self.disbindButton.alpha = 1;
               
                self.bindButton.alpha = 0;
                [self.bindButton setHidden:YES];
                
                [self.perNameLabel setHidden:NO];
                [self.perNameLabel setText:self.myBleTool.currentDev.deviceName];
                [self.perNameLabel setAlpha:1];
                
                [self.bindStateLabel setText:@"已绑定设备"];
                
                [self.connectImageView setImage:[UIImage imageNamed:@"ble_connect"]];
            }];
            
            
        }
            break;
        case 101:
        {
            [self deletAllRowsAtTableView];
            [self.peripheralList setHidden:YES];
            
            [UIView animateWithDuration:1 animations:^{
                [self.refreshImageView setHidden:NO];
                
                self.bindButton.alpha = 0;
                [self.bindButton setHidden:YES];
            }];
        }
            break;
        case 102:
        {
            if (!_isConnected) {
                [self deletAllRowsAtTableView];
                [self.peripheralList setHidden:YES];
                
                [UIView animateWithDuration:1 animations:^{
                    self.disbindButton.alpha = 0;
                    [self.disbindButton setHidden:YES];
                    
                    self.refreshImageView.alpha = 1;
                    [self.refreshImageView setHidden:NO];
                    
                    self.bindButton.alpha = 0;
                    [self.bindButton setHidden:YES];
                    
                    self.perNameLabel.alpha = 0;
                    [self.perNameLabel setHidden:YES];
                    
                    [self.bindStateLabel setText:@"未绑定设备"];
                    
                    [self.connectImageView setImage:[UIImage imageNamed:@"ble_break_icon"]];
                }];
            }else {
                [self.myBleTool connectDevice:self.myBleTool.currentDev];
            }
        }
        default:
            break;
    }
}

#pragma mark - BleDiscoverDelegate
- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device
{
    if (![_dataArr containsObject:device]) {
        [_dataArr addObject:device];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count - 1 inSection:0];
        [indexPaths addObject: indexPath];
        [self.peripheralList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - BleConnectDelegate
//这里我使用peripheral.identifier作为设备的唯一标识，没有使用mac地址，如果出现id变化导致无法连接的情况，请转成用mac地址作为唯一标识。
- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device
{
    [self.hud hideAnimated:YES];
    
    [self.myBleTool stopScan];
    
    [[NSUserDefaults standardUserDefaults] setValue:device.peripheral.identifier.UUIDString forKey:@"bindPeripheralID"];
    [[NSUserDefaults standardUserDefaults] setValue:device.deviceName forKey:@"bindPeripheralName"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isBind"];
    
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已绑定设备：%@",device.deviceName] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    view.tag = 100;
    [view show];
}


- (void)manridyBLEDidFailConnectDevice:(manridyBleDevice *)device
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _isConnected = NO;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"连接异常，请靠近设备并尝试再次连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    view.tag = 101;
    [view show];
    
    [self deletAllRowsAtTableView];
    [self.myBleTool stopScan];
    
    [self.refreshImageView setHidden:NO];
    [self.peripheralList setHidden:YES];
    [self.bindButton setHidden:YES];
    
    index = 0;
}



#pragma mark - 懒加载
- (UIImageView *)connectImageView
{
    if (!_connectImageView) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 25, self.view.frame.size.width * 136.5 / 320, 50, 13)];
        [self.view addSubview:view];
        _connectImageView = view;
    }
    
    return _connectImageView;
}

- (UIImageView *)refreshImageView
{
    if (!_refreshImageView) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.downView.center.x - 44, 100, 88, 78.5)];
        [view setImage:[UIImage imageNamed:@"ble_refresh"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchPeripheral)];
        [view addGestureRecognizer:tap];
        view.userInteractionEnabled = YES;
        
        [self.downView addSubview:view];
        _refreshImageView = view;
    }
    
    return _refreshImageView;
}

- (UILabel *)bindStateLabel
{
    if (!_bindStateLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, self.view.frame.size.width * 190 / 320, 200, 19)];
        [label setTextColor:[UIColor colorWithWhite:1 alpha:0.4]];
        label.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        _bindStateLabel = label;
    }
    
    return _bindStateLabel;
}

- (UILabel *)perNameLabel
{
    if (!_perNameLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, self.view.frame.size.width * 220 / 320, 200, 19)];
        label.alpha = 0;
        
        [label setTextColor:[UIColor colorWithWhite:1 alpha:0.4]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setHidden:YES];
        
        [self.view addSubview:label];
        _perNameLabel = label;
    }
    
    return _perNameLabel;
}

- (UIView *)downView
{
    if (!_downView) {
        UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 274 / 320, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.width * 274 / 320))];
        downView.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:downView];
        _downView = downView;
    }
    
    return _downView;
}

- (UITableView *)peripheralList
{
    if (!_peripheralList) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.downView.frame.size.height - 21 - 50) style:UITableViewStylePlain];
        view.backgroundColor = [UIColor whiteColor];
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.downView addSubview:view];
        _peripheralList = view;
    }
    
    return _peripheralList;
}

- (UIButton *)bindButton
{
    if (!_bindButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.downView.center.x - 90, self.downView.frame.size.height - 21 - 47, 180, 47)];
        [button setTitle:@"绑定设备" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bindPeripheral) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0;
        
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self.downView addSubview:button];
        _bindButton = button;
    }
    
    return _bindButton;
}

- (UIButton *)disbindButton
{
    if (!_disbindButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.downView.center.x - 90, self.downView.frame.size.width * 18 / 320, self.view.frame.size.width * 180 / 320, self.view.frame.size.width * 47 / 320)];
        [button setTitle:@"解除绑定" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(disbindPeripheral) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0;
        
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self.downView addSubview:button];
        _disbindButton = button;
    }
    
    return _disbindButton;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
