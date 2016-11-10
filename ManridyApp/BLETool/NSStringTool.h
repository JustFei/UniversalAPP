//
//  NSStringTool.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Remind;

@interface NSStringTool : NSObject

//int转换16进制
+ (NSString *)ToHex:(long long int)tmpid;

//NSString转换为NSdata，这样就省去了一个一个字节去写入
+ (NSData *)hexToBytes:(NSString *)str;

//补充内容，因为没有三个字节转int的方法，这里补充一个通用方法,16进制转换成10进制
+ (unsigned)parseIntFromData:(NSData *)data;

//协议加工厂
+ (NSString *)protocolAddInfo:(NSString *)info head:(NSString *)head;

//专为提醒制作协议
+ (NSString *)protocolForRemind:(Remind *)model;

//将data转换为不带<>的字符串
+ (NSString *)convertToNSStringWithNSData:(NSData *)data;
@end
