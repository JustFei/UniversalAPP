//
//  BLETool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLETool.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "manridyBleDevice.h"
#import "manridyModel.h"
#import "NSStringTool.h"
#import "AnalysisProcotolTool.h"
#import "AllBleFmdb.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

#define kServiceUUID              @"F000EFE0-0000-4000-0000-00000000B000"
#define kWriteCharacteristicUUID  @"F000EFE1-0451-4000-0000-00000000B000"
#define kNotifyCharacteristicUUID @"F000EFE3-0451-4000-0000-00000000B000"

#define kCurrentVersion @"1.0"


@interface BLETool () <CBCentralManagerDelegate,CBPeripheralDelegate , UNUserNotificationCenterDelegate>


@property (nonatomic ,strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic ,strong) CBCharacteristic *writeCharacteristic;

@property (nonatomic ,strong) NSMutableArray *deviceArr;

@property (nonatomic ,strong) CBCentralManager *myCentralManager;

@property (nonatomic ,strong) AllBleFmdb *fmTool;

@property (nonatomic ,strong) UIAlertView *disConnectView;

@property (nonatomic, strong) UNMutableNotificationContent *notiContent;

@end

@implementation BLETool


#pragma mark - Singleton
static BLETool *bleTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        _fmTool = [[AllBleFmdb alloc] init];
        self.notiContent = [[UNMutableNotificationContent alloc] init];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleTool = [[self alloc] init];
    });
    
    return bleTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleTool = [super allocWithZone:zone];
    });
    
    return bleTool;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - get sdk version -获取SDK版本号
- (NSString *)getManridyBleSDKVersion
{
    return kCurrentVersion;
}

#pragma mark - action of connecting layer -连接层操作
- (void)scanDevice
{
    [self.deviceArr removeAllObjects];
    self.connectState = kBLEstateDisConnected;
    [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan
{
    [_myCentralManager stopScan];
}

- (void)connectDevice:(manridyBleDevice *)device
{
    self.currentDev = device;
    //请求连接到此外设
    [_myCentralManager connectPeripheral:device.peripheral options:nil];
}

- (void)unConnectDevice
{
//    isDisconnect = 1;
    if (self.currentDev.peripheral) {
        [self.myCentralManager cancelPeripheralConnection:self.currentDev.peripheral];
    }
}

//- (void)reConnectDevice:(BOOL)isConnect
//{
//    isReconnect = isConnect;
//}

- (NSArray *)retrieveConnectedPeripherals
{
    return [_myCentralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}

#pragma mark - data of write -写入数据操作
//set time
- (void)writeTimeToPeripheral:(NSDate *)currentDate
{
    NSDateFormatter *currentFormatter = [[NSDateFormatter alloc] init];
    [currentFormatter setDateFormat:@"yyMMddhhmmssEEE"];
    NSString *currentStr = [currentFormatter stringFromDate:currentDate];
    
    //传入时间和头，返回协议字符串
    NSString *protocolStr = [NSStringTool protocolAddInfo:currentStr head:@"00"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"time success");
    }
}

#if 0
//set clock
- (void)writeClockToPeripheral:(ClockData)state withModel:(manridyModel *)model
{
    if (state == ClockDataSetClock) {
        NSLog(@"设置闹钟");
        
        NSString *clockStateStr = [[NSString alloc] init];
        NSString *clockDataStr = [[NSString alloc] init];
        
        for (int index = 0; index < 5; index ++) {
            
            if (index < model.clockModelArr.count) {
                ClockModel *clockModel = model.clockModelArr[index];
                NSString *state;
                if (clockModel.isOpen) {
                    state = @"01";
                }else {
                    state = @"02";
                }
                
                NSString *clock = [clockModel.time stringByReplacingOccurrencesOfString:@":" withString:@""];
                
                clockStateStr = [clockStateStr stringByAppendingString:state];
                clockDataStr = [clockDataStr stringByAppendingString:clock];
            }else {
                clockStateStr = [clockStateStr stringByAppendingString:@"00"];
                clockDataStr = [clockDataStr stringByAppendingString:@"0000"];
            }
        }
        
        clockStateStr = [clockStateStr stringByAppendingString:clockDataStr];
        
        NSLog(@"设置闹钟的协议文本部分%@, 长度为%ld",clockStateStr ,(unsigned long)clockStateStr.length);
        
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSString stringWithFormat:@"FC0100%@0000",clockStateStr];
        
        //写入操作
        if (self.currentDev.peripheral) {
            [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        
        
    }else {
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"01"];
        
        //写入操作
        if (self.currentDev.peripheral) {
            [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"clock success");
        }
    }
}
#endif

//get motionInfo
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:[NSString stringWithFormat:@"%ld",type] head:@"03"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type: CBCharacteristicWriteWithResponse];
        NSLog(@"motion success");
    }
}

