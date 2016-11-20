//
//  HeartRateContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartRateContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (weak, nonatomic) IBOutlet UILabel *heartStateLabel;

@property (nonatomic ,copy) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UIView *state1;
@property (weak, nonatomic) IBOutlet UIView *state2;
@property (weak, nonatomic) IBOutlet UIView *state4;

- (void)drawProgress:(CGFloat )progress;
- (void)showChartViewWithData:(BOOL)haveData;

@end
