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
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (strong, nonatomic) IBOutlet UIView *downView;

@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *hbArr;
@property (nonatomic ,strong) NSMutableArray *lbArr;

- (void)queryBloodWithBloodArr:(NSArray *)bloodDataArr;
- (void)showChartViewWithData:(BOOL)haveData;
- (void)drawProgress:(CGFloat )progress;
@end
