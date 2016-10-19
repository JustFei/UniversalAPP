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
#import "FMDBTool.h"
#import "UserInfoModel.h"

@interface StepTargetViewController () < BleReceiveDelegate>
{
    float _height;
    float _weight;
    NSArray *_userArr;
}
@property (weak, nonatomic) IBOutlet UITextField *stepTargetTextField;

@property (weak, nonatomic) IBOutlet UILabel *mileageTargetLabel;
@property (weak, nonatomic) IBOutlet UILabel *kcalTargetLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic ,strong) BLETool *myBleTool;
@property (nonatomic ,strong) MBProgressHUD *hud;
@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@end

@implementation StepTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"目标设置";
    
    self.myBleTool = [BLETool shareInstance];
    self.myBleTool.receiveDelegate = self;
    
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.clipsToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    self.saveButton.layer.borderWidth = 1;
    self.saveButton.layer.borderColor = [UIColor blackColor].CGColor;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _userArr = [self.myFmdbTool queryAllUserInfo];
        
        if (_userArr.count == 0) {
            _weight = 75.0;
            _height = 180.0;
        }else {
            //这里由于是单用户，所以取第一个值
            UserInfoModel *model = _userArr.firstObject;
            _weight = model.weight;
            _height = model.height;
            
            if (model.stepTarget != 0) {
                self.stepTargetTextField.text = [NSString stringWithFormat:@"%ld",model.stepTarget];
                [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%0.1f",[self getMileage:model.stepTarget]]];
                [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%0.1f",[self getKcal:model.stepTarget]]];
            }
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.myBleTool.receiveDelegate = nil;
}

- (void)dealloc
{
    [self.myFmdbTool CloseDataBase];
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
            
            BOOL result = [self.myFmdbTool modifyStepTargetWithID:1 model:self.stepTargetTextField.text.integerValue];
            
            if (result) {
                self.hud.label.text = @"保存成功";
            }else {
                self.hud.label.text = @"保存失败，请重新尝试";
            }
            
            [self.hud hideAnimated:YES afterDelay:1];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *targetString = [textField.text stringByAppendingString:string];
//    NSLog(@"now == %@",targetString);
    if (targetString.length >= 6) {
        targetString = textField.text;
        NSInteger targetInteger = targetString.integerValue;
        
        [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
        [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
        return NO;
    }
    
    NSInteger targetInteger = targetString.integerValue;
    
    [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
    [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%ld",targetInteger]];
    
    return YES;
}

#pragma mark - Action
- (IBAction)saveInfoAction:(UIButton *)sender
{
    
    if (_userArr.count != 0) {
        if (self.stepTargetTextField.text) {
            [self.myBleTool writeMotionTargetToPeripheral:self.stepTargetTextField.text];
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            [self.hud.label setText:@"正在设置运动目标"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.hud.label.text = @"设置超时，请连接或靠近设备并重试。";
                [self.hud hideAnimated:YES afterDelay:1];
            });
        }
    }else {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先去设置您的个人信息，否则无法设置该功能。" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (IBAction)textFieldDidChange:(UITextField *)sender {
    if (sender.text.length <= 5) {
        [self.mileageTargetLabel setText:[NSString stringWithFormat:@"%0.1f",[self getMileage:sender.text.integerValue]]];
        [self.kcalTargetLabel setText:[NSString stringWithFormat:@"%0.1f",[self getKcal:sender.text.integerValue]]];
    }else {
        self.stepTargetTextField.text = [self.stepTargetTextField.text substringToIndex:5];
    }
}

- (float)getMileage:(NSInteger)step
{
    return (70 + (170 - (_height ? _height : 170))) * step / 100.0;
}

- (float)getKcal:(NSInteger)step
{
    return ([self getMileage:step] / 100.0) * 0.0766666666667 * (_weight ? _weight : 60);
}

#pragma mark - 懒加载
- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
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
