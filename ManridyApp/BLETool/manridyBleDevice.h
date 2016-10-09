//
//  manridyBleDevice.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

@class CBPeripheral;
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface manridyBleDevice : NSObject

//设备
@property (nonatomic ,strong) CBPeripheral *peripheral;
//RSSI
@property (nonatomic ,strong) NSNumber *RSSI;
//UUID
@property (nonatomic ,strong) NSString *uuidString;
//设备名
@property (nonatomic ,strong) NSString *deviceName;

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData andRSSI:(NSNumber *)RSSI;

@end
