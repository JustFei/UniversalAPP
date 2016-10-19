//
//  SleepContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SleepContentView : UIView
@property (weak, nonatomic) IBOutlet UILabel *sleepSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *deepAndLowSleepLabel;
@property (weak, nonatomic) IBOutlet UILabel *sleepStateLabel;

@property (weak, nonatomic) IBOutlet UIView *sleepStateView1;

@property (weak, nonatomic) IBOutlet UIView *sleepStateView2;

@property (weak, nonatomic) IBOutlet UIView *sleepStateView3;

@property (weak, nonatomic) IBOutlet UIView *sleepStateView4;

@property (weak, nonatomic) IBOutlet UIView *downView;

@property (nonatomic ,strong) NSArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;

- (void)showChartView;

@end
