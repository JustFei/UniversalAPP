//
//  StepContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StepTargetViewController.h"
#import "BLETool.h"
#import "PNChart.h"
//#import "FMDBTool.h"
#import "StepDataModel.h"

@interface StepContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileageAndkCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekStatisticsLabel;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;

@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic ,weak) PNLineChart *stepChart;

//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic ,strong) NSTimer *timer;

//@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;



- (void)drawProgress:(CGFloat )progress;
- (void)showChartView;

@end
