//
//  UserInfoViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoViewController1.h"
#import "UserInfoTableViewCell.h"
#import "FMDBTool.h"
#import "BLETool.h"
#import "UserInfoModel.h"
#import "UserInfoSettingModel.h"
#import "UnitsTool.h"
#import "Masonry.h"
#import "MBProgressHUD.h"

#define USER_INFO_SETTING @"UserInfoSetting"
#define USER_NAME_SETTING @"UserNameSetting"
#define USER_HEADIMAGE_SETTING @"UserHeadimageSetting"

typedef enum : NSUInteger {
    PickerTypeGender = 0,
    PickerTypeAge,
    PickerTypeHeight,
    PickerTypeWeight,
} PickerType;

static NSString * const UserInfoTableViewCellID = @"UserInfoTableViewCell";

@interface UserInfoViewController1 () <UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate ,UINavigationControllerDelegate ,UIImagePickerControllerDelegate ,UIAlertViewDelegate ,UIPickerViewDelegate ,UIPickerViewDataSource, BleReceiveDelegate>

@property (nonatomic, weak) UIImageView *headImageView;
@property (nonatomic, weak) UITextField *userNameTextField;
@property (nonatomic, weak) UITableView *infoTableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) BOOL isMetric;
@property (nonatomic, assign) PickerType pickerType;
@property (nonatomic, strong) UIPickerView *infoPickerView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray *genderArr;
@property (nonatomic, strong) NSArray *ageArr;
@property (nonatomic, strong) NSArray *heightArr;
@property (nonatomic, strong) NSArray *weightArr;
@property (nonatomic, strong) UserInfoModel *infoModel;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation UserInfoViewController1

#pragma mark - lyfeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMetric = [self isMetricOrImperialSystem];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:NSLocalizedString(@"userInfo", nil)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = COLOR_WITH_HEX(0x1e88e5, 1);
    
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //监听写入的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserInfoWhetherSuccess:) name:SET_USER_INFO object:nil];
    [BLETool shareInstance].receiveDelegate = self;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = TEXT_BLACK_COLOR_LEVEL1;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameTextField.mas_bottom).offset(16);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@8);
    }];
    
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self setSaveUI];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveUserInfo)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)dealloc
{
    //注销掉所有代理和关闭数据库
    
}

//- (void)setInitUI
//{
//    self.headImageView.backgroundColor = CLEAR_COLOR;
//}

