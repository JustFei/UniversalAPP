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

@interface MainViewController :UIViewController

@property (nonatomic ,strong) StepContentView *stepView;

- (void)writeData;

- (void)showFunctionView;

- (void)hiddenFunctionView;

@end
