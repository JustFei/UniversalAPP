//
//  TemperatureContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "TemperatureContentView.h"
#import "TemperatureWarningViewController.h"

@implementation TemperatureContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"TemperatureContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}
- (IBAction)temperatureWarningAction:(UIButton *)sender
{
    TemperatureWarningViewController *vc = [[TemperatureWarningViewController alloc] initWithNibName:@"TemperatureWarningViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - 获取当前View的控制器的方法
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
