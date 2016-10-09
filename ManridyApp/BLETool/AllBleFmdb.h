//
//  AllBleFmdb.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class manridyModel;

@interface AllBleFmdb : NSObject

- (void)saveMotionToDataBase:(manridyModel *)manridyModel;

- (void)saveSleepToDataBase:(manridyModel *)manridyModel;

//离线保存GPS数据
- (void)saveGPSToDataBase:(manridyModel *)manridyModel;

@end
