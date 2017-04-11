//
//  UnitsTool.m
//  ManridyApp
//
//  Created by Faith on 2017/3/31.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "UnitsTool.h"

@implementation UnitsTool

/** 厘米转英寸 */
+ (NSInteger)cmAndInch:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 0.3937 : param / 0.3937;
}

/** 千克转磅 */
+ (NSInteger)kgAndLb:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 2.205 : param / 2.205;
}

/** 千米转英里 */
+ (NSInteger)kmAndMi:(NSInteger)param withMode:(Mode)mode
{
    return mode == MetricToImperial ? param * 0.62137 : param / 0.62137;
}

//判断是否是公制单位
+ (BOOL)isMetricOrImperialSystem
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"]) {
        BOOL isMetric = [[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"];
        return isMetric;
    }else {
        return NO;
    }
}

@end
