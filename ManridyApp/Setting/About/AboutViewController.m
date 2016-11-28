//
//  AboutViewController.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AboutViewController.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface AboutViewController ()

@property (nonatomic ,strong) UIView *upView;
@property (nonatomic ,strong) UIImageView *headImageView;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UIView *cutView;
@property (nonatomic ,strong) UILabel *softwareLabel;
@property (nonatomic ,strong) UILabel *hardwareLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 261 * WIDTH / 320)];
    self.upView.backgroundColor = [UIColor colorWithRed:77.0 / 255.0 green:170.0 / 255.0 blue:225.0 / 255.0 alpha:1];
    [self.view addSubview:self.upView];
    
    self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 76 * WIDTH / 320, 62, 152 * WIDTH / 320, 161 * WIDTH / 320)];
    self.headImageView.backgroundColor = [UIColor clearColor];
    self.headImageView.image = [UIImage imageNamed:@"about_icon"];
    [self.upView addSubview:self.headImageView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 50, self.headImageView.frame.origin.y + self.headImageView.frame.size.height + 10, 100, 30)];
    self.nameLabel.text = @"瑞动力";
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.upView addSubview:self.nameLabel];
    
    self.cutView = [[UIView alloc] initWithFrame:CGRectMake(0, WIDTH * 261 / 320, WIDTH, 13 * WIDTH / 320)];
    self.cutView.backgroundColor = [UIColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:199.0 / 255.0 alpha:1];
    [self.view addSubview:self.cutView];
    
    self.softwareLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.cutView.frame.origin.y + 30 * WIDTH / 320, 150 * WIDTH / 320, 30)];
    self.softwareLabel.backgroundColor = [UIColor clearColor];
    [self.softwareLabel setText:[NSString stringWithFormat:@"软件版本号：V%@",app_Version]];
    [self.view addSubview:self.softwareLabel];
    
    self.hardwareLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.softwareLabel.frame.origin.y + 45 * WIDTH / 320, 150 * WIDTH / 320,30)];
    self.hardwareLabel.backgroundColor = [UIColor clearColor];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
        [self.hardwareLabel setText:[NSString stringWithFormat:@"固件版本号：V%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"version"]]];
    }
    [self.view addSubview:self.hardwareLabel];
}

#pragma mark - Action
- (void)checkUpDate:(UIButton *)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
