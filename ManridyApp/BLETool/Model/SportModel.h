//
//  SportModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SportModel : NSObject

@property (nonatomic ,copy) NSString *stepNumber;
@property (nonatomic ,copy) NSString *mileageNumber;
@property (nonatomic ,copy) NSString *kCalNumber;
@property (nonatomic ,assign) NSInteger sumDataCount;
@property (nonatomic ,assign) NSInteger currentDataCount;
@property (nonatomic ,copy) NSString *date;
@end
