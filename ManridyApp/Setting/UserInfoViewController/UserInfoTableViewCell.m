//
//  UserInfoTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/10.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "UserInfoTableViewCell.h"
#import "Masonry.h"

@interface UserInfoTableViewCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation UserInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:17]];
        [_nameLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _unitLabel = [[UILabel alloc] init];
        [_unitLabel setFont:[UIFont systemFontOfSize:17]];
        [_unitLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [self addSubview:_unitLabel];
        [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
        
        _centerLabel = [[UILabel alloc] init];
//        [_centerLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_centerLabel setFont:[UIFont systemFontOfSize:17]];
        [_centerLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_centerLabel];
        [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    
    return self;
}

- (void)setModel:(UserInfoSettingModel *)model
{
    if (model) {
        _model = model;
        [self.nameLabel setText:model.nameText];
        [self.unitLabel setText:model.unitText];
        if (model.isGenderCell) {
            [self.centerLabel setText:model.placeHoldText];
            [self.centerLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        }else {
            [self.centerLabel setText:model.placeHoldText];
            [self.centerLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        }
    }
}

@end
