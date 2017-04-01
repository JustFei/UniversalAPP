//
//  UserInfoViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoCell.h"
#import "FMDBTool.h"
#import "BLETool.h"
#import "UserInfoModel.h"
#import "MBProgressHUD.h"
#import "UserListViewController.h"
#import "UnitsTool.h"

#define WIDTH self.view.frame.size.width

@interface UserInfoViewController () <UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate ,UINavigationControllerDelegate ,UIImagePickerControllerDelegate ,UIAlertViewDelegate ,UIPickerViewDelegate ,UIPickerViewDataSource ,BleReceiveDelegate>
{
    NSArray *_nameArr;
    NSArray *_fieldPlaceholdeArr;
    NSArray *_unitArr;
    UITextField *_tempField;
    NSArray *_userArr;
    NSArray *_genderArr;
}

@property (nonatomic ,weak) UIImageView *headImageView;

@property (nonatomic ,weak) UITextField *userNameTextField;

@property (nonatomic ,weak) UILabel *genderLabel;

@property (nonatomic ,weak) UITextField *ageTextField;

@property (nonatomic ,weak) UITextField *heightTextField;

@property (nonatomic ,weak) UITextField *weightTextField;

@property (nonatomic ,weak) UITextField *steplengthTextField;

@property (nonatomic ,weak) UITableView *infoTableView;

@property (nonatomic ,weak) UIButton *saveButton;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) BLETool *myBleTool;

@property (nonatomic ,strong) MBProgressHUD *hud;

@property (nonatomic ,weak) UIPickerView *genderPickerView;

@property (nonatomic ,assign) BOOL isMetric;

@end

@implementation UserInfoViewController

#pragma mark - lyfeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMetric = [self isMetricOrImperialSystem];
    _nameArr = @[NSLocalizedString(@"gender", nil),NSLocalizedString(@"age", nil),NSLocalizedString(@"height", nil),NSLocalizedString(@"weight", nil)];
    _fieldPlaceholdeArr = @[@"",NSLocalizedString(@"inputAge", nil),NSLocalizedString(@"inputHeight", nil),NSLocalizedString(@"inputWeight", nil)];
    _unitArr = @[@"",NSLocalizedString(@"year", nil),self.isMetric ? @"(cm)" : @"(In)",self.isMetric ? @"(kg)" : @"(lb)"];
    _genderArr = @[NSLocalizedString(@"male", nil),NSLocalizedString(@"Female", nil)];
    
    self.navigationItem.title = NSLocalizedString(@"userInfo", nil);
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换用户" style:UIBarButtonItemStylePlain target:self action:@selector(changeUser)];
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    _userArr = [self.myFmdbTool queryAllUserInfo];
    
    [self.saveButton setBackgroundColor:[UIColor whiteColor]];
    
    if (_userArr.count == 0) {
        [self setInitUI];
    }else {
        [self setSaveUI:_userArr];
    }
    
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 261 * WIDTH / 320, self.view.frame.size.width, 13 * WIDTH / 320)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
    
    self.infoTableView.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
    //注销掉所有代理和关闭数据库
    self.infoTableView.delegate = nil;
    self.infoTableView.dataSource = nil;
    self.myBleTool.receiveDelegate = nil;
    [self.myFmdbTool CloseDataBase];
}


- (void)setInitUI
{
    self.headImageView.backgroundColor = [UIColor whiteColor];
}

- (void)setSaveUI:(NSArray *)userArr
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]) {
        DLog(@"hello == %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]);
        [self.userNameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"]) {
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userheadimage"];
        [self.headImageView setImage:[UIImage imageWithData:imageData]];
    }else {
        self.headImageView.backgroundColor = [UIColor whiteColor];
    }
}

//判断是否是公制单位
- (BOOL)isMetricOrImperialSystem
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"]) {
        BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"];
        return isMetric;
    }else {
        return NO;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    if (self.userNameTextField.isEditing) {
        return;
    }else {
        
        //1. 获取键盘的 Y 值
        CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        ;
        
        //注意从字典取出来的是对象，而 CGRect CGFloat 都是基本数据类型，一次需要转换
        CGFloat keyboardY = keyboardFrame.origin.y;
        
        //如果键盘的Y值小于textField的y值，就偏移
        //    if (keyboardY < _tempField.frame.origin.y + _tempField.frame.size.height) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(0, keyboardY - self.view.frame.size.height);
            }];
        });
        
        if ((keyboardY - self.view.frame.size.height) >= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController.navigationBar setHidden:NO];
            });
        }else {
            [self.navigationController.navigationBar setHidden:YES];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)setHeadImage
{
    /**
     *  弹出提示框
     */
    //初始化提示框
    AlertTool *alert = [AlertTool alertWithTitle:nil message:nil style:UIAlertControllerStyleActionSheet];
    //按钮：从相册选择，类型：UIAlertActionStyleDefault
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"choosePhotoFromPhotoAlbum", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
        //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
        //获取方方式3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
        PickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//方式1
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //按钮：拍照，类型：UIAlertActionStyleDefault
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"takeAPhoto", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
        //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
        //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
        //获取方方式3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
        PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;//方式1
        //允许编辑，即放大裁剪
        PickerImage.allowsEditing = YES;
        //自代理
        PickerImage.delegate = self;
        //页面跳转
        [self presentViewController:PickerImage animated:YES completion:nil];
    }]];
    //按钮：取消，类型：UIAlertActionStyleCancel
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:AlertToolStyleCancel handler:nil]];
    [alert show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    self.genderPickerView.hidden = YES;
}

