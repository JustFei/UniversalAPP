//
//  SetTimeModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetTimeModel : NSObject

//时间数据，设置时间返回时间格式为：YYMMDDhhmmssWe;(其中YY为年份后两位，We为星期：周日到周一 依次为 0->6)
@property (nonatomic ,strong) NSString *time;

@end
