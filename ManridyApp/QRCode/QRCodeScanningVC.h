//
//  QRCodeScanningVC.h
//  SGQRCodeExample
//
//  Created by apple on 17/3/21.
//  Copyright © 2017年 JP_lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGQRCodeConst.h"
#import "SGQRCodeScanningVC.h"

typedef void(^ScanQRCodeResult)(NSString *);

@interface QRCodeScanningVC : SGQRCodeScanningVC

@property (nonatomic ,copy) ScanQRCodeResult scanResult;

@end
