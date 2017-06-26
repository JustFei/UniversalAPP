//
//  APPRemindTableViewCell.h
//  New_iwear
//
//  Created by JustFei on 2017/6/20.
//  Copyright © 2017年 manridy. All rights reserved.
//

//#import <MaterialControls/MaterialControls.h>
#import "APPRemindModel.h"

typedef void(^APPRemindSelectButtonClickBlock)(BOOL select);

@interface APPRemindTableViewCell : UITableViewCell

@property (nonatomic, strong) APPRemindModel *model;
@property (nonatomic, copy) APPRemindSelectButtonClickBlock appRemindSelectButtonClickBlock;

@end
