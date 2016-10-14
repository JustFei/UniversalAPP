//
//  UserListViewController.m
//  ManridyApp
//
//  Created by JustFei on 16/10/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserListViewController.h"
#import "FMDBTool.h"
#import "UserInfoModel.h"

@interface UserListViewController () <UITableViewDelegate ,UITableViewDataSource >
{
    NSArray *_userArr;
}
@property (nonatomic ,weak) UITableView *userListTableView;

@property (nonatomic ,weak) UIButton *addUser;

@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userArr = [self.myFmdbTool queryAllUserInfo];
    
    self.view.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    self.userListTableView.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.addUser setTitle:@"添加用户" forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)addUserAction
{
    
}


#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userlistcell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userlistcell"];
    }
    
    UserInfoModel *model = _userArr[indexPath.row];
    
    cell.textLabel.text = model.userName;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}




#pragma mark - 懒加载
- (FMDBTool *)myFmdbTool
{
    if (!_myFmdbTool) {
        _myFmdbTool = [[FMDBTool alloc] initWithPath:@"UserList"];
    }
    
    return _myFmdbTool;
}

- (UITableView *)userListTableView
{
    if (!_userListTableView) {
       
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, _userArr.count * 44) style:UITableViewStylePlain];
        
        if (_userArr.count * 44 + 64 < self.view.frame.size.height - self.view.frame.size.width * 90 / 320) {
            view.frame = CGRectMake(0, 64, self.view.frame.size.width, _userArr.count * 44);
        }else {
            view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - self.view.frame.size.width * 154 / 320);
        }
        
        view.backgroundColor = [UIColor redColor];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self.view addSubview:view];
        _userListTableView = view;
    }
    
    return _userListTableView;
}

- (UIButton *)addUser
{
    if (!_addUser) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - self.view.frame.size.width * 100 / 320, self.userListTableView.frame.origin.y + self.userListTableView.frame.size.height + 20, self.view.frame.size.width * 200 / 320, self.view.frame.size.width * 40 / 320)];
        
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5;
        
        [button addTarget:self action:@selector(addUserAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _addUser = button;
    }
    
    return _addUser;
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
