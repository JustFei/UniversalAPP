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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(onExpand:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    button.frame = CGRectMake(0, 0, WIDTH, 44);
    
    NSLog(@"button.frame == %@",NSStringFromCGRect(button.frame));
    
    self.contentView.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    return self;
}

- (void)setModel:(SectionModel *)model {
    if (_model != model) {
        _model = model;
    }
    
    self.arrowImageView.image = [UIImage imageNamed:model.arrowImageName];
    self.iconImageView.image = [UIImage imageNamed:model.imageName];
    if (!model.isExpanded) {
        self.arrowImageView.transform = CGAffineTransformIdentity;
    } else {
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
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
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
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
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 20, 15, 11, 15)];
        [self.contentView addSubview:view];
        _arrowImageView = view;
        
        NSLog(@"headerViewRect == %@",NSStringFromCGRect(_arrowImageView.frame));
    }
    
    return _arrowImageView;
}

@end
