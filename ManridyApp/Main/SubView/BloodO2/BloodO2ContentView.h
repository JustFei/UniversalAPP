//
//  BloodO2ContentView.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/19.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"

@interface BloodO2ContentView : UIView < PNChartDelegate >
@property (weak, nonatomic) IBOutlet UILabel *BOLabel;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic ,copy) NSMutableArray *dateArr;
@property (nonatomic ,weak) PNLineChart *BOChart;
@property (weak, nonatomic) IBOutlet UILabel *currentBOLabel;

- (void)queryBOWithBloodArr:(NSArray *)BODataArr;
@end
