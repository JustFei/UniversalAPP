//
//  TextConstants.h
//  New_iwear
//
//  Created by JustFei on 2017/5/19.
//  Copyright © 2017年 manridy. All rights reserved.
//

#ifndef TextConstants_h
#define TextConstants_h

#pragma mark - 数据库名字
#define DB_NAME @"UserList"

#pragma mark - 通知中心的名字
//设置时间
#define SET_TIME @"SetTime"
//设置闹钟
#define SET_CLOCK @"SetClock"
//计步信息
#define GET_MOTION_DATA @"GetMotionData"
//计步清零
#define SET_MOTION_ZERO @"SetMotionZero"
//gps 数据
#define GET_GPS_DATA @"GetGPSData"
//用户信息
#define SET_USER_INFO @"SetUserInfo"
//运动目标
#define SET_MOTION_TARGET @"SetMotionTarget"
//查看是否配对
#define GET_PAIR @"GetPair"
//心率开关
#define SET_HR_STATE @"SetHRState"
//心率数据
#define GET_HR_DATA @"GetHRData"
//睡眠数据
#define GET_SLEEP_DATA @"GetSleepData"
//设置固件
#define SET_FIRMWARE @"SetFirmware"
//设备确认查找到时反馈
#define GET_SEARCH_FEEDBACK @"GetSearchFeedBack"
//设备查找手机(此处需要全局监听)
#define SET_FIND_PHONE @"SetFindPhone"
//设备防丢开关
#define LOST_PERIPHERAL_SWITCH @"LostPeripheralSwitch"
//血压
#define GET_BP_DATA @"GetBPData"
//血氧
#define GET_BO_DATA @"GetBOData"
//拍照
#define SET_TAKE_PHOTO @"SetTakePhoto"
//分段计步
#define GET_SEGEMENT_STEP @"GetSegementStep"
//分段跑步
#define GET_SEGEMENT_RUN @"GetSegementRun"
//久坐提醒
#define GET_SEDENTARY_DATA @"GetSedentaryData"
//单位设置
#define SET_UNITS_DATA @"SetUnitsData"
//时间格式设置
#define SET_TIME_FORMATTER @"SetTimeFormatter"
//窗口设置
#define SET_WINDOW @"SetWindow"
//翻腕亮屏通知
#define WRIST_SETTING_NOTI @"WristSettingNoti"


#pragma mark - NSUserDefault 保存的信息的名字
//长度单位
#define LONG_MEASURE @"LongMeasure"             //yes：英制，no：公制
//重量单位
#define HUNDRED_WEIGHT @"HundredWeight"         //yes：英制，no：公制
//时间制式
#define TIME_FORMATTER @"TimeFormatter"         //yes：12时，no：24时
////运动目标
//#define MOTION_TARGET @"MotionTarget"
////睡眠目标
//#define SLEEP_TARGET @"SleepTarget"
//硬件版本号
#define HARDWARE_VERSION @"HardwareVersion"  
//窗口设置保存
#define WINDOW_SETTING @"WindowSetting"
//久坐设置保存
#define SEDENTARY_SETTING @"SedentarySetting"
//闹钟设置保存
#define CLOCK_SETTING @"ClockSetting"
//闹钟是否开启保存
#define CLOCK_ISOPEN @"ClockIsOpen"
//短信提醒开关保存
#define MESSAGE_SWITCH_SETTING @"MessageSwitchSetting"
//电话提醒开关保存
#define PHONE_SWITCH_SETTING @"PhoneSwitchSetting"
//app 设置保存
#define APP_REMIND_SETTING @"AppRemindSetting"
//防丢设置保存
#define LOST_SETTING @"LostSetting"
//翻腕亮屏设置保存
#define WRIST_SETTING @"WristSetting"
//亮度设置保存
#define DIMMING_SETTING @"DimmingSetting"
//单位设置保存
#define UNITS_SETTING @"UnitsSetting"
//时间格式设置保存
#define TIME_FORMATTER_SETTING @"TimeFormatterSetting"
//目标设置保存
#define TARGET_SETTING @"TargetSetting"
//用户名保存
#define USER_NAME_SETTING @"UserNameSetting"
//用户头像保存
#define USER_HEADIMAGE_SETTING @"UserHeadimageSetting"
//用户其他信息保存
#define USER_INFO_SETTING @"UserInfoSetting"
//电量信息保存
#define ELECTRICITY_INFO_SETTING @"ElectricityInfoSetting"

#pragma mark - 同步完成通知更新 UI
#define UPDATE_ALL_UI @"UpdateAllUI"

#endif /* TextConstants_h */
