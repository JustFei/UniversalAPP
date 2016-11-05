//
//  AnalysisProcotolTool.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class manridyModel;

@interface AnalysisProcotolTool : NSObject
{
    
}

@property (nonatomic ,assign) float staticLon;

@property (nonatomic ,assign) float staticLat;

+ (instancetype)shareInstance;

//解析设置时间数据（00|80）
- (manridyModel *)analysisSetTimeData:(NSData *)data WithHeadStr:(NSString *)head;

//解析闹钟数据 (01|81)
- (manridyModel *)analysisClockData:(NSData *)data WithHeadStr:(NSString *)head;

//解析获取运动信息的数据（03|83）
- (manridyModel *)analysisGetSportData:(NSData *)data WithHeadStr:(NSString *)head;

//解析获取运动信息清零的数据（04|84）
- (manridyModel *)analysisSportZeroData:(NSData *)data WithHeadStr:(NSString *)head;

//解析获取GPS历史的数据（05|85）
//- (manridyModel *)analysisHistoryGPSData:(NSData *)data WithHeadStr:(NSString *)head;

//解析用户信息的数据（06|86）
- (manridyModel *)analysisUserInfoData:(NSData *)data WithHeadStr:(NSString *)head;

//解析运动目标的数据（07|87）
- (manridyModel *)analysisSportTargetData:(NSData *)data WithHeadStr:(NSString *)head;

//解析心率开关的数据（09|89）
- (manridyModel *)analysisHeartStateData:(NSData *)data WithHeadStr:(NSString *)head;

//解析心率的数据（0A|8A）
- (manridyModel *)analysisHeartData:(NSData *)data WithHeadStr:(NSString *)head;

//解析睡眠的数据（0C|8C）
- (manridyModel *)analysisSleepData:(NSData *)data WithHeadStr:(NSString *)head;

//解析GPS的数据（0D|8D）
//- (manridyModel *)analysisGPSData:(NSData *)data WithHeadStr:(NSString *)head;

@end
