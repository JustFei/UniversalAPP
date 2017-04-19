//
//  AboutViewController.m
//  ManridyApp
//
//  Created by JustFei on 2016/11/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AboutViewController.h"
#import "MBProgressHUD.h"
#import "UpdateViewController.h"

#define WIDTH self.view.frame.size.width
#define HEIGHT self.view.frame.size.height

@interface AboutViewController ()

@property (nonatomic ,strong) UIView *upView;
@property (nonatomic ,strong) UIImageView *headImageView;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UIView *cutView;
@property (nonatomic ,strong) UILabel *softwareLabel;
@property (nonatomic ,strong) UILabel *hardwareLabel;
@property (nonatomic ,strong) UIButton *checkUpdateButton;
@property (nonatomic ,strong) MBProgressHUD *hud;

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
    self.nameLabel.text = NSLocalizedString(@"appName", nil);
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.upView addSubview:self.nameLabel];
    
    self.cutView = [[UIView alloc] initWithFrame:CGRectMake(0, WIDTH * 261 / 320, WIDTH, 13 * WIDTH / 320)];
    self.cutView.backgroundColor = [UIColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:199.0 / 255.0 alpha:1];
    [self.view addSubview:self.cutView];
    
    self.softwareLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.cutView.frame.origin.y + 30 * WIDTH / 320, (WIDTH - 30) * WIDTH / 320, 30)];
    self.softwareLabel.backgroundColor = [UIColor clearColor];
    [self.softwareLabel setText:[NSString stringWithFormat:NSLocalizedString(@"softWare", nil),app_Version]];
    [self.view addSubview:self.softwareLabel];
    
    self.hardwareLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.softwareLabel.frame.origin.y + 45 * WIDTH / 320, (WIDTH - 30) * WIDTH / 320,30)];
    self.hardwareLabel.backgroundColor = [UIColor clearColor];
    
    
    self.checkUpdateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.checkUpdateButton.frame = CGRectMake(self.view.frame.size.width - 150, self.hardwareLabel.frame.origin.y, 120, 30);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"checkUpdate", nil)];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:108.0 / 255.0 green:108.0 / 255.0 blue:108.0 / 255.0 alpha:1] range:strRange];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"isBind"]) {
        [self.checkUpdateButton setAttributedTitle:str forState:UIControlStateNormal];
        [self.hardwareLabel setText:[NSString stringWithFormat:NSLocalizedString(@"hardWare", nil),[[NSUserDefaults standardUserDefaults] objectForKey:@"version"]]];
    }else {
        self.checkUpdateButton.hidden = YES;
        self.hardwareLabel.hidden = YES;
    }
    
    [self.checkUpdateButton addTarget:self action:@selector(checkUpdate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.checkUpdateButton];
    [self.view addSubview:self.hardwareLabel];
}

#pragma mark - Action
- (void)checkUpdate:(UIButton *)sender
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //检查设备固件的版本号:高于1.3.4的才支持空中升级
        NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
        version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (version.integerValue >= 134) {
            [self.hud hideAnimated:YES];
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"更新提示" message:@"有新版本，是否更新" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UpdateViewController *udVC = [[UpdateViewController alloc] init];
                 CATransition * animation = [CATransition animation];
                animation.duration = 0.5;    //  时间
                
                /**  type：动画类型
                 *  pageCurl       向上翻一页
                 *  pageUnCurl     向下翻一页
                 *  rippleEffect   水滴
                 *  suckEffect     收缩
                 *  cube           方块
                 *  oglFlip        上下翻转
                 */
                animation.type = @"rippleEffect";
                
                /**  type：页面转换类型
                 *  kCATransitionFade       淡出
                 *  kCATransitionMoveIn     覆盖
                 *  kCATransitionReveal     底部显示
                 *  kCATransitionPush       推出
                 */
                //animation.type = kCATransitionMoveIn;
                
                //PS：type 更多效果请 搜索： CATransition
                
                /**  subtype：出现的方向
                 *  kCATransitionFromRight       右
                 *  kCATransitionFromLeft        左
                 *  kCATransitionFromTop         上
                 *  kCATransitionFromBottom      下
                 */
                //animation.subtype = kCATransitionFromBottom;
                
                [self.view.window.layer addAnimation:animation forKey:nil];
                [self presentViewController:udVC animated:YES completion:nil];
            }];
            UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [vc addAction:okAc];
            [vc addAction:cancelAc];
            [self presentViewController:vc animated:YES completion:nil];
        }else {
            self.hud.label.text = @"暂无更新";
            self.hud.mode = MBProgressHUDModeText;
            [self.hud hideAnimated:YES afterDelay:2];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
