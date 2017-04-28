//
//  TakePhotoModel.h
//  ManridyApp
//
//  Created by Faith on 2017/4/27.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CameraModeEnterCameraMode,
    CameraModeExitCameraMode,
    CameraModeTakePhotoAction,
    CameraModePhotoActionFinish
} CameraMode;

@interface TakePhotoModel : NSObject

@property (nonatomic, assign) CameraMode cameraMode;
@property (nonatomic, assign) BOOL enterCameraMode;
@property (nonatomic, assign) BOOL exitCameraMode;
@property (nonatomic, assign) BOOL takePhotoAction;
@property (nonatomic, assign) BOOL photoActionFinish;

@end