//set motionInfo zero
- (void)writeMotionZeroToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"04"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}
//get GPS data
- (void)writeGPSToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"05"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"gps success");
    }
}

//set userInfo
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height
{
    NSString *userInfoStr = [weight stringByAppendingString:[NSString stringWithFormat:@",%@",height]];
    
    userInfoStr = [NSStringTool protocolAddInfo:userInfoStr head:@"06"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:userInfoStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//set motion target
- (void)writeMotionTargetToPeripheral:(NSString *)target
{
    NSString *targetStr = [NSStringTool protocolAddInfo:target head:@"07"];
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:targetStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//set heart rate test state
- (void)writeHeartRateTestStateToPeripheral:(HeartRateTestState)state
{
    switch (state) {
        case HeartRateTestStateStop:
            //stop heart rate test
        {
            NSString *stopStr = [NSStringTool protocolAddInfo:@"00" head:@"09"];
            
            if (self.currentDev.peripheral) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:stopStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            }
        }
            break;
        case HeartRateTestStateStart:
            //start heart rate test
        {
            NSString *startStr = [NSStringTool protocolAddInfo:@"01" head:@"09"];
            
            if (self.currentDev.peripheral) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:startStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            }
        }
            break;
            
        default:
            break;
    }
}

//get heart rate data
- (void)writeHeartRateRequestToPeripheral:(HeartRateData)heartRateData
{
    switch (heartRateData) {
        case HeartRateDataLastData:
            //last data of heart rate
        {
            NSString *lastStr = [NSStringTool protocolAddInfo:@"00" head:@"0A"];
            
            if (self.currentDev.peripheral) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:lastStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
                NSLog(@"heartRate success");
            }
        }
            break;
        case HeartRateDataHistoryData:
            //history data of heart rate
        {
            NSString *historyStr = [NSStringTool protocolAddInfo:@"01" head:@"0A"];
            
            if (self.currentDev.peripheral) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:historyStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            }
        }
            break;
            
        default:
            break;
    }
}

//get sleepInfo
- (void)writeSleepRequestToperipheral:(SleepData)sleepData
{
    NSString *sleepStr;
    switch (sleepData) {
        case SleepDataLastData:
            //last data of sleep
            sleepStr = [NSStringTool protocolAddInfo:@"00" head:@"0C"];
            NSLog(@"sleep success");
            
            break;
        case SleepDataHistoryData:
            //history data of sleep
            sleepStr = [NSStringTool protocolAddInfo:@"01" head:@"0C"];
            
            break;
            
        default:
            break;
    }
    
    //写入操作
    if (self.currentDev.peripheral) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:sleepStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBCentralManagerDelegate
//检查设备蓝牙开关的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message = nil;
    switch (central.state) {
        case 1:
            message = @"该设备不支持蓝牙功能，请检查系统设置";
            break;
        case 2:
            message = @"该设备蓝牙未授权，请检查系统设置";
            break;
        case 3:
            message = @"该设备蓝牙未授权，请检查系统设置";
            break;
        case 4:
            message = @"该设备尚未打开蓝牙，请在设置中打开";
            break;
        case 5:

            break;

        default:
            break;
    }
    
    if (message != nil && message.length != 0) {
        NSLog(@"message == %@",message);
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:nil]];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *currentvc = delegate.window.rootViewController;
        [currentvc presentViewController:vc  animated:YES completion:nil];
        
    }
    
        [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

//查找到正在广播的指定外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"Discovered %@", peripheral.name);
    //...
    //当你发现你感兴趣的连接外围设备，停止扫描其他设备，以节省电能。
    if (![peripheral.name isEqualToString:@""]) {
        
        if (![self.deviceArr containsObject:peripheral]) {
            [self.deviceArr addObject:peripheral];
            
            manridyBleDevice *device = [[manridyBleDevice alloc] initWith:peripheral andAdvertisementData:advertisementData andRSSI:RSSI];
            
            //返回扫描到的设备实例
            if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                
                [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
            }
        }
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"Peripheral connected");
    
    peripheral.delegate = self;
    //传入nil会返回所有服务;一般会传入你想要服务的UUID所组成的数组,就会返回指定的服务
    [peripheral discoverServices:nil];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mainVc showFunctionView];
    
    [self.disConnectView dismissWithClickedButtonIndex:0 animated:NO];
}

