//
//  UnitsTool.h
//  ManridyApp
//
//  Created by Faith on 2017/3/31.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MetricToImperial,
    ImperialToMetric
} Mode;

@interface UnitsTool : NSObject

/** 厘米转英寸 */
+ (NSInteger)cmAndInch:(NSInteger)param withMode:(Mode)mode;
/** 千克转磅 */
+ (NSInteger)kgAndLb:(NSInteger)param withMode:(Mode)mode;
/** 千米转英里 */
+ (NSInteger)kmAndMi:(NSInteger)param withMode:(Mode)mode;

@end
