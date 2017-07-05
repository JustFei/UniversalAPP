//
//  SedentaryReminderTableViewCell.h
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SedentaryReminderModel.h"

typedef void(^SwitchChangeBlock)(void);

@interface SedentaryReminderTableViewCell : UITableViewCell

@property (nonatomic, strong) SedentaryReminderModel *model;
@property (nonatomic, copy) SwitchChangeBlock switchChangeBlock;

@end
