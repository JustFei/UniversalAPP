//
//  BLETool.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "BLETool.h"
#import "manridyBleDevice.h"
#import "manridyModel.h"
#import "NSStringTool.h"
#import "AnalysisProcotolTool.h"
#import "AllBleFmdb.h"
#import "AppDelegate.h"
#import "ClockModel.h"
#import <UserNotifications/UserNotifications.h>

#define kServiceUUID              @"F000EFE0-0451-4000-0000-00000000B000"
#define kWriteCharacteristicUUID  @"F000EFE1-0451-4000-0000-00000000B000"
#define kNotifyCharacteristicUUID @"F000EFE3-0451-4000-0000-00000000B000"

#define kCurrentVersion @"1.0"


@interface BLETool () <UNUserNotificationCenterDelegate>

@property (nonatomic ,strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic ,strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic ,strong) NSMutableArray *deviceArr;
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
- (BOOL)retrievePeripherals
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"]) {
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"peripheralUUID"];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidStr];
        NSArray *arr = [_myCentralManager retrievePeripheralsWithIdentifiers: @[uuid]];
        DLog(@"当前已连接的设备%@,有几个%ld",arr ,arr.count);
        if (arr.count != 0) {
            CBPeripheral *per = (CBPeripheral *)arr.firstObject;
            per.delegate = self;
            manridyBleDevice *device = [[manridyBleDevice alloc] initWith:per andAdvertisementData:nil andRSSI:nil];
            
            [self connectDevice:device];
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

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
    self.isReconnect = YES;
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
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSString *currentStr = [NSString stringWithFormat:@"%02ld%02ld%02ld%02ld%02ld%02ld%02ld",[comps year] % 100 ,[comps month] ,[comps day] ,[comps hour] ,[comps minute] ,[comps second] ,[comps weekday] - 1];
//    NSLog(@"-----------weekday is %ld",(long)[comps weekday]);//在这里需要注意的是：星期日是数字1，星期一时数字2，以此类推。。。
    
    //传入时间和头，返回协议字符串
    NSString *protocolStr = [NSStringTool protocolAddInfo:currentStr head:@"00"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        DLog(@"time success");
    }
}

//set clock
- (void)writeClockToPeripheral:(ClockData)state withClockArr:(NSMutableArray *)clockArr
{
    if (state == ClockDataSetClock) {
        DLog(@"设置闹钟");
        
        NSString *clockStateStr = [[NSString alloc] init];
        NSString *clockDataStr = [[NSString alloc] init];
        
        for (int index = 0; index < 5; index ++) {
            
            if (index < clockArr.count) {
                ClockModel *clockModel = clockArr[index];
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
        
        DLog(@"闹钟的协议 == %@",clockStateStr);
        
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSString stringWithFormat:@"FC0100%@0000",clockStateStr];
        
        //写入操作
        if (self.currentDev.peripheral && self.writeCharacteristic) {
            [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        
        
    }else {
        //传入时间和头，返回协议字符串
        NSString *protocolStr = [NSStringTool protocolAddInfo:@"01" head:@"01"];
        
        //写入操作
        if (self.currentDev.peripheral && self.writeCharacteristic) {
            [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            DLog(@"clock success");
        }
    }
}

//get motionInfo
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:[NSString stringWithFormat:@"%ld",(unsigned long)type] head:@"03"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type: CBCharacteristicWriteWithResponse];
        DLog(@"motion success");
    }
}

//set motionInfo zero
- (void)writeMotionZeroToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"04"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}
//get GPS data
- (void)writeGPSToPeripheral
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:nil head:@"05"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        DLog(@"gps success");
    }
}

