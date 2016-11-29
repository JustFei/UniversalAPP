//
//  AppDelegate.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import "manridyBleDevice.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate () <BleDiscoverDelegate, BleConnectDelegate ,BleReceiveSearchResquset , UNUserNotificationCenterDelegate>
{
    SystemSoundID soundID;
    CTCallCenter *_callCenter;
    BOOL _isBind;
}
@property (nonatomic ,strong) UIAlertController *searchVC;

@end

@implementation AppDelegate

static void completionCallback(SystemSoundID mySSID)
{
    // 播放完毕之后，再次播放
    AudioServicesPlayAlertSound(mySSID);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.discoverDelegate = self;
    self.myBleTool.connectDelegate = self;
    self.myBleTool.searchDelegate = self;

//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"]) {
        _isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
        NSLog(@"有没有绑定设备 == %d",_isBind);
//    }
    
    self.mainVc = [[MainViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.mainVc];
//    if (_isBind) {
//        //蓝牙是否打开
//        if (self.myBleTool.systemBLEstate == SystemBLEStatePoweredOn) {
//            [self connectBLE];
//        }
//    }
    
    //监听state变化的状态
    [self.myBleTool addObserver:self forKeyPath:@"systemBLEstate" options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    //设置navigationBar为透明无线
    [nc.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage new]];
    nc.navigationBar.clipsToBounds = YES;
    
    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:@{@"NSForegroundColorAttributeName":[UIColor whiteColor], @"NSFontAttributeName":[UIFont systemFontOfSize:15]}];
    
    self.window.rootViewController = nc;
    
    //注册通知
    // 申请通知权限
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    }];
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"监听到%@对象的%@属性发生了改变， %@", object, keyPath, change[@"new"]);
    if ([keyPath isEqualToString:@"systemBLEstate"]) {
        NSString *new = change[@"new"];
        switch (new.integerValue) {
            case 4:
                
                break;
            case 5:
            {
                if (_isBind) {
                    if (self.myBleTool.connectState == kBLEstateDisConnected) {
                        [self connectBLE];
                    }
                }
            }
                
                break;
                
            default:
                break;
        }
    }
}

- (void)connectBLE
{
    BOOL systemConnect = [self.myBleTool retrievePeripherals];
    if (!systemConnect) {
        [self.myBleTool scanDevice];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.myBleTool stopScan];
            
            if (self.myBleTool.connectState == kBLEstateDisConnected) {
                [self.mainVc.stepView.stepLabel setText:@"未连接上设备，点击重试"];
            }
        });
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.myBleTool removeObserver:self forKeyPath:@"systemBLEstate"];
}

#pragma mark - BleDiscoverDelegate
- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device
{
    NSString *bindUUIDString = [[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralID"];
    if ([device.peripheral.identifier.UUIDString isEqualToString:bindUUIDString]) {
        [self.myBleTool connectDevice:device];
    }
}

#pragma mark - BleReceiveSearchResquset
- (void)receivePeripheralRequestToRemindPhoneWithState:(BOOL)OnorOFF
{
    if (OnorOFF) {
        if (self.searchVC != nil) {
            [self.searchVC dismissViewControllerAnimated:YES completion:nil];
        }
        [self.window.rootViewController presentViewController:self.searchVC animated:YES completion:nil];
        [self requestNotify];
        
        NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
        //提示音 带震动
        AudioServicesPlayAlertSound(soundID);
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL,(void*)completionCallback ,NULL);
    }else {
        [self.searchVC dismissViewControllerAnimated:YES completion:nil];
        AudioServicesDisposeSystemSoundID(soundID);
    }
}

- (void)requestNotify
{
    // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    // 标题
    content.title = @"手环查找中。。。";
    // 次标题
    content.subtitle = @"您的手环正在查找您。。。";
    content.sound = [UNNotificationSound defaultSound];
    
    // 标识符
    content.categoryIdentifier = @"categoryIndentifier1";
    
    // 2、创建通知触发
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    // 3、创建通知请求
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification1" content:content trigger:trigger];
    
    // 4、将请求加入通知中心
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"已成功加推送%@",notificationRequest.identifier);
        }
    }];
}

- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device
{
//    [self.mainVc showFunctionView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.myBleTool writeTimeToPeripheral:[NSDate date]];
        [self.mainVc writeData];
    });
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 懒加载
- (UIAlertController *)searchVC
{
    if (!_searchVC) {
        _searchVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在查找设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ac = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.myBleTool writeStopPeripheralRemind];
            AudioServicesDisposeSystemSoundID(soundID);
        }];
        [_searchVC addAction:ac];
    }
    
    return _searchVC;
}

@end
