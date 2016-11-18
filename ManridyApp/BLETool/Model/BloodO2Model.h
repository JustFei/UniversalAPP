//
//  BloodO2Model.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BloodO2DataLastData = 0,
    BloodO2DataHistoryData,
} BloodO2Data;

@interface BloodO2Model : NSObject

//判断是最后一次还是历史
@property (nonatomic ,assign) BloodO2Data bloodO2State;

@property (nonatomic ,copy) NSString *dayString;
@property (nonatomic ,copy) NSString *timeString;
@property (nonatomic ,copy) NSString *integerString;
@property (nonatomic ,copy) NSString *floatString;
@property (nonatomic ,copy) NSString *currentCount;
@property (nonatomic ,copy) NSString *sumCount;

@end
