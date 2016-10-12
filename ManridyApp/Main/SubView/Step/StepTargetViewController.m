//
//  StepTargetViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "StepTargetViewController.h"
#import "BLETool.h"
#import "MBProgressHUD.h"

@interface StepTargetViewController () < BleReceiveDelegate>

@property (weak, nonatomic) IBOutlet UITextField *stepTargetTextField;

@property (weak, nonatomic) IBOutlet UILabel *mileageTargetLabel;
@property (weak, nonatomic) IBOutlet UILabel *kcalTargetLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic ,strong) BLETool *myBleTool;
@property (nonatomic ,strong) MBProgressHUD *hud;

@end

@implementation StepTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"目标设置";
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.receiveDelegate = self;
    
    [self.stepTargetTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.clipsToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    self.saveButton.layer.borderWidth = 1;
    self.saveButton.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.myBleTool.receiveDelegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BleReceiveDelegate
- (void)receiveMotionTargetWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight) {
        if (manridyModel.receiveDataType == ReturnModelTypeSportTargetModel) {
            [self.hud hideAnimated:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSString *targetString = [textField.text stringByAppendingString:string];
////    NSLog(@"now == %@",targetString);
//    if (targetString.length >= 6) {
//        targetString = textField.text;
//        NSInteger targetInteger = targetString.integerValue;
//        
//        [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
//        [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
//        return NO;
//    }
//    
//    NSInteger targetInteger = targetString.integerValue;
//    
//    [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
//    [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
//    
//    return YES;
//}

#pragma mark - Action
- (IBAction)saveInfoAction:(UIButton *)sender
{
    if (self.stepTargetTextField.text) {
        [self.myBleTool writeMotionTargetToPeripheral:self.stepTargetTextField.text];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        [self.hud.label setText:@"正在设置运动目标"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
    [self.mileageTargetLabel setText:textField.text];
    [self.kcalTargetLabel setText:textField.text];
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
