//
//  SedentaryModel.h
//  ManridyApp
//
//  Created by Faith on 2017/1/18.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SedentaryModel : NSObject

@property (nonatomic ,assign) BOOL sedentaryAlert;
@property (nonatomic ,assign) BOOL unDisturb;
@property (nonatomic ,assign) int timeInterval;
@property (nonatomic ,copy) NSString *disturbStartTime;
@property (nonatomic ,copy) NSString *disturbEndTime;
@property (nonatomic ,copy) NSString *sedentaryStartTime;
@property (nonatomic ,copy) NSString *sedentaryEndTime;
@property (nonatomic ,assign) int stepInterval;

@end
