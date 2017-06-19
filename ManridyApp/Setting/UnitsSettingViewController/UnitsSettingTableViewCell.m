//
//  UnitsSettingTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "UnitsSettingTableViewCell.h"

@interface UnitsSettingTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation UnitsSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(16);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        _selectButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [_selectButton setImage:[UIImage imageNamed:@"ic_radiobuttonoff"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"ic_radiobuttonon_color"] forState:UIControlStateSelected];
        [self addSubview:_selectButton];
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
            make.width.equalTo(@24);
            make.height.equalTo(@24);
        }];
    }
    return self;
}

- (void)setModel:(UnitsSettingModel *)model
{
    if (model) {
        _model = model;
        [self.nameLabel setText:model.name];
        self.selectButton.selected = model.isSelect;
        [self.nameLabel setTextColor:model.isSelect ? NAVIGATION_BAR_COLOR : TEXT_BLACK_COLOR_LEVEL4 ];
    }
}

#pragma mark - Action
- (void)selectAction:(UIButton *)sender
{
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
//        [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
    }else {
        if (self.unitsSettingSelectBlock) {
            self.unitsSettingSelectBlock();
        }
    }
}

@end
