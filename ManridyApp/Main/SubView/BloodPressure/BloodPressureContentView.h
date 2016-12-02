//
//  BloodPressureContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@interface BloodPressureContentView : UIView < PNChartDelegate >
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (strong, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *currentBPLabel;

@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *hbArr;
@property (nonatomic ,strong) NSMutableArray *lbArr;
@property (nonatomic ,strong) NSMutableArray *bpmArr;
@property (nonatomic ,strong) NSMutableArray *timeArr;
@property (nonatomic ,weak) PNBarChart *lowBloodChart;
@property (nonatomic ,weak) PNBarChart *highBloodChart;

- (void)queryBloodWithBloodArr:(NSArray *)bloodDataArr;
- (void)showChartViewWithData:(BOOL)haveData;
- (void)drawProgress:(CGFloat )progress;
@end
