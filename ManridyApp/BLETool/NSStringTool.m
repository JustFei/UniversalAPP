//
//  NSStringTool.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "NSStringTool.h"

@implementation NSStringTool

#pragma mark - 数据格式转换操作
//int转换16进制
+ (NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}

//NSString转换为NSdata，这样就省去了一个一个字节去写入
+ (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    
    //    NSLog(@"data = %@",data);
    return data;
}

//补充内容，因为没有三个字节转int的方法，这里补充一个通用方法,16进制转换成10进制
+ (unsigned)parseIntFromData:(NSData *)data
{
    
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    return intData;
}

//协议加工厂
+ (NSString *)protocolAddInfo:(NSString *)info head:(NSString *)head
{
    if ([head isEqualToString:@"00"]) {
        //---------------设置时间----------------------
        
        NSString *weStr = [info substringFromIndex:12];
        NSString *timeStr = [info substringToIndex:12];
        
        if ([weStr isEqualToString:@"Sun"] || [weStr isEqualToString:@"周日"]) {
            timeStr = [timeStr stringByAppendingString:@"00"];
        }else if ([weStr isEqualToString:@"Mon"] || [weStr isEqualToString:@"周一"]) {
            timeStr = [timeStr stringByAppendingString:@"01"];
        }else if ([weStr isEqualToString:@"Tues"] || [weStr isEqualToString:@"周二"]) {
            timeStr = [timeStr stringByAppendingString:@"02"];
        }else if ([weStr isEqualToString:@"Wed"] || [weStr isEqualToString:@"周三"]) {
            timeStr = [timeStr stringByAppendingString:@"03"];
        }else if ([weStr isEqualToString:@"Thur"] || [weStr isEqualToString:@"周四"]) {
            timeStr = [timeStr stringByAppendingString:@"04"];
        }else if ([weStr isEqualToString:@"Fri"] || [weStr isEqualToString:@"周五"]) {
            timeStr = [timeStr stringByAppendingString:@"05"];
        }else if ([weStr isEqualToString:@"Sat"] || [weStr isEqualToString:@"周六"]) {
            timeStr = [timeStr stringByAppendingString:@"06"];
        }
        
        timeStr = [NSString stringWithFormat:@"FC00%@",timeStr];
        
        while (1) {
            if (timeStr.length < 40) {
                timeStr = [timeStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        NSString *protocolStr = timeStr;
        return protocolStr;
    }else if ([head isEqualToString:@"01"]) {
        //--------------获取闹钟信息----------------
        
        NSString *protocolStr = [NSString stringWithFormat:@"FC%@%@",head,info];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }

        return protocolStr;
        
    }else if ([head isEqualToString:@"03"]) {
        //----------------获取运动信息---------------
        NSString *motionStr;
        switch (info.integerValue) {
            case 0:
            {
                //请求获取步数0000 0001
                motionStr = @"FC0301";
            }
                break;
            case 1:
            {
                //请求获取步数和卡路里
                motionStr = @"FC0307";
            }
                break;
            case 2:
            {
                //查询设备数据条数
                motionStr = @"FC0380";
            }
                break;
            case 3:
            {
                //获取保存的距离数据内容
                motionStr = @"FC03C0";
            }
                
            default:
                break;
        }
        
        while (1) {
            if (motionStr.length < 40) {
                motionStr = [motionStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        NSString *protocolStr = motionStr;
        return protocolStr;
    }else if ([head isEqualToString:@"04"]) {
        //-----------------运动信息清零-------------
        
        NSString *motionZeroStr = @"FC04";
        
        while (1) {
            if (motionZeroStr.length < 40) {
                motionZeroStr = [motionZeroStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        NSString *protocolStr = motionZeroStr;
        return protocolStr;
    }else if ([head isEqualToString:@"05"]) {
        //-----------------获取GPS数据---------
        NSString *GPSStr = @"FC05";
        
        while (1) {
            if (GPSStr.length < 40) {
                GPSStr = [GPSStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        NSString *protocolStr = GPSStr;
        return protocolStr;
    }else if ([head isEqualToString:@"06"]) {
        //-----------------设置用户信息----------
        
        NSArray *subStrArr = [info componentsSeparatedByString:@","];
        NSString *height = subStrArr.firstObject;
        NSString *weight = subStrArr.lastObject;
        
        height = [self ToHex:height.intValue];
        weight = [self ToHex:weight.intValue];
        
        if (height.length == 0) {
            height = @"00";
        }else if (height.length == 1) {
            height = [NSString stringWithFormat:@"0%@",height];
        }
        
        if (weight.length == 0) {
            weight = @"00";
        }else if (weight.length == 1) {
            weight = [NSString stringWithFormat:@"0%@",weight];
        }
        
        NSString *protocolStr = [NSString stringWithFormat:@"FC06%@%@",height,weight];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        return protocolStr;
        
        
    }else if ([head isEqualToString:@"07"]) {
        //----------------设置目标步数-------------
        
        //转换成16进制
        NSString *targetStr = [self ToHex:info.intValue];
        if (targetStr.length < 6) {
            NSInteger count = 6 - targetStr.length;
            for (int i = 0; i < count; i ++) {
                targetStr = [NSString stringWithFormat:@"0%@",targetStr];
            }
            //            NSLog(@"%@",targetStr);
        }
        
        NSString *protocolStr = [NSString stringWithFormat:@"FC0701%@",targetStr];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        return protocolStr;
    }else if ([head isEqualToString:@"09"]) {
        //---------------设置心率开关----------
        NSString *protocolStr = [NSString stringWithFormat:@"FC09%@",info];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        return protocolStr;
    }else if ([head isEqualToString:@"0A"] || [head isEqualToString:@"0a"]) {
        //--------------获取心率数据-----------
        NSString *protocolStr = [NSString stringWithFormat:@"FC0A%@",info];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        return protocolStr;
    }else if ([head isEqualToString:@"0c"] || [head isEqualToString:@"0C"]) {
        //--------------获取睡眠数据-----------
        
        NSString *protocolStr = [NSString stringWithFormat:@"FC0C%@",info];
        
        while (1) {
            if (protocolStr.length < 40) {
                protocolStr = [protocolStr stringByAppendingString:@"00"];
            }else {
                break;
            }
        }
        
        return protocolStr;
    }
    
    return nil;
}

//将data转换为不带<>的字符串
+ (NSString *)convertToNSStringWithNSData:(NSData *)data
{
    
    
    NSMutableString *strTemp = [NSMutableString stringWithCapacity:[data length]*2];
    
    
    const unsigned char *szBuffer = [data bytes];
    
    
    for (NSInteger i=0; i < [data length]; ++i) {
        
        [strTemp appendFormat:@"%02lx",(unsigned long)szBuffer[i]];
        
    }
    
    
    return strTemp;
    
}

@end
