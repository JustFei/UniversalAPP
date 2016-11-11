//
//  BLETool.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "manridyModel.h"

@class manridyModel;

typedef enum : NSUInteger {
    HeartRateTestStateStop = 0,
    HeartRateTestStateStart,
} HeartRateTestState;

typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected,
//    kBLEstateBindUnConnected,
}kBLEstate;

typedef enum{
    SystemBLEStateUnknown = 0,
    SystemBLEStateResetting,
    SystemBLEStateUnsupported,
    SystemBLEStateUnauthorized,
    SystemBLEStatePoweredOff,
    SystemBLEStatePoweredOn,
} SystemBLEState;

@class manridyBleDevice;

//扫描设备协议
@protocol BleDiscoverDelegate <NSObject>

@optional
- (void)manridyBLEDidDiscoverDeviceWithMAC:(manridyBleDevice *)device;

@end

//连接协议
@protocol BleConnectDelegate <NSObject>

@optional
/**
 *  invoked when the device did connected by the centeral
 *
 *  @param device: the device did connected
 */
- (void)manridyBLEDidConnectDevice:(manridyBleDevice *)device;

/**
 *  invoked when the device did fail connected
 *
 *  @param connect fail
 */
- (void)manridyBLEDidFailConnectDevice:(manridyBleDevice *)device;

/**
 *  invoked when the device did disconnected
 *
 *  @param device the device did disconnected
 */
- (void)manridyBLEDidDisconnectDevice:(manridyBleDevice *)device;

@end

//写入协议
@protocol BleReceiveDelegate <NSObject>

@optional

/**
 *  同一返回数据的接口，所有数据均通过这个接口回调
 *
 */
- (void)receiveDataWithModel:(manridyModel *)manridyModel;

//不同数据类型的回调
//set time
- (void)receiveSetTimeDataWithModel:(manridyModel *)manridyModel;

//set clock
- (void)receiveSetClockDataWithModel:(manridyModel *)manridyModel;

//motion data
- (void)receiveMotionDataWithModel:(manridyModel *)manridyModel;

//motion zero
- (void)receiveSetMotionZeroWithModel:(manridyModel *)manridyModel;

//GPS data
- (void)receiveGPSWithModel:(manridyModel *)manridyModel;

//user info
- (void)receiveUserInfoWithModel:(manridyModel *)manridyModel;

//set motion target
- (void)receiveMotionTargetWithModel:(manridyModel *)manridyModel;

//set heart rate test state
- (void)receiveHeartRateTestWithModel:(manridyModel *)manridyModel;

//get heart rate data
- (void)receiveHeartRateDataWithModel:(manridyModel *)manridyModel;

//get sleepInfo
- (void)receiveSleepInfoWithModel:(manridyModel *)manridyModel;

//get search feedback
- (void)receiveSearchFeedback;

@end

@protocol BleReceiveSearchResquset <NSObject>

@optional
- (void)receivePeripheralRequestToRemindPhoneWithState:(BOOL)OnorOFF;

@end

@interface BLETool : NSObject

+ (instancetype)shareInstance;

//当前连接的设备
@property (nonatomic ,strong) manridyBleDevice *currentDev;

@property (nonatomic ,assign) kBLEstate connectState; //support add observer ,abandon @readonly ,don't change it anyway.

@property (nonatomic ,weak) id <BleDiscoverDelegate>discoverDelegate;

@property (nonatomic ,weak) id <BleConnectDelegate>connectDelegate;

@property (nonatomic ,weak) id <BleReceiveDelegate>receiveDelegate;

@property (nonatomic ,weak) id <BleReceiveSearchResquset>searchDelegate;

@property (nonatomic ,assign) BOOL isReconnect;

@property(nonatomic, assign,) SystemBLEState systemBLEstate;

#pragma mark - action of connecting layer -连接层操作
//扫描设备
- (void)scanDevice;

//停止扫描
- (void)stopScan;

//连接设备
- (void)connectDevice:(manridyBleDevice *)device;

//断开设备连接
- (void)unConnectDevice;

//重连设备
//- (void)reConnectDevice:(BOOL)isConnect;

//检索已连接的外接设备
- (NSArray *)retrieveConnectedPeripherals;

#pragma mark - get sdk version -获取SDK版本号
- (NSString *)getManridyBleSDKVersion;

#pragma mark - data of write -数据层操作
//set time
- (void)writeTimeToPeripheral:(NSDate *)currentDate;

//set clock
- (void)writeClockToPeripheral:(ClockData)state withClockArr:(NSMutableArray *)clockArr;

//get motionInfo
- (void)writeMotionRequestToPeripheralWithMotionType:(MotionType)type;

//set motionInfo zero
- (void)writeMotionZeroToPeripheral;

//get GPS data
- (void)writeGPSToPeripheral;

//set userInfo
- (void)writeUserInfoToPeripheralWeight:(NSString *)weight andHeight:(NSString *)height;

//set motion target
- (void)writeMotionTargetToPeripheral:(NSString *)target;

//set heart rate test state
- (void)writeHeartRateTestStateToPeripheral:(HeartRateTestState)state;

//get heart rate data
- (void)writeHeartRateRequestToPeripheral:(HeartRateData)heartRateData;

//get sleepInfo
- (void)writeSleepRequestToperipheral:(SleepData)sleepData;

//photo and message remind
- (void)writePhoneAndMessageRemindToPeripheral:(Remind *)remindModel;

//search my peripheral
- (void)writeSearchPeripheralWithONorOFF:(BOOL)state;

//stop peripheral
- (void)writeStopPeripheralRemind;

//临时写入保持连接
- (void)writeToKeepConnect;
@end
