//
//  PhoneRemindTableViewCell.m
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhoneRemindTableViewCell.h"

@implementation PhoneRemindTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeState:(UISwitch *)sender
{
    if (self._clockSwitchValueChangeBlock) {
        self._clockSwitchValueChangeBlock();
    }
}

@end