//PickerImage完成后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //把newPhono设置成头像
    [self.headImageView setImage:newPhoto];
    //关闭当前界面，即回到主界面去
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)chooseGender
{
    self.genderPickerView.hidden = NO;
    self.genderPickerView.backgroundColor = [UIColor colorWithRed:48.0 / 255.0 green:110.0 / 255.0 blue:187.0 / 255.0 alpha:1];
    if (_userArr.count != 0) {
        UserInfoModel *model = _userArr.firstObject;
        if ([model.gender isEqualToString:NSLocalizedString(@"male", nil)]) {
            [self.genderPickerView selectRow:0 inComponent:0 animated:NO];
        }else {
            [self.genderPickerView selectRow:1 inComponent:0 animated:NO];
        }
    }
}

#pragma mark -ButtonAction
- (void)saveUserInfo
{
    [self.view endEditing:YES];
//     && self.steplengthTextField.text != nil && self.steplengthTextField.text.length != 0
    if (self.userNameTextField.text != nil && self.userNameTextField.text.length != 0 && self.ageTextField.text != nil && self.ageTextField.text.length != 0 && self.heightTextField.text != nil && self.heightTextField.text.length != 0 && self.weightTextField.text != nil && self.weightTextField.text.length != 0) {
        
        [self.myBleTool writeUserInfoToPeripheralWeight:self.weightTextField.text andHeight:self.heightTextField.text];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        
        NSArray *userArr = [self.myFmdbTool queryAllUserInfo];
        
        //计算出在英制和公制下的身高体重
        NSInteger height = self.isMetric ? self.heightTextField.text.integerValue : [UnitsTool cmAndInch:self.heightTextField.text.integerValue withMode:ImperialToMetric];
        NSInteger weight = self.isMetric ? self.weightTextField.text.integerValue : [UnitsTool kgAndLb:self.weightTextField.text.integerValue withMode:ImperialToMetric];
        
        UserInfoModel *model = [UserInfoModel userInfoModelWithUserName:self.userNameTextField.text andGender:self.genderLabel.text andAge:self.ageTextField.text.integerValue andHeight:height andWeight:weight andStepLength:self.steplengthTextField.text.integerValue andStepTarget:0 andSleepTarget:0];
       
        if (userArr.count == 0) {
           BOOL isSuccess = [self.myFmdbTool insertUserInfoModel:model];
            if (isSuccess) {
                self.hud.label.text = NSLocalizedString(@"saveSuccess", nil);
                
                NSData *imageData = UIImagePNGRepresentation(self.headImageView.image);
                [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"userheadimage"];
                
                [self.hud hideAnimated:YES afterDelay:1];
            }else {
                self.hud.label.text = NSLocalizedString(@"saveFailAndTryAgain", nil);
                [self.hud hideAnimated:YES afterDelay:1];
            }
        }else {
            BOOL isSuccess = [self.myFmdbTool modifyUserInfoWithID:1 model:model];
            if (isSuccess) {
                self.hud.label.text = NSLocalizedString(@"changeSuccess", nil);
                
                NSData *imageData = UIImagePNGRepresentation(self.headImageView.image);
                [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:@"userheadimage"];
                
                [self.hud hideAnimated:YES afterDelay:1];
            }else {
                self.hud.label.text = NSLocalizedString(@"changeFailAndTryAgain", nil);
                [self.hud hideAnimated:YES afterDelay:1];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"currentusername"];
        
        DLog(@"gang gang set == %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentusername"]);
        
    }else {
        AlertTool *vc = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"infoNotComplete", nil) style:UIAlertControllerStyleAlert];
        [vc addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:nil]];
        
        [vc show];
         
    }
}

