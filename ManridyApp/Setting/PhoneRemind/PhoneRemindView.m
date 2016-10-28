//
//  PhoneRemindView.m
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhoneRemindView.h"
#import "SectionModel.h"

@implementation PhoneRemindView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    button.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 44);
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)setModel:(SectionModel *)model {
    if (_model != model) {
        _model = model;
    }
    
    self.arrowImageView.image = [UIImage imageNamed:model.arrowImageName];
    self.iconImageView.image = [UIImage imageNamed:model.imageName];
    if (model.isExpanded) {
        self.arrowImageView.transform = CGAffineTransformIdentity;
    } else {
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    self.functionLabel.text = model.functionName;
}

#pragma mark - Action
- (void)onExpand:(UIButton *)sender {
    self.model.isExpanded = !self.model.isExpanded;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.model.isExpanded) {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }];
    
    if (self.expandCallback) {
        self.expandCallback(self.model.isExpanded);
    }
}

#pragma mark - 懒加载
- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(8, 9, 25, 25)];
        [self.contentView addSubview:view];
        _iconImageView = view;
    }
    
    return _iconImageView;
}

- (UILabel *)functionLabel
{
    if (!_functionLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 11, 55, 21)];
        label.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label];
        _functionLabel = label;
    }
    
    return _functionLabel;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 32, self.contentView.center.y - 7, 24, 14)];
        [self.contentView addSubview:view];
        _arrowImageView = view;
    }
    
    return _arrowImageView;
}

//- (UIButton *)button
//{
//    if (!_button) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
//        [button addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self.contentView addSubview:button];
//        _button = button;
//    }
//    
//    return _button;
//}

@end
