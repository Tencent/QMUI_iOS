//
//  QMUIConfigurationTemplate.h
//  ZTest1
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

// 此文件仅供复制使用，不能加到静态库的Compile Sources里面。

/**
 * 1、在QMUI的UICommon里面把这个文件复制到自己的项目下然后按需要修改（通过修改这个模板的单例来修改宏的值）。
 * 2、无需修改的宏，可以保持注释的状态，避免重新赋相同的值。
 * 3、在main函数里面调用setupConfigurationTemplate来使修改生效。
 * 4、@warning 务必请不要修改默认的顺序，只需修改值即可。
 * 5、@warning 更新QMUI的时候，请留意是否这个模板有更新，有则需要把更新的代码负责到项目模板对应的地方，如果没有及时复制，则会使用QMUI给的默认值。
 * 6、@warning 当修改了某个宏，其他引用了这个宏的修改则不能注释，否则会更新不了新的值。比如：a = b ; c = a ; 如果需改了a = d，则c = a就不能注释了。如果觉得这样太麻烦，那么可以把所有的注释都去掉，这样就不用关心这个问题了。
 */

#import <Foundation/Foundation.h>

@interface QMUIConfigurationTemplate : NSObject

+ (void)setupConfigurationTemplate;

@end
