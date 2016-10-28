//
//  SectionModel.h
//  ManridyApp
//
//  Created by JustFei on 16/10/28.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionModel : NSObject

@property (nonatomic ,copy) NSString *functionName;

@property (nonatomic ,copy) NSString *imageName;

@property (nonatomic ,copy) NSString *arrowImageName;
// 是否是展开的
@property (nonatomic, assign) BOOL isExpanded;

@end
