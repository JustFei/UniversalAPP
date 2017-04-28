//
//  manridyBleDevice.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "manridyBleDevice.h"

@implementation manridyBleDevice

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData andRSSI:(NSNumber *)RSSI
{
    manridyBleDevice *per = [[manridyBleDevice alloc] init];
    NSString *advName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    //DLog(@"perName == %@    advName == %@",cbPeripheral.name ,advName);
    per.peripheral = cbPeripheral;
    per.deviceName = advName;
    CBUUID *serverUUID = ((NSArray *)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"]).firstObject;
    per.uuidString = serverUUID.UUIDString;
    per.RSSI = RSSI;
    
    return per;
}

@end