- (void)setSaveUI
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME_SETTING]) {
        NSLog(@"hello == %@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME_SETTING]);
        [self.userNameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME_SETTING]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_HEADIMAGE_SETTING]) {
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_HEADIMAGE_SETTING];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)setHeadImage
{
    AlertTool *alert = [AlertTool alertWithTitle:nil message:nil style:UIAlertControllerStyleActionSheet];
    [alert addAction:[AlertAction actionWithTitle:NSLocalizedString(@"choosePhotoFromPhotoAlbum", nil) style:AlertToolStyleDefault handler:^(AlertAction *action) {
        UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
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

- (void)showInfoPickerView:(NSString *)infoText
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.currentIndex = -1;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        switch (self.pickerType) {
            case PickerTypeGender:
                self.infoModel.gender = self.currentIndex;
                break;
            case PickerTypeAge:
                self.infoModel.age = self.currentIndex;
                break;
            case PickerTypeHeight:
                self.infoModel.height = self.currentIndex;
                break;
            case PickerTypeWeight:
                self.infoModel.weight = self.currentIndex;
                break;
                
            default:
                break;
        }
        self.dataArr = nil;
        [self.infoTableView reloadData];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    self.infoPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width - 30, 216)];
    self.infoPickerView.dataSource = self;
    self.infoPickerView.delegate = self;
    switch (self.pickerType) {
        case PickerTypeGender:
        {
            NSInteger index;
            if (![infoText isEqualToString:NSLocalizedString(@"PlsChose", nil)]) {
                index = self.infoModel.gender;
            }else {
                index = 0;
            }
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeAge:
        {
            NSInteger index;
            if (![infoText isEqualToString:NSLocalizedString(@"PlsChose", nil)]) {
                index = self.infoModel.age;
            }else {
                index = 0;
            }
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeHeight:
        {
            NSInteger index;
            if (![infoText isEqualToString:NSLocalizedString(@"PlsChose", nil)]) {
                index = self.infoModel.height;
            }else {
                index = 0;
            }
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
        case PickerTypeWeight:
        {
            NSInteger index;
            if (![infoText isEqualToString:NSLocalizedString(@"PlsChose", nil)]) {
                index = self.infoModel.weight;
            }else {
                index = 0;
            }
            [self.infoPickerView selectRow:index inComponent:0 animated:NO];
            [alert.view addSubview:self.infoPickerView];
        }
            break;
            
        default:
            break;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -ButtonAction
- (void)saveUserInfo
{
    [self.view endEditing:YES];
    if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.label.text = NSLocalizedString(@"NoConnectToSave", nil);
        [self.hud hideAnimated:YES afterDelay:2];
    }else {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        [[BLETool shareInstance] writeUserInfoToPeripheralWeight: self.weightArr[self.infoModel.weight] andHeight:self.heightArr[self.infoModel.height]];
    }
}

#pragma mark - BleReceiveDelegate
- (void)receiveUserInfoWithModel:(manridyModel *)manridyModel
{
    if (manridyModel.receiveDataType == ReturnModelTypeUserInfoModel) {
        if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
            //写入本地
            self.hud.label.text = NSLocalizedString(@"saveSuccess", nil);
            [self.hud hideAnimated:YES afterDelay:2];
            //保存用户名
            [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text ? self.userNameTextField.text : NSLocalizedString(@"userName", nil) forKey:USER_NAME_SETTING];
            //保存用户头像
            NSData *imageData = UIImagePNGRepresentation(self.headImageView.image);
            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:USER_HEADIMAGE_SETTING];
            //保存用户的其他基本信息
            self.infoModel.userName = self.userNameTextField.text ? self.userNameTextField.text : NSLocalizedString(@"userName", nil);
            NSData *infoData = [NSKeyedArchiver archivedDataWithRootObject:self.infoModel];
            [[NSUserDefaults standardUserDefaults] setObject:infoData forKey:USER_INFO_SETTING];
        }else {
            self.hud.label.text = NSLocalizedString(@"saveFail", nil);
            [self.hud hideAnimated:YES afterDelay:2];
        }
    }
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
// UIPickerViewDataSource中定义的方法，该方法的返回值决定改控件包含多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// UIPickerViewDataSource中定义的方法，该方法的返回值决定该控件指定列包含多少哥列表项

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case PickerTypeGender:
            return self.genderArr.count;
            break;
        case PickerTypeAge:
            return self.ageArr.count;
            break;
        case PickerTypeHeight:
            return self.heightArr.count;
            break;
        case PickerTypeWeight:
            return self.weightArr.count;
            break;
            
        default:
            break;
    }
    
    return 0;
}

// UIPickerViewDelegate中定义的方法，该方法返回NSString将作为UIPickerView中指定列和列表项上显示的标题

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (self.pickerType) {
        case PickerTypeGender:
            return self.genderArr[row];
            break;
        case PickerTypeAge:
            return self.ageArr[row];
            break;
        case PickerTypeWeight:
            return self.weightArr[row];
            break;
        case PickerTypeHeight:
            return self.heightArr[row];
            break;
            
        default:
            break;
    }
    return 0;
}

// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component

{
    switch (self.pickerType) {
        case PickerTypeGender:
            self.currentIndex = row;
            break;
            
        case PickerTypeAge:
            self.currentIndex = row;
            break;
            
        case PickerTypeHeight:
            self.currentIndex = row;
            break;
            
        case PickerTypeWeight:
            self.currentIndex = row;
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.pickerType = indexPath.row;
    UserInfoSettingModel *model = self.dataArr[indexPath.row];
    [self showInfoPickerView:model.placeHoldText];
}

#pragma mark - 懒加载
- (UIImageView *)headImageView
{
    if (!_headImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = CLEAR_COLOR;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_HEADIMAGE_SETTING]) {
            NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_HEADIMAGE_SETTING];
            [imageView setImage:[UIImage imageWithData:imageData]];
        }else {
            [imageView setImage:[UIImage imageNamed:@"set_avatar1"]];
        }
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setHeadImage)];
        [imageView addGestureRecognizer:tap];
        
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(16);
            make.width.equalTo(@127);
            make.height.equalTo(@127);
        }];
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.cornerRadius = 127 / 2;
        
        _headImageView = imageView;
    }
    
    return _headImageView;
}

