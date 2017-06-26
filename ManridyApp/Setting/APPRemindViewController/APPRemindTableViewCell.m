//
//  APPRemindTableViewCell.m
//  New_iwear
//
//  Created by JustFei on 2017/6/20.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "APPRemindTableViewCell.h"

@interface APPRemindTableViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation APPRemindTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.mas_left).offset(16);
        }];
        
        _nameLabel = [[UILabel alloc] init];
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(_headImageView.mas_right).offset(32);
        }];
        
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:[UIImage imageNamed:@"appremind_ic_normal"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"appremind_ic_select"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectButton];
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-16);
        }];
    }
    
    return self;
}

- (void)setModel:(APPRemindModel *)model
{
    if (model) {
        [self.headImageView setImage:[UIImage imageNamed:model.imageName]];
        [self.nameLabel setText:model.name];
        [self.selectButton setSelected:model.isSelect];
    }
}

#pragma mark - Action
- (void)selectAction:(UIButton *)sender
{
    [sender setSelected:!sender.selected];
    if (self.appRemindSelectButtonClickBlock) {
        self.appRemindSelectButtonClickBlock(sender.selected);
    }
}

@end
