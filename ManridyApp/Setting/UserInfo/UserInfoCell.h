//
//  UserInfoCell.h
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserInfoTextFieldBlock)(UITextField *);

@interface UserInfoCell : UITableViewCell 

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (nonatomic ,copy) UserInfoTextFieldBlock userInfoTextFieldBlock;

@end
