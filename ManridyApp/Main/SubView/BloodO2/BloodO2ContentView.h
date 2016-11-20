//
//  BloodO2ContentView.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/19.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodO2ContentView : UIView
@property (weak, nonatomic) IBOutlet UILabel *BOLabel;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (nonatomic ,copy) NSMutableArray *dateArr;


- (void)queryBOWithBloodArr:(NSArray *)BODataArr;
@end