- (UITextField *)userNameTextField
{
    if (!_userNameTextField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME_SETTING] ? [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME_SETTING] : NSLocalizedString(@"userName", nil);
        
//        [textField setValue:WHITE_COLOR forKeyPath:@"_placeholderLabel.textColor"];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:14];
        
        [self.view addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.headImageView.mas_bottom).offset(33);
            make.width.equalTo(@200);
            make.height.equalTo(@34);
        }];
        _userNameTextField = textField;
    }
    
    return _userNameTextField;
}

- (UITableView *)infoTableView
{
    if (!_infoTableView) {
        UITableView *_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _tableView.backgroundColor = COLOR_WITH_HEX(0xf5f5f5, 1);
        
        [_tableView registerClass:NSClassFromString(UserInfoTableViewCellID)forCellReuseIdentifier:UserInfoTableViewCellID];
        
        [self.view addSubview:_tableView];
        _infoTableView = _tableView;
    }
    
    return _infoTableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSArray *nameArr = @[NSLocalizedString(@"gender", nil),NSLocalizedString(@"age", nil),NSLocalizedString(@"height", nil),NSLocalizedString(@"weight", nil)];
        NSArray *fieldPlaceholdeArr;
        if (self.infoModel) {
            fieldPlaceholdeArr = @[self.infoModel.gender ? NSLocalizedString(@"Female", nil) : NSLocalizedString(@"male", nil),
                                   self.infoModel.age ? self.ageArr[self.infoModel.age] : NSLocalizedString(@"PlsChose", nil),
                                   self.infoModel.height ? self.heightArr[self.infoModel.height] : NSLocalizedString(@"PlsChose", nil),
                                   self.infoModel.weight ? self.weightArr[self.infoModel.weight] : NSLocalizedString(@"PlsChose", nil)];
        }else {
            fieldPlaceholdeArr = @[NSLocalizedString(@"PlsChose", nil),NSLocalizedString(@"PlsChose", nil),NSLocalizedString(@"PlsChose", nil),NSLocalizedString(@"PlsChose", nil)];
        }
        
        NSArray *unitArr = @[@"",NSLocalizedString(@"year", nil),self.isMetric ? @"(cm)" : @"(In)",self.isMetric ? @"(kg)" : @"(lb)"];
        NSMutableArray *mutArr = [NSMutableArray array];
        for (int index = 0; index < nameArr.count; index ++) {
            UserInfoSettingModel *model = [[UserInfoSettingModel alloc] init];
            model.nameText = nameArr[index];
            model.placeHoldText = fieldPlaceholdeArr[index];
            model.unitText = unitArr[index];
            model.isGenderCell = index == 0 ? YES : NO;
            [mutArr addObject:model];
        }
        
        _dataArr = [NSArray arrayWithArray:mutArr];
    }
    
    return _dataArr;
}

- (UserInfoModel *)infoModel
{
    if (!_infoModel) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING]) {
            NSData *infoData = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_SETTING];
            _infoModel = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
        }else {
            _infoModel = [[UserInfoModel alloc] init];
        }
    }
    return _infoModel;
}

- (NSArray *)genderArr
{
    if (!_genderArr) {
        _genderArr = @[NSLocalizedString(@"Female", nil) , NSLocalizedString(@"male", nil)];
    }
    return _genderArr;
}

- (NSArray *)ageArr
{
    if (!_ageArr) {
        NSMutableArray *ageMutArr = [NSMutableArray array];
        for (int i = 0; i <= 100; i ++) {
            NSString *age = [NSString stringWithFormat:@"%d",i];
            [ageMutArr addObject:age];
        }
        _ageArr = ageMutArr;
    }
    return _ageArr;
}

- (NSArray *)heightArr
{
    if (!_heightArr) {
        NSMutableArray *heightMutArr = [NSMutableArray array];
        for (int i = 90; i <= 200; i ++) {
            NSString *height = [NSString stringWithFormat:@"%d",i];
            [heightMutArr addObject:height];
        }
        _heightArr = heightMutArr;
    }
    
    return _heightArr;
}

- (NSArray *)weightArr
{
    if (!_weightArr) {
        NSMutableArray *weightMutArr = [NSMutableArray array];
        for (int i = 15; i <= 150; i ++) {
            NSString *weight = [NSString stringWithFormat:@"%d",i];
            [weightMutArr addObject:weight];
        }
        _weightArr = weightMutArr;
    }
    
    return _weightArr;
}

@end
