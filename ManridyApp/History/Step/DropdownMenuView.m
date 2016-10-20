//
//  DropdownMenuView.m
//  ManridyApp
//
//  Created by JustFei on 16/10/20.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "DropdownMenuView.h"

@interface DropdownMenuView()
{
    // 用来显示具体内容的容器
    UIImageView * _containerView;
}
@end

@implementation DropdownMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除默认的背景颜色
        self.backgroundColor = [UIColor clearColor];
        
        // 添加一个灰色图片，作为下拉菜单的背景
        _containerView = [[UIImageView alloc] init];
        _containerView.image = [UIImage imageNamed:@"popover_background"];
        _containerView.userInteractionEnabled = YES;
        [self addSubview:_containerView];
    }
    return self;
}

- (void)setContentController:(UIViewController *)contentController
{
    _contentController = contentController;
    
    UIView * content = [contentController view];
    
    // 1. 用一个临时变量保存返回值。
    CGRect temp = content.frame;
    
    // 2. 给这个变量赋值。因为变量都是L-Value，可以被赋值
    temp.origin.x = 7;
    temp.origin.y = 13;
    
    // 3. 修改frame的值
    content.frame = temp;
    
    // 调整内容的位置
    CGRect temp1 = _containerView.frame;
    
    temp1.size.height = CGRectGetMaxY(content.frame) + 9;
    temp1.size.width = CGRectGetMaxX(content.frame) + 7;
    
    _containerView.frame = temp1;
    
    // 添加内容到灰色图片中
    [_containerView addSubview:content];
}

#pragma mark 在指定UIView下方显示菜单
- (void)showFrom:(UIView *)from
{
    // 1.获得最上面的窗口
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    // 2.添加自己到窗口上
    [window addSubview:self];
    
    // 3.设置尺寸
    self.frame = window.bounds;
    
    // 4.调整灰色图片的位置
    // 默认情况下，frame是以父控件左上角为坐标原点
    // 转换坐标系
    CGRect newFrame = [from convertRect:from.bounds toView:window];
    
    CGPoint centerPoint = _containerView.center;
    centerPoint.x = CGRectGetMinX(newFrame);
    _containerView.center = centerPoint;
    
    
    CGRect temp = _containerView.frame;
    temp.origin.y = CGRectGetMaxY(newFrame);
    _containerView.frame = temp;
    
    // 通知外界，自己显示了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
        [self.delegate dropdownMenuDidShow:self];
    }
}

#pragma mark 销毁下拉菜单
- (void)dismiss
{
    [self removeFromSuperview];
    
    // 通知外界，自己被销毁了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidDismiss:)]) {
        [self.delegate dropdownMenuDidDismiss:self];
    }
}

#pragma mark 点击自己执行销毁动作
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end