//set userInfo
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height
{
    NSString *userInfoStr = [weight stringByAppendingString:[NSString stringWithFormat:@",%@",height]];
    
    userInfoStr = [NSStringTool protocolAddInfo:userInfoStr head:@"06"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:userInfoStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//set motion target
- (void)writeMotionTargetToPeripheral:(NSString *)target
{
    NSString *targetStr = [NSStringTool protocolAddInfo:target head:@"07"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
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
            
            if (self.currentDev.peripheral && self.writeCharacteristic) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:stopStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            }
        }
            break;
        case HeartRateTestStateStart:
            //start heart rate test
        {
            NSString *startStr = [NSStringTool protocolAddInfo:@"01" head:@"09"];
            
            if (self.currentDev.peripheral && self.writeCharacteristic) {
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
            
            if (self.currentDev.peripheral && self.writeCharacteristic) {
                [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:lastStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
                DLog(@"heartRate success");
            }
        }
            break;
        case HeartRateDataHistoryData:
            //history data of heart rate
        {
            NSString *historyStr = [NSStringTool protocolAddInfo:@"01" head:@"0A"];
            
            if (self.currentDev.peripheral && self.writeCharacteristic) {
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
            DLog(@"sleep success");
            
            break;
        case SleepDataHistoryData:
            //history data of sleep
            sleepStr = [NSStringTool protocolAddInfo:@"01" head:@"0C"];
            
            break;
            
        default:
            break;
    }
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:sleepStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//photo and message remind
- (void)writePhoneAndMessageRemindToPeripheral:(Remind *)remindModel
{
    NSString *remindStr;
    remindStr = [NSStringTool protocolForRemind:remindModel];
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:remindStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
        DLog(@"电话短信提醒协议 == %@",remindStr);
    }
}

//search my peripheral
- (void)writeSearchPeripheralWithONorOFF:(BOOL)state
{
    NSString *searchStr;
    if (state) {
        //开始查找
        searchStr = @"FC100003";
    }else {
        searchStr = @"FC100000";
    }
    
    while (1) {
        if (searchStr.length < 40) {
            searchStr = [searchStr stringByAppendingString:@"00"];
        }else {
            break;
        }
    }
    DLog(@"search == %@",searchStr);
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:searchStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//设备断开后震动提醒
- (void)writePeripheralShakeWhenUnconnectWithOforOff:(BOOL)state
{
    NSString *searchStr;
    if (state) {
        //设备开启丢失模式
        searchStr = @"FC100201";
    }else {
        //设备关闭丢失模式
        searchStr = @"FC100200";
    }
    
    while (1) {
        if (searchStr.length < 40) {
            searchStr = [searchStr stringByAppendingString:@"00"];
        }else {
            break;
        }
    }
    DLog(@"防丢协议 == %@",searchStr);
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:searchStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//stop peripheral
- (void)writeStopPeripheralRemind
{
    NSString *stopStr = @"1001";
    
    while (1) {
        if (stopStr.length < 40) {
            stopStr = [stopStr stringByAppendingString:@"00"];
        }else {
            break;
        }
    }
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:stopStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//get blood data
- (void)writeBloodToPeripheral:(BloodData)bloodData
{
    NSString *bloodStr;
    switch (bloodData) {
        case BloodDataLastData:
            //last data of sleep
            bloodStr = [NSStringTool protocolAddInfo:@"00" head:@"11"];
            DLog(@"sleep success");
            
            break;
        case BloodDataHistoryData:
            //history data of sleep
            bloodStr = [NSStringTool protocolAddInfo:@"01" head:@"11"];
            
            break;
            
        default:
            break;
    }
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:bloodStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//get blood O2 data
- (void)writeBloodO2ToPeripheral:(BloodO2Data)bloodO2Data
{
    NSString *bloodStr;
    switch (bloodO2Data) {
        case BloodO2DataLastData:
            //last data of sleep
            bloodStr = [NSStringTool protocolAddInfo:@"00" head:@"12"];
            DLog(@"sleep success");
            
            break;
        case BloodO2DataHistoryData:
            //history data of sleep
            bloodStr = [NSStringTool protocolAddInfo:@"01" head:@"12"];
            
            break;
            
        default:
            break;
    }
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:bloodStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/** get version from peripheral */
- (void)writeRequestVersion
{
    NSString *protocolStr = [NSStringTool protocolAddInfo:@"" head:@"0f"];
    
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//set sedentary alert
- (void)writeSedentaryAlertWithSedentaryModel:(SedentaryModel *)sedentaryModel
{
    NSString *ss;
    NSString *T2T1 = @"0000";
    NSString *SHSM = @"0000";   //免打扰时段开始时间
    NSString *EHEM = @"0000";   //免打扰时段结束时间
    NSString *IHIM = @"0000";   //设定开始提醒时间
    NSString *IhIm = @"0000";   //设定提醒结束时间
    
    if (!sedentaryModel.sedentaryAlert) {
        if (!sedentaryModel.unDisturb) {
            ss = @"00";     //久坐和勿扰都没开启
        }else {
            ss = @"02";     //久坐关闭，勿扰开启
        }
    }else {
#warning change T2T1 time
        //001e
        T2T1 = @"001e" ;    //30分钟提醒间隔
        //T2T1 = @"003c" ;    //60分钟提醒间隔
        IHIM = [sedentaryModel.sedentaryStartTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        IhIm = [sedentaryModel.sedentaryEndTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        SHSM = [sedentaryModel.disturbStartTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        EHEM = [sedentaryModel.disturbEndTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        if (!sedentaryModel.unDisturb) {
            ss = @"01";     //久坐开启，勿扰关闭 SS BIT[0]=1
        }else {
            ss = @"03";     //久坐和勿扰都开启  SS BIT[0]=1 ;SS BIT[1]=1
        }
    }
    NSString *stepInterval = [NSStringTool ToHex:sedentaryModel.stepInterval];
    if (stepInterval.length < 4) {
        while (1) {
            stepInterval = [@"0" stringByAppendingString:stepInterval];
            if (stepInterval.length >= 4) {
                break;
            }
        }
    }
    NSString *info = [[[[[[ss stringByAppendingString:T2T1] stringByAppendingString:SHSM] stringByAppendingString:EHEM] stringByAppendingString:IHIM] stringByAppendingString:IhIm] stringByAppendingString:stepInterval];
    
    
    NSString *protocolStr = [NSStringTool protocolAddInfo:info head:@"16"];
    DLog(@"久坐协议 = %@",protocolStr);
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//写入名称
- (void)writePeripheralNameWithNameString:(NSString *)name
{
    
    NSString *lengthInterval = [NSStringTool ToHex:name.length / 2];
    if (lengthInterval.length < 2) {
        while (1) {
            lengthInterval = [@"0" stringByAppendingString:lengthInterval];
            if (lengthInterval.length >= 2) {
                break;
            }
        }
    }
    NSString *protocolStr = [[@"FC0F07" stringByAppendingString:lengthInterval]stringByAppendingString:name];
    
    while (1) {
        if (protocolStr.length < 40) {
            protocolStr = [protocolStr stringByAppendingString:@"00"];
        }else {
            break;
        }
    }
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:protocolStr] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

//临时写入保持连接
- (void)writeToKeepConnect
{
    //写入操作
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:@"fc0f00"] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/*推送公制和英制单位
 ImperialSystem  YES = 英制
 NO  = 公制
 */
- (void)writeUnitToPeripheral:(BOOL)ImperialSystem
{
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:ImperialSystem ? @"FC170001" : @"FC170000"] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark -拍照
/** 打开设备的拍照模式 */
- (void)writeOpenCameraMode
{
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:@"FC1981"] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/** 完成拍照 */
- (void)writePhotoFinish
{
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:@"FC190080"] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/** 关闭设备的拍照模式 */
- (void)writeCloseCameraMode
{
    if (self.currentDev.peripheral && self.writeCharacteristic) {
        [self.currentDev.peripheral writeValue:[NSStringTool hexToBytes:@"FC1980"] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBCentralManagerDelegate
//检查设备蓝牙开关的状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *message = nil;
    switch (central.state) {
        case 0:
            self.systemBLEstate = 0;
            break;
        case 1:
//            message = @"该设备不支持蓝牙功能，请检查系统设置";
            self.systemBLEstate = 1;
            break;
        case 2:
        {
            self.systemBLEstate = 2;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 3:
        {
            self.systemBLEstate = 3;
            message = @"该设备蓝牙未授权，请检查系统设置";
        }
            break;
        case 4:
        {
            message = NSLocalizedString(@"phoneNotOpenBLE", nil);
            self.systemBLEstate = 4;
            DLog(@"message == %@",message);
            AlertTool *aTool = [AlertTool alertWithTitle:NSLocalizedString(@"tips", nil) message:message style:UIAlertControllerStyleAlert];
            [aTool addAction:[AlertAction actionWithTitle:NSLocalizedString(@"IKnow", nil) style:AlertToolStyleDefault handler:nil]];
            [aTool show];
        }
            break;
        case 5:
        {
            self.systemBLEstate = 5;
            message = NSLocalizedString(@"bleHaveOpen", nil);
        }
            break;

        default:
            break;
    }
    
    //[_myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

//查找到正在广播的指定外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    manridyBleDevice *device = [[manridyBleDevice alloc] initWith:peripheral andAdvertisementData:advertisementData andRSSI:RSSI];
    //当你发现你感兴趣的连接外围设备，停止扫描其他设备，以节省电能。
    if (device.deviceName != nil ) {
        if (![self.deviceArr containsObject:peripheral]) {
            [self.deviceArr addObject:peripheral];
            
            //返回扫描到的设备实例
            if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                
                [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
            }
        }
    }else {
        if ([device.uuidString isEqualToString:kServiceUUID]) {
            device.deviceName = @"X9Plus";
            if (![self.deviceArr containsObject:peripheral]) {
                DLog(@"+1");
                [self.deviceArr addObject:peripheral];
                
                //返回扫描到的设备实例
                if ([self.discoverDelegate respondsToSelector:@selector(manridyBLEDidDiscoverDeviceWithMAC:)]) {
                    
                    [self.discoverDelegate manridyBLEDidDiscoverDeviceWithMAC:device];
                }
            }
        }
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
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
//    DLog(@"连接失败");
    
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
        DLog(@"需要断线重连");
        [self.myCentralManager connectPeripheral:self.currentDev.peripheral options:nil];
        
        self.disConnectView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"bleReConnect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"IKnow", nil) otherButtonTitles:nil, nil];
        self.disConnectView.tag = 103;
        [self.disConnectView show];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"]) {
            BOOL isFindMyPeripheral = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFindMyPeripheral"];
            
            /**TODO:这里的延迟操作会因为在后台的原因停止执行，目前测试在8秒钟左右可以实现稳定延迟。*/
            if (isFindMyPeripheral) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self delayMethod];
                });
                
            }
        }
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.mainVc.haveNewStep = YES;
        delegate.mainVc.haveNewHeartRate = YES;
        delegate.mainVc.haveNewSleep = YES;
        delegate.mainVc.haveNewBP = YES;
        delegate.mainVc.haveNewBO = YES;
        [delegate.mainVc hiddenFunctionView];
        
    }else {
        self.currentDev = nil;
    }

}

- (void)delayMethod
{
    if (self.connectState == kBLEstateDisConnected) {
        // 1、创建通知内容，注：这里得用可变类型的UNMutableNotificationContent，否则内容的属性是只读的
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = NSLocalizedString(@"perDismissNodify", nil);
        // 次标题
        //content.subtitle = NSLocalizedString(@"PerDismissNodifySubtitle", nil);
        // 内容
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        NSString *dateStr = [formatter stringFromDate:date];
        content.body = [NSString stringWithFormat:NSLocalizedString(@"PerDismissNodifyContent", nil),dateStr];
        // 通知的提示声音，这里用的默认的声音
        content.sound = [UNNotificationSound soundNamed:@"alert.wav"];
        
        // 标识符
        content.categoryIdentifier = @"categoryIndentifier";
        
        // 2、创建通知触发
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        // 3、创建通知请求
        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"KFGroupNotification" content:content trigger:trigger];
        
        // 4、将请求加入通知中心
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                DLog(@"已成功加推送%@",notificationRequest.identifier);
            }
        }];
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
    
//    DLog(@"Discovered characteristic %@", service.characteristics);
    DLog(@"服务 %@,", service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics) {
        DLog(@"特征值： %@",characteristic.UUID);
        
        //保存写入特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) {
            
            self.writeCharacteristic = characteristic;
        }
        
        //保存订阅特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kNotifyCharacteristicUUID]]) {
            self.notifyCharacteristic = characteristic;
            self.connectState = kBLEstateDidConnected;
            if ([self.connectDelegate respondsToSelector:@selector(manridyBLEDidConnectDevice:)]) {
                if (self.currentDev.peripheral == peripheral) {
                    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:@"peripheralUUID"];
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
        DLog(@"Error changing notification state: %@",[error localizedDescription]);
    }else {
        DLog(@"Success cahnging notification state: %d;value = %@",characteristic.isNotifying ,characteristic.value);
    }
}

//订阅特征值发送变化的通知，所有获取到的值都将在这里进行处理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DLog(@"updateValue == %@",characteristic.value);
    
    [self analysisDataWithCharacteristic:characteristic.value];
    
}

//写入某特征值后的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
//        DLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }else {
//        DLog(@"Success writing chararcteristic value: %@",characteristic);
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
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisClockData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveSetClockDataWithModel:)]) {
                [self.receiveDelegate receiveSetClockDataWithModel:model];
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
            
        }else if ([headStr isEqualToString:@"08"] || [headStr isEqualToString:@"88"]) {
            manridyModel *model = [[AnalysisProcotolTool shareInstance]analysisPairData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receivePairWitheModel:)]) {
                [self.receiveDelegate receivePairWitheModel:model];
            }
            
        }else if ([headStr isEqualToString:@"09"] || [headStr isEqualToString:@"89"]) {
            //心率开关
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisHeartStateData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveHeartRateTestWithModel:)]) {
                [self.receiveDelegate receiveHeartRateTestWithModel:model];
            }
            
        }else if([headStr isEqualToString:@"0a"] || [headStr isEqualToString:@"0A"] || [headStr isEqualToString:@"8a"] || [headStr isEqualToString:@"8A"]) {
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
        }else if ([headStr isEqualToString:@"0f"] || [headStr isEqualToString:@"0F"]) {
            //判断是版本号还是电量
            NSString *typeStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
            if ([typeStr isEqualToString:@"06"]) {//电量
                NSString *batteryStr = [NSString stringWithFormat:@"%x", hexBytes[8]];
                DLog(@"电量：%@",batteryStr);
            }else if ([typeStr isEqualToString:@"05"]) {//版本号
                int maint = hexBytes[7];
                int miint = hexBytes[8];
                int reint = hexBytes[9];
                
                NSString *versionStr = [[[NSString stringWithFormat:@"%d", maint] stringByAppendingString:[NSString stringWithFormat:@".%d",miint]] stringByAppendingString:[NSString stringWithFormat:@".%d",reint]];
                if ([self.receiveDelegate respondsToSelector:@selector(receiveVersionWithVersionStr:)]) {
                    [self.receiveDelegate receiveVersionWithVersionStr:versionStr];
                }
            }else if ([typeStr isEqualToString:@"07"]) {//改名称
                if ([self.receiveDelegate respondsToSelector:@selector(receiveChangePerNameSuccess:)]) {
                    [self.receiveDelegate receiveChangePerNameSuccess:YES];
                }
            }
        }else if ([headStr isEqualToString:@"fc"] || [headStr isEqualToString:@"FC"]) {
            NSString *secondStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
            NSString *TTStr = [NSString stringWithFormat:@"%02x", hexBytes[3]];
            if ([secondStr isEqualToString:@"10"]) {
                if ([self.searchDelegate respondsToSelector:@selector(receivePeripheralRequestToRemindPhoneWithState:)]) {
                    if ([TTStr isEqualToString:@"00"]) {
                        [self.searchDelegate receivePeripheralRequestToRemindPhoneWithState:NO];
                    }else {
                        [self.searchDelegate receivePeripheralRequestToRemindPhoneWithState:YES];
                    }
                    
                }
            }
        }else if ([headStr isEqualToString:@"10"]) {
            if ([self.receiveDelegate respondsToSelector:@selector(receiveSearchFeedback)]) {
                [self.receiveDelegate receiveSearchFeedback];
            }
        }else if ([headStr isEqualToString:@"11"]) {
            //获取血压
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodData:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveBloodDataWithModel:)]) {
                [self.receiveDelegate receiveBloodDataWithModel:model];
            }
        }else if ([headStr isEqualToString:@"12"]) {
            //获取血氧
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisBloodO2Data:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveBloodO2DataWithModel:)]) {
                [self.receiveDelegate receiveBloodO2DataWithModel:model];
            }
        }else if ([headStr isEqualToString:@"19"]) {
            //开始拍照
            manridyModel *model = [[AnalysisProcotolTool shareInstance] analysisTakePhoto:value WithHeadStr:headStr];
            if ([self.receiveDelegate respondsToSelector:@selector(receiveTakePhoto:)]) {
                [self.receiveDelegate receiveTakePhoto:model];
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
