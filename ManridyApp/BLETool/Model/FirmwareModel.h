//
//  FirmwareModel.h
//  New_iwear
//
//  Created by JustFei on 2017/5/19.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 FirmwareModeResetPer               :        设备复位
 FirmwareModeReinitializeBMA250     :        重新初始化 BMA250
 FirmwareModeReinitializeTP         :        重新初始化TP
 FirmwareModeSetLCD                 :        LCD亮度控制
 FirmwareModeGetVersion             :        获取固件版本号
 FirmwareModeGetElectricity         :        获取设备剩余电量百分比。
 FirmwareModeSetPerName             :        修改蓝牙名称，
 FirmwareModeResetPerName           :        恢复出厂名称。
 FirmwareModeSetLogSitch            :        打开(VL=1)/关闭(VL=0)Debug信息输出功能。
 FirmwareModeGetLog                 :        打开(VL=1)/关闭(VL=0)/提取(VL=2)日志记录功能。
 */
typedef enum : NSUInteger {
    FirmwareModeResetPer = 0,
    FirmwareModeReinitializeBMA250,
    FirmwareModeReinitializeTP,
    FirmwareModeSetLCD,
    FirmwareModeGetVersion,
    FirmwareModeGetElectricity,
    FirmwareModeSetPerName,
    FirmwareModeResetPerName,
    FirmwareModeSetDebugSitch,
    FirmwareModeGetLog
} FirmwareMode;

@interface FirmwareModel : NSObject

@property (nonatomic, assign) FirmwareMode mode;

@property (nonatomic, assign) BOOL isResetPerSuccess;
@property (nonatomic, assign) BOOL isReinitializeBMA250Success;
@property (nonatomic, assign) BOOL isReinitializeTPSuccess;
@property (nonatomic, assign) float LCDvalue;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign) NSString *PerElectricity;
@property (nonatomic, strong) NSString *setPerName;
@property (nonatomic, assign) BOOL isResetPerNameSuccess;
@property (nonatomic, assign) BOOL isOpenDebugSuccess;
@property (nonatomic, assign) BOOL isOpenLogSuccess;

@end
