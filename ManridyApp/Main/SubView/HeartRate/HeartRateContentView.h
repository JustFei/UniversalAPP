//
//  HeartRateContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

typedef void(^HrTestBlock)(void);

@interface HeartRateContentView : UIView < PNChartDelegate >

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *hrTestBtn;
@property (strong, nonatomic) IBOutlet UILabel *currentHRStateLabel;
@property (nonatomic, copy) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, weak) PNLineChart *heartChart;
@property (nonatomic, copy) HrTestBlock hrTestBlock;

- (void)drawProgress:(CGFloat )progress;
- (void)showChartViewWithData:(BOOL)haveData;
- (void)showHRStateLabel;

@end
