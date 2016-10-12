//
//  StepContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepContentView.h"
#import "StepTargetViewController.h"
#import "BLETool.h"

@interface StepContentView () <BleReceiveDelegate>
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileageAndkCalLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekStatisticsLabel;

@property (nonatomic ,strong) BLETool *myBleTool;

@end

@implementation StepContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"StepContentView" owner:self options:nil].firstObject;
        self.frame = frame;
        self.myBleTool = [BLETool shareInstance];
        self.myBleTool.receiveDelegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.myBleTool writeMotionRequestToPeripheral];
    });
}

#pragma mark - Action
- (IBAction)setTargetAction:(UIButton *)sender
{
    StepTargetViewController *vc = [[StepTargetViewController alloc] initWithNibName:@"StepTargetViewController" bundle:nil];
    [[self findViewController:self].navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - BleReceiveDelegate
- (void)receiveMotionDataWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSportModel) {
            [self.stepLabel setText:manridyModel.sportModel.stepNumber];
            [self.mileageAndkCalLabel setText:[NSString stringWithFormat:@"%@公里/%@千卡",manridyModel.sportModel.mileageNumber ,manridyModel.sportModel.kCalNumber]];
            //保存motion数据到数据库
        }
    }
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    // 1.自己先处理事件...
//    NSLog(@"do somthing...");
//    // 2.再调用系统的默认做法，再把事件交给上一个响应者处理
//    [super touchesBegan:touches withEvent:event];
//}

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
