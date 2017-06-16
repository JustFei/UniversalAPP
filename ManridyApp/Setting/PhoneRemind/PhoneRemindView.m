//
//  PhoneRemindView.m
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "PhoneRemindView.h"
#import "SectionModel.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width

@implementation PhoneRemindView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
    }
    [self layoutIfNeeded];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    button.frame = CGRectMake(0, 0, WIDTH, 44);
    
    self.contentView.backgroundColor = COLOR_WITH_HEX(0x1e88e5, 1);
    
    return self;
}

- (void)setModel:(SectionModel *)model {
    if (_model != model) {
        _model = model;
    }
    [self.contentView addSubview:self.cutView];
    
    NSString *imageStr = model.imageNameArr.firstObject;
    NSString *funStr = model.functionNameArr.firstObject;
    self.arrowImageView.image = [UIImage imageNamed:model.arrowImageName];
    self.iconImageView.image = [UIImage imageNamed:imageStr];
    if (!model.isExpanded) {
        self.arrowImageView.transform = CGAffineTransformIdentity;
    } else {
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
    
    self.functionLabel.text = funStr;
}

#pragma mark - Action
- (void)onExpand:(UIButton *)sender {
    self.model.isExpanded = !self.model.isExpanded;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.model.isExpanded) {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        }
    }];
    
    if (self.expandCallback) {
        self.expandCallback(self.model.isExpanded);
    }
}

#pragma mark - 懒加载
- (UIView *)cutView
{
    if (!_cutView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 16)];
        view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        
        [self.contentView addSubview:view];
        _cutView = view;
    }
    
    return _cutView;
}

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
//        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(8, 9, 25, 22)];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(8, 23, 20, 20)];
        [self.contentView addSubview:view];
        _iconImageView = view;
    }
    
    return _iconImageView;
}

- (UILabel *)functionLabel
{
    if (!_functionLabel) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 11, 80, 21)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 150, 21)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
        _functionLabel = label;
    }
    
    return _functionLabel;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
//        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 39, 15, 11, 15)];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 39, 30, 11, 15)];
        [self.contentView addSubview:view];
        _arrowImageView = view;
        
        DLog(@"headerViewRect == %@",NSStringFromCGRect(_arrowImageView.frame));
    }
    
    return _arrowImageView;
}

@end
