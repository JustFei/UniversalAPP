//
//  PhoneRemindTableViewCell.h
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClockSwitchValueChangeBlock)(void);

@interface PhoneRemindTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *functionName;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UISwitch *timeSwitch;

@property (nonatomic ,copy) ClockSwitchValueChangeBlock _clockSwitchValueChangeBlock;

@end
