//
//  SedentaryReminderTableViewCell.m
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SedentaryReminderTableViewCell.h"

@interface SedentaryReminderTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeStateLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation SedentaryReminderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextColor:TEXT_BLACK_COLOR_LEVEL4];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(16);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _subTitleLabel = [[UILabel alloc] init];
        [_subTitleLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_subTitleLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_subTitleLabel];
        [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(9);
            make.left.equalTo(_titleLabel.mas_left);
        }];
        
        _switchButton = [[UIButton alloc] init];
        [_switchButton setImage:[UIImage imageNamed:@"ic_off"] forState:UIControlStateNormal];
        [_switchButton setImage:[UIImage imageNamed:@"ic_on"] forState:UIControlStateSelected];
        _switchButton.backgroundColor = CLEAR_COLOR;
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchButton];
        [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleLabel.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
            make.width.equalTo(@48);
            make.height.equalTo(@48);
        }];
        
        _arrowImageView = [[UIImageView alloc] init];
        [self addSubview:_arrowImageView];
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.arrowImageView.mas_left);
        }];
        
        _timeStateLabel = [[UILabel alloc] init];
        [_timeStateLabel setTextColor:TEXT_BLACK_COLOR_LEVEL3];
        [_timeStateLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_timeStateLabel];
        [_timeStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(_timeLabel.mas_left).offset(-8);
        }];
    }
    
    return self;
}

- (void)setModel:(SedentaryReminderModel *)model
{
    if (model) {
        _model = model;
        [self.titleLabel setText:model.title];
        [self.subTitleLabel setText:model.subTitle];
        if (model.whetherHaveSwitch) {
//            [self.switchButton setImage:[UIImage imageNamed:model.switchIsOpen ? @"ic_on" : @"ic_off"]];
            [self.switchButton setSelected:model.switchIsOpen];
            self.timeLabel.hidden = YES;
            self.timeStateLabel.hidden = YES;
            self.arrowImageView.hidden = YES;
        }else {
            self.switchButton.hidden = YES;
            [self.timeLabel setText:model.time];
            [self.arrowImageView setImage:[UIImage imageNamed:@"ic_chevron_right"]];
        }
    }
}

#pragma mark - Action
- (void)switchAction:(UIButton *)sender
{
    if (self.switchChangeBlock) {
        self.switchChangeBlock();
    }
}

@end