- (void)changeUser
{
    UserListViewController *vc = [[UserListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIPickerViewDataSource有关的代理方法
//返回列数（必须实现）
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回每列里边的行数（必须实现）
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        //返回表情数组的个数
    return _genderArr.count;
}

#pragma mark - UIPickerViewDelegate处理有关的代理方法
//设置组件的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 100;
}
//设置组件中每行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}
//设置组件中每行的标题row:行
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _genderArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.genderLabel setText:_genderArr[row]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag) {
        case 101:
        {
            if (string.length == 0) return YES;
            
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 3) {
                return NO;
            }
        }
            break;
        case 102:
        {
            if (string.length == 0) return YES;
            
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 3) {
                return NO;
            }
        }
            break;
        case 103:
        {
            if (string.length == 0) return YES;
            
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 3) {
                return NO;
            }
        }
            break;
        case 104:
        {
            if (string.length == 0) return YES;
            
            NSInteger existedLength = textField.text.length;
            NSInteger selectedLength = range.length;
            NSInteger replaceLength = string.length;
            if (existedLength - selectedLength + replaceLength > 3) {
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    
    return YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userinfocell"];
    
    if (indexPath.row == 0) {
        [cell.genderLabel setHidden:NO];
        cell.genderLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseGender)];
        [cell.genderLabel addGestureRecognizer:tap];
        [cell.textField setHidden:YES];
        
        if (_userArr.count != 0) {
            UserInfoModel *model = _userArr.firstObject;
            [cell.genderLabel setText:model.gender];
        }
        
        self.genderLabel = cell.genderLabel;
    }else {
        [cell.genderLabel setHidden:YES];
        cell.textField.placeholder = _fieldPlaceholdeArr[indexPath.row];
        cell.textField.delegate = self;
        
        switch (indexPath.row) {
            case 1:
            {
                cell.textField.tag = 101;
                self.ageTextField = cell.textField;
                if (_userArr.count != 0) {
                    UserInfoModel *model = _userArr.firstObject;
                    [self.ageTextField setText:[NSString stringWithFormat:@"%ld",(long)model.age]];
                }
            }
                break;
            case 2:
            {
                cell.textField.tag = 102;
                self.heightTextField = cell.textField;
                if (_userArr.count != 0) {
                    UserInfoModel *model = _userArr.firstObject;
                    //判断是英制还是公制
                    [self.heightTextField setText:[NSString stringWithFormat:@"%ld",(long)self.isMetric ? model.height : [UnitsTool cmAndInch:model.height withMode:MetricToImperial]]];
                }
                
            }
                break;
            case 3:
            {
                cell.textField.tag = 103;
                self.weightTextField = cell.textField;
                if (_userArr.count != 0) {
                    UserInfoModel *model = _userArr.firstObject;
                    [self.weightTextField setText:[NSString stringWithFormat:@"%ld",(long)self.isMetric ? model.weight : [UnitsTool kgAndLb:model.weight withMode:MetricToImperial]]];
                }
                
            }
                
                break;
//            case 4:
//            {
//                cell.textField.tag = 104;
//                self.steplengthTextField = cell.textField;
//                if (_userArr.count != 0) {
//                    UserInfoModel *model = _userArr.firstObject;
//                    [self.steplengthTextField setText:[NSString stringWithFormat:@"%ld",model.stepLength]];
//                }
//                
//            }
//                break;
                
            default:
                break;
        }
        
    }
    
    [cell.nameLabel setText:_nameArr[indexPath.row]];
    [cell.unitLabel setText:_unitArr[indexPath.row]];
    
    cell.userInfoTextFieldBlock = ^(UITextField * textField) {
        _tempField = textField;
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.width * 44 / 320;
}

#pragma mark - BleReceiveDelegate
- (void)receiveUserInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypeUserInfoModel) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            
        }
    }
}

#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 63.5 * WIDTH / 320, 80, 127 * WIDTH / 320, 127 * WIDTH / 320)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.image = [UIImage imageNamed:@"set_userphoto"];
        
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setHeadImage)];
        [imageView addGestureRecognizer:tap];
        
        [self.view addSubview:imageView];
        _headImageView = imageView;
    }
    
    return _headImageView;
}

- (UITextField *)userNameTextField
{
    if (!_userNameTextField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x - 100 * WIDTH / 320, 215 * WIDTH / 320, 200 * WIDTH / 320, 34)];
        textField.placeholder = NSLocalizedString(@"inputUserName", nil);
//        textField.delegate = self;
        
        [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:14];
        
        [self.view addSubview:textField];
        _userNameTextField = textField;
    }
    
    return _userNameTextField;
}

- (UITableView *)infoTableView
{
    if (!_infoTableView) {
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 274 * WIDTH / 320, WIDTH, WIDTH * 220 / 320) style:UITableViewStylePlain];
        view.tableFooterView = [[UIView alloc] init];
        view.scrollEnabled = NO;
        view.allowsSelection = NO;
        
        view.delegate = self;
        view.dataSource = self;
        
        view.backgroundColor = [UIColor clearColor];
        [view registerNib:[UINib nibWithNibName:@"UserInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"userinfocell"];
        
        [self.view addSubview:view];
        _infoTableView = view;
    }
    
    return _infoTableView;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 85 * WIDTH / 320, self.view.frame.size.height - 64 * WIDTH / 320, 170 * WIDTH / 320, 44)];
        [button addTarget:self action:@selector(saveUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 5;
        
        [self.view addSubview:button];
        _saveButton = button;
    }
    
    return _saveButton;
}

- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@""];
    }
    
    return _myFmdbTool;
}

- (BLETool *)myBleTool
{
    if (!_myBleTool) {
        _myBleTool = [BLETool shareInstance];
        _myBleTool.receiveDelegate = self;
    }
    
    return _myBleTool;
}

- (UIPickerView *)genderPickerView
{
    if (!_genderPickerView) {
        UIPickerView *view = [[UIPickerView alloc] initWithFrame:CGRectMake(10, WIDTH * 200 / 320, WIDTH - 20, WIDTH * 100 / 320)];
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _genderPickerView = view;
    }
    
    return _genderPickerView;
}

@end
