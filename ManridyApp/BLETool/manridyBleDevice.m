//
//  manridyBleDevice.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/8.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "manridyBleDevice.h"
#import "NSStringTool.h"

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
    NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    if (data.length >= 10) {
        NSString *mac = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(4, 6)]];
        mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableString *mutMac = mac.mutableCopy;
        NSInteger index = mutMac.length;
        while ((index - 2) > 0) {
            index -= 2;
            [mutMac insertString:@":" atIndex:index];
        }
        per.macAddress = mutMac;
    }
    
    return per;
}

@end
