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

- (void)showChartView;

@end
