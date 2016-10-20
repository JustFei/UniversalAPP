//
//  AppDelegate.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "BLETool.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic ,strong) MainViewController *mainVc;
@property (nonatomic ,strong) BLETool *myBleTool;

@end

