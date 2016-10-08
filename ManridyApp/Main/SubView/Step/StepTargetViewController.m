//
//  StepTargetViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepTargetViewController.h"

@interface StepTargetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *stepTargetTextField;

@property (weak, nonatomic) IBOutlet UILabel *mileageTargetLabel;
@property (weak, nonatomic) IBOutlet UILabel *kcalTargetLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation StepTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"目标设置";
    
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.clipsToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    self.saveButton.layer.borderWidth = 1;
    self.saveButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveInfoAction:(UIButton *)sender {
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
