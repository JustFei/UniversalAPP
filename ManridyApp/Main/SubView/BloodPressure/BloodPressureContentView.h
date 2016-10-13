//
//  BloodPressureContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodPressureContentView : UIView
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureLabel;

@property (weak, nonatomic) IBOutlet UILabel *bloodPressureHighState;
@property (weak, nonatomic) IBOutlet UILabel *bloodPressureLowState;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@end
