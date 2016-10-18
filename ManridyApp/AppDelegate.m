//
//  AppDelegate.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BLETool.h"
#import "manridyBleDevice.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface AppDelegate () <BleDiscoverDelegate, BleConnectDelegate>
{
    CTCallCenter *_callCenter;
}
@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) MainViewController *mainVc;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
    // 监控通话信息
    CTCallCenter *center = [[CTCallCenter alloc] init];
    _callCenter = center;
    // 获取并输出手机的运营商信息
    [self aboutCall];
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.discoverDelegate = self;
    self.myBleTool.connectDelegate = self;
    
    BOOL isBind = [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"];
    
    
    
    self.mainVc = [[MainViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.mainVc];
    
    if (isBind) {
        [self.myBleTool scanDevice];
    }
    
    //设置navigationBar为透明无线
    [nc.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage new]];
    nc.navigationBar.clipsToBounds = YES;
    
    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:@{@"NSForegroundColorAttributeName":[UIColor whiteColor], @"NSFontAttributeName":[UIFont systemFontOfSize:15]}];
    
    self.window.rootViewController = nc;
    
    return YES;
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
    [self.mainVc writeData];
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
