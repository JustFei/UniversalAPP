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

@interface AboutViewController () < NSXMLParserDelegate >

@property (nonatomic ,strong) UIView *upView;
@property (nonatomic ,strong) UIImageView *headImageView;
@property (nonatomic ,strong) UILabel *nameLabel;
@property (nonatomic ,strong) UIView *cutView;
@property (nonatomic ,strong) UILabel *softwareLabel;
@property (nonatomic ,strong) UILabel *hardwareLabel;
@property (nonatomic ,strong) UIButton *checkUpdateButton;
@property (nonatomic ,strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) UIAlertController *updateAc;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLabel setText:NSLocalizedString(@"about", nil)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.view.backgroundColor = COLOR_WITH_HEX(0xf5f5f5, 1);
    
    self.upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 261 * WIDTH / 320)];
    self.upView.backgroundColor = COLOR_WITH_HEX(0x1e88e5, 1);
    [self.view addSubview:self.upView];
    
    self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 76 * WIDTH / 320, 62, 152 * WIDTH / 320, 161 * WIDTH / 320)];
    self.headImageView.backgroundColor = [UIColor clearColor];
    self.headImageView.image = [UIImage imageNamed:@"about_image"];
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
//    self.checkUpdateButton.hidden = YES;
    [self.view addSubview:self.hardwareLabel];
}

#pragma mark - Action
- (void)checkUpdate:(UIButton *)sender
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([BLETool shareInstance].connectState == kBLEstateDisConnected) {
            self.hud.label.text = NSLocalizedString(@"NotConnectToUpdate", nil);
            [self.hud hideAnimated:YES afterDelay:2];
        }else {
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.label.text = NSLocalizedString(@"CheckingUpdate", nil);
            NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
            if ([version compare:@"2.0" options:NSNumericSearch] == NSOrderedDescending || [version compare:@"2.0" options:NSNumericSearch] == NSOrderedSame) {
                NSURL *url = [NSURL URLWithString:@"http://39.108.92.15:12345/version.xml"];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:10.0];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    NSLog(@"connectionError == %@", connectionError);
                    if (!connectionError) {
                        //创建xml解析器
                        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
                        //设置代理
                        parser.delegate = self;
                        //开始解析
                        [parser parse];
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.hud.label setText:NSLocalizedString(@"NetError", nil)];
                            [self.hud hideAnimated:YES afterDelay:2];
                        });
                    }
                }];
            }else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.hud.label setText:NSLocalizedString(@"NOUpdate", nil)];
                    [self.hud hideAnimated:YES afterDelay:1.5];
                });
            }
            
        }
    });
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"1.开始文档");
}

//每发现一个开始节点就调用

/**
 *  每发现一个节点就调用
 *  *  @param parser        解析器
 *  @param elementName   节点名字
 *  @param attributeDict 属性字典
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    NSLog(@"2.发现节点：%@",elementName);
    if ([elementName isEqualToString:@"product"])
    {
        //获取 id 号
        NSString *idcount = attributeDict[@"id"];
        if ([idcount isEqualToString:@"0000"]) {
            self.filePath = [@"http://39.108.92.15:12345" stringByAppendingString:[NSString stringWithFormat:@"/0000/%@", attributeDict[@"file"]]];
            NSString *verInServer = attributeDict[@"least"];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
                NSString *hardVer = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
                if ([verInServer compare:hardVer options:NSNumericSearch] == NSOrderedDescending) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud hideAnimated:YES afterDelay:1];
                        //提示是否更新
                        [self.updateAc setMessage:[NSString stringWithFormat:NSLocalizedString(@"ChoseWheatherUpdate", nil), verInServer]];
                        [self presentViewController:self.updateAc animated:YES completion:nil];
                    });
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud.label setText:NSLocalizedString(@"NOUpdate", nil)];
                        [self.hud hideAnimated:YES afterDelay:2];
                    });
                }
            }
        }
    }
    
    //    [self.elementNameString setString:@""];
}

//发现节点内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    NSLog(@"3.发现节点内容：%@",string);
    //把发现的内容进行拼接
    //    [self.elementNameString appendString:string];
}

//发现结束节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    NSLog(@"3.发现结束节点 %@",elementName);
    //    NSLog(@"拼接的内容%@",self.elementNameString);
    
    if ([elementName isEqualToString:@"name"])
    {
        //        self.video.name = self.elementNameString;
    }else if ([elementName isEqualToString:@"teacher"])
    {
        //        self.video.teacher = self.elementNameString;
    }
}

//解析完毕调用
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"解析完毕---------");
    
    //    NSLog(@"%@",self.video);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy
- (UIAlertController *)updateAc
{
    if (!_updateAc) {
        _updateAc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tips", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *okAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UpdateViewController *vc = [[UpdateViewController alloc] init];
            vc.filePa = self.filePath;
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [_updateAc addAction:cancelAc];
        [_updateAc addAction:okAc];
    }
    
    return _updateAc;
}


@end
