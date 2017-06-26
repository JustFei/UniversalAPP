//
//  Log.h
//  OnePiece
//
//  Created by JustFei on 2016/11/25.
//  Copyright © 2016年 manridy. All rights reserved.
//

#ifndef Log_h
#define Log_h

//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#endif /* Log_h */