//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
//    NSLog(@"连接失败");
    
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidFailConnectDevice:)]) {
        [self.connectDelegate manridyBLEDidFailConnectDevice:self.currentDev];
    }
    
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectState = kBLEstateDisConnected;
    if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidDisconnectDevice:)]) {
        [self.connectDelegate manridyBLEDidDisconnectDevice:self.currentDev];
    }
    
    if (self.isReconnect) {
        NSLog(@"需要断线重连");
        [self.myCentralManager connectPeripheral:self.currentDev.peripheral options:nil];
        
        self.disConnectView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备意外断开，等待重连" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        self.disConnectView.tag = 103;
        [self.disConnectView show];
        // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = @"手环丢失通知";
        // 次标题
        content.subtitle = @"注意！您的手环已经处于非连接状态，可能已经丢失！";
        // 内容
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSString *dateStr = [formatter stringFromDate:date];
        content.body = [NSString stringWithFormat:@"注意！您的手环已于%@离开可连接范围，可能丢失！请注意！",dateStr];
        
        //            self.badge++;
        // app显示通知数量的角标
        //            content.badge = @(self.badge);
        
        // 通知的提示声音，这里用的默认的声音
        content.sound = [UNNotificationSound defaultSound];
        
        NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:@"all_next_icon" withExtension:@"png"];
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"imageIndetifier" URL:imageUrl options:nil error:nil];
        
        // 附件 可以是音频、图片、视频 这里是一张图片
        content.attachments = @[attachment];
        
        // 标识符
        content.categoryIdentifier = @"categoryIndentifier";
        
        // 2、创建通知触发
        /* 触发器分三种：
         UNTimeIntervalNotificationTrigger : 在一定时间后触发，如果设置重复的话，timeInterval不能小于60
         UNCalendarNotificationTrigger : 在某天某时触发，可重复
         UNLocationNotificationTrigger : 进入或离开某个地理区域时触发
         */
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        
        // 3、创建通知请求
        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification" content:content trigger:trigger];
        
        // 4、将请求加入通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"已成功加推送%@",notificationRequest.identifier);
            }
        }];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.mainVc hiddenFunctionView];
        
    }else {
        self.currentDev = nil;
    }

}

#pragma mark - CBPeripheralDelegate
//发现到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        
        //返回特定的写入，订阅的特征即可
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kWriteCharacteristicUUID],[CBUUID UUIDWithString:kNotifyCharacteristicUUID]] forService:service];
    }
}

//获得某服务的特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
//    NSLog(@"Discovered characteristic %@", service.characteristics);
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
//        [peripheral readValueForCharacteristic:characteristic];
//        
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];

        
        //保存写入特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
            
            self.writeCharacteristic = characteristic;
        }
        
        //保存订阅特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotifyCharacteristicUUID]]) {
            self.notifyCharacteristic = characteristic;
            
            if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidConnectDevice:)]) {
                if (self.currentDev.peripheral == peripheral) {
                    self.connectState = kBLEstateDidConnected;
                    [self.connectDelegate manridyBLEDidConnectDevice:self.currentDev];
                }
            }
            
            //订阅该特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    
}

//获得某特征值变化的通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error changing notification state: %@",[error localizedDescription]);
    }else {
        NSLog(@"Success cahnging notification state: %d;value = %@",characteristic.isNotifying ,characteristic.value);
    }
}

//订阅特征值发送变化的通知，所有获取到的值都将在这里进行处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"updateValue == %@",characteristic);
    
    [self analysisDataWithCharacteristic:characteristic.value];
    
}

//写入某特征值后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }else {
        NSLog(@"Success writing chararcteristic value: %@",characteristic);
    }
}

