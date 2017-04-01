//
//  UnitsSettingTableViewCell.m
//  ManridyApp
//
//  Created by Faith on 2017/3/31.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UnitsSettingTableViewCell.h"

@implementation UnitsSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //选中的图标
        _selecetImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.center.y - 5, 10, 10)];
        [self.contentView addSubview:_selecetImageView];
        
        //单位
        _unitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, self.center.y - 7.5, 300, 15)];
        [self.contentView addSubview:_unitsLabel];
    }
    
    return self;
}

@end
