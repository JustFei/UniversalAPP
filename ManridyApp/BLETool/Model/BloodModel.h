//
//  BloodModel.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BloodDataLastData = 0,
    BloodDataHistoryData,
} BloodData;

@interface BloodModel : NSObject

//判断是最后一次还是历史
@property (nonatomic ,assign) BloodData bloodState;

@property (nonatomic ,copy) NSString *dayString;
@property (nonatomic ,copy) NSString *timeString;
@property (nonatomic ,copy) NSString *highBloodString;
@property (nonatomic ,copy) NSString *lowBloodString;
@property (nonatomic ,copy) NSString *currentCount;
@property (nonatomic ,copy) NSString *sumCount;
@property (nonatomic ,copy) NSString *bpmString;

@end