#pragma mark - 数据解析
- (void)analysisDataWithCharacteristic:(NSData *)value
{
    if ([value bytes] != nil) {
        const unsigned char *hexBytes = [value bytes];
        
        //命令字段
        NSString *headStr = [NSString stringWithFormat:@"%02x", hexBytes[0]];
        
        if ([headStr isEqualToString:@"00"] || [headStr isEqualToString:@"80"]) {
            //解析设置时间数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSetTimeData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveSetTimeDataWithModel:)]) {
                [self.receiveDelegate receiveSetTimeDataWithModel:model];
            }
            
        }else if ([headStr isEqualToString:@"01"] || [headStr isEqualToString:@"81"]) {
            //解析闹钟数据
//            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisClockData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveSetClockDataWithModel:)]) {
//                [self.receiveDelegate receiveSetClockDataWithModel:model];
            }

        }else if ([headStr isEqualToString:@"03"] || [headStr isEqualToString:@"83"]) {
            //解析获取的步数数据
            manridyModel *model =  [[AnalysisProcotolTool shareInstance] analysisGetSportData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveMotionDataWithModel:)]) {
                [self.receiveDelegate receiveMotionDataWithModel:model];
            }else {
//                [_fmTool saveMotionToDataBase:model];
            }

        }else if ([headStr isEqualToString:@"04"] || [headStr isEqualToString:@"84"]) {
            //运动清零
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSportZeroData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveDataWithModel:)]) {
                [self.receiveDelegate receiveDataWithModel:model];
            }
            
        }else if ([headStr isEqualToString:@"05"] || [headStr isEqualToString:@"85"]) {
            //获取到历史的GPS数据信息
//            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHistoryGPSData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveGPSWithModel:)]) {
//                [self.receiveDelegate receiveGPSWithModel:model];
//                [_fmTool saveGPSToDataBase:model];
            }else {
//                [_fmTool saveGPSToDataBase:model];
            }

        }else if ([headStr isEqualToString:@"06"] || [headStr isEqualToString:@"86"]) {
            //用户信息推送
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisUserInfoData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveUserInfoWithModel:)]) {
                [self.receiveDelegate receiveUserInfoWithModel:model];
            }

        }else if ([headStr isEqualToString:@"07"] || [headStr isEqualToString:@"87"]) {
            //运动目标推送
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSportTargetData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveMotionTargetWithModel:)]) {
                [self.receiveDelegate receiveMotionTargetWithModel:model];
            }
            
        }else if ([headStr isEqualToString:@"09"] || [headStr isEqualToString:@"89"]) {
            //心率开关
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartStateData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveHeartRateTestWithModel:)]) {
                [self.receiveDelegate receiveHeartRateTestWithModel:model];
            }
            
        }else if ([headStr isEqualToString:@"0a"] || [headStr isEqualToString:@"0A"] || [headStr isEqualToString:@"8a"] || [headStr isEqualToString:@"8A"]) {
            //获取心率数据
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveHeartRateDataWithModel:)]) {
                [self.receiveDelegate receiveHeartRateDataWithModel:model];
            }
            
        }else if ([headStr isEqualToString:@"0c"] || [headStr isEqualToString:@"0C"] || [headStr isEqualToString:@"8c"] || [headStr isEqualToString:@"8C"]) {
            //获取睡眠
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisSleepData:value WithHeadStr: headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveSleepInfoWithModel:)]) {
                [self.receiveDelegate receiveSleepInfoWithModel:model];
            }else {
//                [_fmTool saveSleepToDataBase:model];
            }
        }else if ([headStr isEqualToString:@"0d"] || [headStr isEqualToString:@"0D"] || [headStr isEqualToString:@"8d"] || [headStr isEqualToString:@"8D"]) {
            //上报GPS数据
//            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisGPSData:value WithHeadStr: headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveGPSWithModel:)]) {
//                [self.receiveDelegate receiveGPSWithModel:model];
//                [_fmTool saveGPSToDataBase:model];
            }else {
//                [_fmTool saveGPSToDataBase:model];
            }
        }
    }
}

#pragma mark - 通知

#pragma mark - 懒加载
- (NSMutableArray *)deviceArr
{
    if (!_deviceArr) {
        _deviceArr = [NSMutableArray array];
    }
    
    return _deviceArr;
}


@end
