//
//  StepViewController.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StepContentView.h"
#import "HeartRateContentView.h"
//#import "TemperatureContentView.h"
#import "SleepContentView.h"
#import "BloodPressureContentView.h"
#import "BloodO2ContentView.h"

@interface MainViewController :UIViewController

@property (nonatomic ,strong) StepContentView *stepView;

@property (nonatomic ,strong) HeartRateContentView *heartRateView;

//@property (nonatomic ,strong) TemperatureContentView *temperatureView;

@property (nonatomic ,strong) SleepContentView *sleepView;

@property (nonatomic ,strong) BloodPressureContentView  *bloodPressureView;

@property (nonatomic ,strong) BloodO2ContentView *boView;
@property (nonatomic ,assign) BOOL haveNewStep;
@property (nonatomic ,assign) BOOL haveNewHeartRate;
@property (nonatomic ,assign) BOOL haveNewSleep;
@property (nonatomic ,assign) BOOL haveNewBP;
@property (nonatomic ,assign) BOOL haveNewBO;


- (void)writeData;

- (void)showFunctionView;

- (void)hiddenFunctionView;

@end
