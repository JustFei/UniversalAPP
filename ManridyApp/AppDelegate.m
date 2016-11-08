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

@interface AppDelegate () <BleDiscoverDelegate, BleConnectDelegate ,UNUserNotificationCenterDelegate>
{
    CTCallCenter *_callCenter;
    BOOL _isBind;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
#if 0
    // 监控通话信息
    CTCallCenter *center = [[CTCallCenter alloc] init];
    _callCenter = center;
    // 获取并输出手机的运营商信息
    [self aboutCall];
#endif
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.discoverDelegate = self;
    self.myBleTool.connectDelegate = self;
    
    _isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    
    self.mainVc = [[MainViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.mainVc];
    if (_isBind) {
        //蓝牙是否打开
        if (self.myBleTool.systemBLEstate == SystemBLEStatePoweredOn) {
            [self connectBLE];
        }
    }
    
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
                    [self connectBLE];
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
    [self.myBleTool scanDevice];
    self.myBleTool.isReconnect = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myBleTool stopScan];
        
        if (self.myBleTool.connectState == kBLEstateDisConnected) {
            [self.mainVc.stepView.stepLabel setText:@"未连接上设备，点击重试"];
        }
    });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.myBleTool removeObserver:self forKeyPath:@"systemBLEstate"];
}

- (void) aboutCall{
    //获取电话接入信息
    _callCenter.callEventHandler = ^(CTCall *call){
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"Call has been disconnected");
            
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"Call has just been connected");
            
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            NSLog(@"Call is incoming");
            
        }else if ([call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"call is dialing");
            
        }else{
            NSLog(@"Nothing is done");
        }
    };
}

- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device
{
    NSString *bindUUIDString = [[NSUserDefaults standardUserDefaults] objectForKey:@"bindPeripheralID"];
    if ([device.peripheral.identifier.UUIDString isEqualToString:bindUUIDString]) {
        [self.myBleTool connectDevice:device];
    }
}

- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device
{
//    [self.mainVc showFunctionView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.myBleTool writeTimeToPeripheral:[NSDate date]];
//        [self.myBleTool writeToKeepConnect];
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

@end
