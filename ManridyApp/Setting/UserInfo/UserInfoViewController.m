//
//  UserInfoViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/9/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfoCell.h"

@interface UserInfoViewController () <UITableViewDelegate ,UITableViewDataSource ,UITextFieldDelegate >
{
    NSArray *_nameArr;
    NSArray *_fieldPlaceholdeArr;
    NSArray *_unitArr;
    UITextField *_tempField;
}

@property (nonatomic ,weak) UIButton *headButton;

@property (nonatomic ,weak) UITextField *userNameTextField;

@property (nonatomic ,weak) UITableView *infoTableView;

@property (nonatomic ,weak) UIButton *saveButton;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _nameArr = @[@"性别",@"年龄",@"身高",@"体重",@"步长"];
    _fieldPlaceholdeArr = @[@"",@"请输入年龄",@"请输入身高",@"请输入体重",@"请输入步长"];
    _unitArr = @[@"",@"(岁)",@"(cm)",@"(kg)",@"(cm)"];
    
    self.navigationItem.title = @"用户信息";
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    
    self.headButton.backgroundColor = [UIColor clearColor];
    self.userNameTextField.borderStyle = UITextBorderStyleNone;
    self.userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 261, self.view.frame.size.width, 13)];
    view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [self.view addSubview:view];
    
    self.infoTableView.backgroundColor = [UIColor clearColor];
    
    [self.saveButton setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSLog(@"%@",notification);
    
    //1. 获取键盘的 Y 值
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //或者  keyboardFrame = [[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeadImage
{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    _tempField = textField;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
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
        [cell.textField setHidden:YES];
    }else {
        [cell.genderLabel setHidden:YES];
        cell.textField.placeholder = _fieldPlaceholdeArr[indexPath.row];
        cell.textField.delegate = self;
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
    return 44;
}

#pragma mark - 懒加载
- (UIButton *)headButton
{
    if (!_headButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 63.5, 80, 127, 127)];
        
        [button setBackgroundImage:[UIImage imageNamed:@"set_userphoto"] forState:UIControlStateNormal];
        [button setTitle:@"设置头像" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(setHeadImage) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        _headButton = button;
    }
    
    return _headButton;
}

- (UITextField *)userNameTextField
{
    if (!_userNameTextField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x - 100, 215, 200, 34)];
        textField.placeholder = @"请输入用户名";
        textField.delegate = self;
        
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
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 274, self.view.frame.size.width, 220) style:UITableViewStylePlain];
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
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - 85, self.infoTableView.frame.origin.y + 220 + 20, 170, 44)];
        [button setTitle:@"保存" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 5;
        
        [self.view addSubview:button];
        _saveButton = button;
    }
    
    return _saveButton;
}

/*
#pragma mark - Navigationpp

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
