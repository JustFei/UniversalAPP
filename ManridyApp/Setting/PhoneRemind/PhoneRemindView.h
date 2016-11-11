//
//  PhoneRemindView.h
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SectionModel;
typedef void(^HeaderViewExpandCallback)(BOOL isExpanded);

@interface PhoneRemindView : UITableViewHeaderFooterView

@property (nonatomic ,weak) UIView *cutView;
@property (nonatomic ,weak) UIImageView *iconImageView;
@property (nonatomic ,weak) UILabel *functionLabel;
@property (nonatomic ,weak) UIImageView *arrowImageView;

@property (nonatomic ,strong) SectionModel *model;

@property (nonatomic, copy) HeaderViewExpandCallback expandCallback;

@end
