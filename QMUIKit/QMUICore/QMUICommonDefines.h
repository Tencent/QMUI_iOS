//
//  QMUICommonDefines.h
//  qmui
//
//  Created by QMUI Team on 14-6-23.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "QMUIHelper.h"

#pragma mark - 变量-编译相关

// 判断当前是否debug编译模式
#ifdef DEBUG
#define IS_DEBUG YES
#else
#define IS_DEBUG NO
#endif


/// 判断当前编译使用的 Base SDK 版本是否为 iOS 8.0 及以上

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#define IOS8_SDK_ALLOWED YES
#endif


/// 判断当前编译使用的 Base SDK 版本是否为 iOS 9.0 及以上

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#define IOS9_SDK_ALLOWED YES
#endif


/// 判断当前编译使用的 Base SDK 版本是否为 iOS 10.0 及以上

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#define IOS10_SDK_ALLOWED YES
#endif


/// 判断当前编译使用的 Base SDK 版本是否为 iOS 11.0 及以上

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
#define IOS11_SDK_ALLOWED YES
#endif

#pragma mark - Clang

#define ArgumentToString(macro) #macro
#define ClangWarningConcat(warning_name) ArgumentToString(clang diagnostic ignored warning_name)

// 参数可直接传入 clang 的 warning 名，warning 列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(ClangWarningConcat(#warningName))
#define EndIgnoreClangWarning _Pragma("clang diagnostic pop")

#define BeginIgnorePerformSelectorLeaksWarning BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define EndIgnorePerformSelectorLeaksWarning EndIgnoreClangWarning

#define BeginIgnoreAvailabilityWarning BeginIgnoreClangWarning(-Wpartial-availability)
#define EndIgnoreAvailabilityWarning EndIgnoreClangWarning

#define BeginIgnoreDeprecatedWarning BeginIgnoreClangWarning(-Wdeprecated-declarations)
#define EndIgnoreDeprecatedWarning EndIgnoreClangWarning


#pragma mark - 变量-设备相关

// 设备类型
#define IS_IPAD [QMUIHelper isIPad]
#define IS_IPAD_PRO [QMUIHelper isIPadPro]
#define IS_IPOD [QMUIHelper isIPod]
#define IS_IPHONE [QMUIHelper isIPhone]
#define IS_SIMULATOR [QMUIHelper isSimulator]

// 操作系统版本号，只获取第二级的版本号，例如 10.3.1 只会得到 10.3
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] doubleValue])

// 数字形式的操作系统版本号，可直接用于大小比较；如 110205 代表 11.2.5 版本；根据 iOS 规范，版本号最多可能有3位
#define IOS_VERSION_NUMBER [QMUIHelper numbericOSVersion]

// 是否横竖屏
// 用户界面横屏了才会返回YES
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
// 无论支不支持横屏，只要设备横屏了，就会返回YES
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])

// 屏幕宽度，会根据横竖屏的变化而变化
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

// 屏幕宽度，跟横竖屏无关
#define DEVICE_WIDTH (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

// 屏幕高度，会根据横竖屏的变化而变化
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

// 屏幕高度，跟横竖屏无关
#define DEVICE_HEIGHT (IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

// 设备屏幕尺寸
// iPhoneX
#define IS_58INCH_SCREEN [QMUIHelper is58InchScreen]
// iPhone6/7/8 Plus
#define IS_55INCH_SCREEN [QMUIHelper is55InchScreen]
// iPhone6/7/8
#define IS_47INCH_SCREEN [QMUIHelper is47InchScreen]
// iPhone5/5s/SE
#define IS_40INCH_SCREEN [QMUIHelper is40InchScreen]
// iPhone4/4s
#define IS_35INCH_SCREEN [QMUIHelper is35InchScreen]
// iPhone4/4s/5/5s/SE
#define IS_320WIDTH_SCREEN (IS_35INCH_SCREEN || IS_40INCH_SCREEN)

// 是否Retina
#define IS_RETINASCREEN ([[UIScreen mainScreen] scale] >= 2.0)

// 是否放大模式（iPhone 6及以上的设备支持放大模式）
#define IS_ZOOMEDMODE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)] ? (ScreenNativeScale > ScreenScale) : NO)

#pragma mark - 变量-布局相关

// bounds && nativeBounds / scale && nativeScale
#define ScreenBoundsSize ([[UIScreen mainScreen] bounds].size)
#define ScreenNativeBoundsSize ([[UIScreen mainScreen] nativeBounds].size)
#define ScreenScale ([[UIScreen mainScreen] scale])
#define ScreenNativeScale ([[UIScreen mainScreen] nativeScale])

// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算)
#define StatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)

// navigationBar相关frame
#define NavigationBarHeight (IS_LANDSCAPE ? PreferredVarForDevices(44, 32, 32, 32) : 44)

// toolBar相关frame
#define ToolBarHeight (IS_LANDSCAPE ? PreferredVarForUniversalDevicesIncludingIPhoneX(44, 44, 53, 32, 32, 32) : PreferredVarForUniversalDevicesIncludingIPhoneX(44, 44, 83, 44, 44, 44))

// tabBar相关frame
#define TabBarHeight (IS_LANDSCAPE ? PreferredVarForUniversalDevicesIncludingIPhoneX(49, 49, 53, 32, 32, 32) : PreferredVarForUniversalDevicesIncludingIPhoneX(49, 49, 83, 49, 49, 49))

// 保护 iPhoneX 安全区域的 insets
#define IPhoneXSafeAreaInsets [QMUIHelper safeAreaInsetsForIPhoneX]

// 获取顶部导航栏占位高度，从而在布局 subviews 时可以当成 minY 参考
// 注意，以下两个宏已废弃，请尽量使用 UIViewController (QMUI) qmui_navigationBarMaxYInViewCoordinator 代替
#define NavigationContentTop (StatusBarHeight + NavigationBarHeight)
#define NavigationContentStaticTop NavigationContentTop

// 获取一个像素
#define PixelOne [QMUIHelper pixelOne]

// 获取最合适的适配值，默认以varFor55Inch为准，也即偏向大屏，特殊的，iPhone X 虽然英寸值更大，但由于宽度与 47inch 相等，因此布局上使用与 47inch 一样的值
#define PreferredVarForDevices(varFor55Inch, varFor47or58Inch, varFor40Inch, varFor35Inch) PreferredVarForUniversalDevices(varFor55Inch, varFor55Inch, varFor47or58Inch, varFor40Inch, varFor35Inch)

// 同上，加多一个iPad的参数
#define PreferredVarForUniversalDevices(varForPad, varFor55Inch, varFor47or58Inch, varFor40Inch, varFor35Inch) PreferredVarForUniversalDevicesIncludingIPhoneX(varForPad, varFor55Inch, varFor47or58Inch, varFor47or58Inch, varFor40Inch, varFor35Inch)

// 同上，包含 iPhoneX
#define PreferredVarForUniversalDevicesIncludingIPhoneX(varForPad, varFor55Inch, varFor58Inch, varFor47Inch, varFor40Inch, varFor35Inch) (IS_IPAD ? varForPad : (IS_35INCH_SCREEN ? varFor35Inch : (IS_40INCH_SCREEN ? varFor40Inch : (IS_47INCH_SCREEN ? varFor47Inch : (IS_55INCH_SCREEN ? varFor55Inch : varFor58Inch)))))

#pragma mark - 方法-创建器

#define CGSizeMax CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)

// 使用文件名(不带后缀名)创建一个UIImage对象，会被系统缓存，适用于大量复用的小资源图
// 使用这个 API 而不是 imageNamed: 是因为后者在 iOS 8 下反而存在性能问题（by molice 不确定 iOS 9 及以后的版本是否还有这个问题）
#define UIImageMake(img) [UIImage imageNamed:img inBundle:nil compatibleWithTraitCollection:nil]

// 使用文件名(不带后缀名，仅限png)创建一个UIImage对象，不会被系统缓存，用于不被复用的图片，特别是大图
#define UIImageMakeWithFile(name) UIImageMakeWithFileAndSuffix(name, @"png")
#define UIImageMakeWithFileAndSuffix(name, suffix) [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", [[NSBundle mainBundle] resourcePath], name, suffix]]

// 字体相关的宏，用于快速创建一个字体对象，更多创建宏可查看 UIFont+QMUI.h
#define UIFontMake(size) [UIFont systemFontOfSize:size]
#define UIFontItalicMake(size) [UIFont italicSystemFontOfSize:size] // 斜体只对数字和字母有效，中文无效
#define UIFontBoldMake(size) [UIFont boldSystemFontOfSize:size]
#define UIFontBoldWithFont(_font) [UIFont boldSystemFontOfSize:_font.pointSize]

// UIColor 相关的宏，用于快速创建一个 UIColor 对象，更多创建的宏可查看 UIColor+QMUI.h
#define UIColorMake(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define UIColorMakeWithRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]


#pragma mark - 数学计算

#define AngleWithDegrees(deg) (M_PI * (deg) / 180.0)


#pragma mark - 动画

#define QMUIViewAnimationOptionsCurveOut (7<<16)
#define QMUIViewAnimationOptionsCurveIn (8<<16)


#pragma mark - 其他

#define StringFromBOOL(_flag) (_flag ? @"YES" : @"NO")

#pragma mark - 方法-C对象、结构操作

/**
 *  如果 fromClass 里存在 originSelector，则这个函数会将 fromClass 里的 originSelector 与 toClass 里的 newSelector 交换实现。
 *  如果 fromClass 里不存在 originSelecotr，则这个函数会为 fromClass 增加方法 originSelector，并且该方法会使用 toClass 的 newSelector 方法的实现，而 toClass 的 newSelector 方法的实现则会被替换为空内容
 *  @warning 注意如果 fromClass 里的 originSelector 是继承自父类并且 fromClass 也没有重写这个方法，这会导致实际上被替换的是父类，然后父类及父类的所有子类（也即 fromClass 的兄弟类）也受影响，因此使用时请谨记这一点。
 *  @param _fromClass 要被替换的 class，不能为空
 *  @param _originSelector 要被替换的 class 的 selector，可为空，为空则相当于为 fromClass 新增这个方法
 *  @param _toClass 要拿这个 class 的方法来替换
 *  @param _newSelector 要拿 toClass 里的这个方法来替换 originSelector
 *  @return 是否成功替换（或增加）
 */
CG_INLINE BOOL
ExchangeImplementationsInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector) {
    if (!_fromClass || !_toClass) {
        return NO;
    }
    
    Method oriMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    if (!newMethod) {
        return NO;
    }
    
    Class superclass = class_getSuperclass(_fromClass);
    BOOL tryToExchangeSuperclassMethod = [superclass instancesRespondToSelector:_originSelector] && (class_getInstanceMethod(superclass, _originSelector) == class_getInstanceMethod(_fromClass, _originSelector));
    if (tryToExchangeSuperclassMethod) {
        NSLog(@"注意，%@ 准备替换方法 %@, 但这个方法来自于父类 %@", NSStringFromClass(_fromClass), NSStringFromSelector(_originSelector), NSStringFromClass(superclass));
    }
    
    BOOL isAddedMethod = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}

/// 交换同一个 class 里的 originSelector 和 newSelector 的实现，如果原本不存在 originSelector，则相当于给 class 新增一个叫做 originSelector 的方法
CG_INLINE BOOL
ExchangeImplementations(Class _class, SEL _originSelector, SEL _newSelector) {
    return ExchangeImplementationsInTwoClasses(_class, _originSelector, _class, _newSelector);
}

/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
CG_INLINE BOOL
OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(Class originClass, SEL originCMD, IMP originIMP)) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    if (!originMethod) {
        return NO;
    }
    IMP originIMP = method_getImplementation(originMethod);
    method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originIMP)));
    return YES;
}

/**
 *  用 block 重写某个 class 的某个无参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须无参数，返回值为 void
 *  @param implementationBlock targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针。
 */
CG_INLINE BOOL
ExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void (^implementationBlock)(__kindof NSObject *selfObject)) {
    return OverrideImplementation(targetClass, targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {
        return ^(__kindof NSObject *selfObject) {
            
            void (*originSelectorIMP)(id, SEL);
            originSelectorIMP = (void (*)(id, SEL))originIMP;
            originSelectorIMP(selfObject, originCMD);
            
            if (![selfObject isKindOfClass:originClass]) return;
            
            implementationBlock(selfObject);
        };
    });
}

/**
 *  用 block 重写某个 class 的某个无参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param _returnType 返回值的数据类型
 *  @param _implementationBlock 格式为 ^_returnType(NSObject *selfObject, _returnType originReturnValue) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define ExtendImplementationOfNonVoidMethodWithoutArguments(_targetClass, _targetSelector, _returnType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
            return ^_returnType (__kindof NSObject *selfObject) {\
                \
                _returnType (*originSelectorIMP)(id, SEL);\
                originSelectorIMP = (_returnType (*)(id, SEL))originIMP;\
                _returnType result = originSelectorIMP(selfObject, originCMD);\
                \
                if ([selfObject isKindOfClass:originClass]) {\
                    return _implementationBlock(selfObject, result);\
                }\
                \
                return result;\
            };\
        });

/**
 *  用 block 重写某个 class 的带一个参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值为 void
 *  @param _argumentType targetSelector 的参数类型
 *  @param _implementationBlock 格式为 ^(NSObject *selfObject, _argumentType firstArgv) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写
 */
#define ExtendImplementationOfVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
        return ^(__kindof NSObject *selfObject, _argumentType firstArgv) {\
            \
            void (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (void (*)(id, SEL, _argumentType))originIMP;\
            originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            if (![selfObject isKindOfClass:originClass]) return;\
            \
            _implementationBlock(selfObject, firstArgv);\
        };\
    });

/**
 *  用 block 重写某个 class 的带一个参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param implementationBlock，格式为 ^_returnType (NSObject *selfObject, _argumentType firstArgv, _returnType originReturnValue){}，内容也即 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写；第三个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define ExtendImplementationOfNonVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _returnType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
        return ^_returnType (__kindof NSObject *selfObject, _argumentType firstArgv) {\
            \
            _returnType (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (_returnType (*)(id, SEL, _argumentType))originIMP;\
            _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            if ([selfObject isKindOfClass:originClass]) {\
                return _implementationBlock(selfObject, firstArgv, result);\
            }\
            \
            return result;\
        };\
    });

#pragma mark - CGFloat

/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 *  issue: https://github.com/QMUI/QMUI_iOS/issues/203
 */
CG_INLINE CGFloat
removeFloatMin(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}

/**
 *  基于指定的倍数，对传进来的 floatValue 进行像素取整。若指定倍数为0，则表示以当前设备的屏幕倍数为准。
 *
 *  例如传进来 “2.1”，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
 */
CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = removeFloatMin(floatValue);
    scale = scale == 0 ? ScreenScale : scale;
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

/**
 *  类似flat()，只不过 flat 是向上取整，而 floorInPixel 是向下取整
 */
CG_INLINE CGFloat
floorInPixel(CGFloat floatValue) {
    floatValue = removeFloatMin(floatValue);
    CGFloat resultValue = floor(floatValue * ScreenScale) / ScreenScale;
    return resultValue;
}

CG_INLINE BOOL
between(CGFloat minimumValue, CGFloat value, CGFloat maximumValue) {
    return minimumValue < value && value < maximumValue;
}

CG_INLINE BOOL
betweenOrEqual(CGFloat minimumValue, CGFloat value, CGFloat maximumValue) {
    return minimumValue <= value && value <= maximumValue;
}

/**
 *  调整给定的某个 CGFloat 值的小数点精度，超过精度的部分按四舍五入处理。
 *
 *  例如 CGFloatToFixed(0.3333, 2) 会返回 0.33，而 CGFloatToFixed(0.6666, 2) 会返回 0.67
 *
 *  @warning 参数类型为 CGFloat，也即意味着不管传进来的是 float 还是 double 最终都会被强制转换成 CGFloat 再做计算
 *  @warning 该方法无法解决浮点数精度运算的问题
 */
CG_INLINE CGFloat
CGFloatToFixed(CGFloat value, NSUInteger precision) {
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(precision)];
    NSString *toString = [NSString stringWithFormat:formatString, value];
    #if CGFLOAT_IS_DOUBLE
    CGFloat result = [toString doubleValue];
    #else
    CGFloat result = [toString floatValue];
    #endif
    return result;
}

/// 用于居中运算
CG_INLINE CGFloat
CGFloatGetCenter(CGFloat parent, CGFloat child) {
    return flat((parent - child) / 2.0);
}

#pragma mark - CGPoint

/// 两个point相加
CG_INLINE CGPoint
CGPointUnion(CGPoint point1, CGPoint point2) {
    return CGPointMake(flat(point1.x + point2.x), flat(point1.y + point2.y));
}

/// 获取rect的center，包括rect本身的x/y偏移
CG_INLINE CGPoint
CGPointGetCenterWithRect(CGRect rect) {
    return CGPointMake(flat(CGRectGetMidX(rect)), flat(CGRectGetMidY(rect)));
}

CG_INLINE CGPoint
CGPointGetCenterWithSize(CGSize size) {
    return CGPointMake(flat(size.width / 2.0), flat(size.height / 2.0));
}

CG_INLINE CGPoint
CGPointToFixed(CGPoint point, NSUInteger precision) {
    CGPoint result = CGPointMake(CGFloatToFixed(point.x, precision), CGFloatToFixed(point.y, precision));
    return result;
}

CG_INLINE CGPoint
CGPointRemoveFloatMin(CGPoint point) {
    CGPoint result = CGPointMake(removeFloatMin(point.x), removeFloatMin(point.y));
    return result;
}

#pragma mark - UIEdgeInsets

/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

/// 将两个UIEdgeInsets合并为一个
CG_INLINE UIEdgeInsets
UIEdgeInsetsConcat(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    insets1.top += insets2.top;
    insets1.left += insets2.left;
    insets1.bottom += insets2.bottom;
    insets1.right += insets2.right;
    return insets1;
}

CG_INLINE UIEdgeInsets
UIEdgeInsetsSetTop(UIEdgeInsets insets, CGFloat top) {
    insets.top = flat(top);
    return insets;
}

CG_INLINE UIEdgeInsets
UIEdgeInsetsSetLeft(UIEdgeInsets insets, CGFloat left) {
    insets.left = flat(left);
    return insets;
}
CG_INLINE UIEdgeInsets
UIEdgeInsetsSetBottom(UIEdgeInsets insets, CGFloat bottom) {
    insets.bottom = flat(bottom);
    return insets;
}

CG_INLINE UIEdgeInsets
UIEdgeInsetsSetRight(UIEdgeInsets insets, CGFloat right) {
    insets.right = flat(right);
    return insets;
}

CG_INLINE UIEdgeInsets
UIEdgeInsetsToFixed(UIEdgeInsets insets, NSUInteger precision) {
    UIEdgeInsets result = UIEdgeInsetsMake(CGFloatToFixed(insets.top, precision), CGFloatToFixed(insets.left, precision), CGFloatToFixed(insets.bottom, precision), CGFloatToFixed(insets.right, precision));
    return result;
}

CG_INLINE UIEdgeInsets
UIEdgeInsetsRemoveFloatMin(UIEdgeInsets insets) {
    UIEdgeInsets result = UIEdgeInsetsMake(removeFloatMin(insets.top), removeFloatMin(insets.left), removeFloatMin(insets.bottom), removeFloatMin(insets.right));
    return result;
}

#pragma mark - CGSize

/// 判断一个size是否为空（宽或高为0）
CG_INLINE BOOL
CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

/// 将一个CGSize像素对齐
CG_INLINE CGSize
CGSizeFlatted(CGSize size) {
    return CGSizeMake(flat(size.width), flat(size.height));
}

/// 将一个 CGSize 以 pt 为单位向上取整
CG_INLINE CGSize
CGSizeCeil(CGSize size) {
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

/// 将一个 CGSize 以 pt 为单位向下取整
CG_INLINE CGSize
CGSizeFloor(CGSize size) {
    return CGSizeMake(floor(size.width), floor(size.height));
}

CG_INLINE CGSize
CGSizeToFixed(CGSize size, NSUInteger precision) {
    CGSize result = CGSizeMake(CGFloatToFixed(size.width, precision), CGFloatToFixed(size.height, precision));
    return result;
}

CG_INLINE CGSize
CGSizeRemoveFloatMin(CGSize size) {
    CGSize result = CGSizeMake(removeFloatMin(size.width), removeFloatMin(size.height));
    return result;
}

#pragma mark - CGRect

/// 判断一个 CGRect 是否存在NaN
CG_INLINE BOOL
CGRectIsNaN(CGRect rect) {
    return isnan(rect.origin.x) || isnan(rect.origin.y) || isnan(rect.size.width) || isnan(rect.size.height);
}

/// 系统提供的 CGRectIsInfinite 接口只能判断 CGRectInfinite 的情况，而该接口可以用于判断 INFINITY 的值
CG_INLINE BOOL
CGRectIsInf(CGRect rect) {
    return isinf(rect.origin.x) || isinf(rect.origin.y) || isinf(rect.size.width) || isinf(rect.size.height);
}

/// 判断一个 CGRect 是否合法（例如不带无穷大的值、不带非法数字）
CG_INLINE BOOL
CGRectIsValidated(CGRect rect) {
    return !CGRectIsNull(rect) && !CGRectIsInfinite(rect) && !CGRectIsNaN(rect) && !CGRectIsInf(rect);
}

/// 创建一个像素对齐的CGRect
CG_INLINE CGRect
CGRectFlatMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return CGRectMake(flat(x), flat(y), flat(width), flat(height));
}

/// 对CGRect的x/y、width/height都调用一次flat，以保证像素对齐
CG_INLINE CGRect
CGRectFlatted(CGRect rect) {
    return CGRectMake(flat(rect.origin.x), flat(rect.origin.y), flat(rect.size.width), flat(rect.size.height));
}

/// 为一个CGRect叠加scale计算
CG_INLINE CGRect
CGRectApplyScale(CGRect rect, CGFloat scale) {
    return CGRectFlatted(CGRectMake(CGRectGetMinX(rect) * scale, CGRectGetMinY(rect) * scale, CGRectGetWidth(rect) * scale, CGRectGetHeight(rect) * scale));
}

/// 计算view的水平居中，传入父view和子view的frame，返回子view在水平居中时的x值
CG_INLINE CGFloat
CGRectGetMinXHorizontallyCenterInParentRect(CGRect parentRect, CGRect childRect) {
    return flat((CGRectGetWidth(parentRect) - CGRectGetWidth(childRect)) / 2.0);
}

/// 计算view的垂直居中，传入父view和子view的frame，返回子view在垂直居中时的y值
CG_INLINE CGFloat
CGRectGetMinYVerticallyCenterInParentRect(CGRect parentRect, CGRect childRect) {
    return flat((CGRectGetHeight(parentRect) - CGRectGetHeight(childRect)) / 2.0);
}

/// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持垂直居中时，layoutingRect的originY
CG_INLINE CGFloat
CGRectGetMinYVerticallyCenter(CGRect referenceRect, CGRect layoutingRect) {
    return CGRectGetMinY(referenceRect) + CGRectGetMinYVerticallyCenterInParentRect(referenceRect, layoutingRect);
}

/// 返回值：同一个坐标系内，想要layoutingRect和已布局完成的referenceRect保持水平居中时，layoutingRect的originX
CG_INLINE CGFloat
CGRectGetMinXHorizontallyCenter(CGRect referenceRect, CGRect layoutingRect) {
    return CGRectGetMinX(referenceRect) + CGRectGetMinXHorizontallyCenterInParentRect(referenceRect, layoutingRect);
}

/// 为给定的rect往内部缩小insets的大小
CG_INLINE CGRect
CGRectInsetEdges(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= UIEdgeInsetsGetHorizontalValue(insets);
    rect.size.height -= UIEdgeInsetsGetVerticalValue(insets);
    return rect;
}

/// 传入size，返回一个x/y为0的CGRect
CG_INLINE CGRect
CGRectMakeWithSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

CG_INLINE CGRect
CGRectFloatTop(CGRect rect, CGFloat top) {
    rect.origin.y = top;
    return rect;
}

CG_INLINE CGRect
CGRectFloatBottom(CGRect rect, CGFloat bottom) {
    rect.origin.y = bottom - CGRectGetHeight(rect);
    return rect;
}

CG_INLINE CGRect
CGRectFloatRight(CGRect rect, CGFloat right) {
    rect.origin.x = right - CGRectGetWidth(rect);
    return rect;
}

CG_INLINE CGRect
CGRectFloatLeft(CGRect rect, CGFloat left) {
    rect.origin.x = left;
    return rect;
}

/// 保持rect的左边缘不变，改变其宽度，使右边缘靠在right上
CG_INLINE CGRect
CGRectLimitRight(CGRect rect, CGFloat rightLimit) {
    rect.size.width = rightLimit - rect.origin.x;
    return rect;
}

/// 保持rect右边缘不变，改变其宽度和origin.x，使其左边缘靠在left上。只适合那种右边缘不动的view
/// 先改变origin.x，让其靠在offset上
/// 再改变size.width，减少同样的宽度，以抵消改变origin.x带来的view移动，从而保证view的右边缘是不动的
CG_INLINE CGRect
CGRectLimitLeft(CGRect rect, CGFloat leftLimit) {
    CGFloat subOffset = leftLimit - rect.origin.x;
    rect.origin.x = leftLimit;
    rect.size.width = rect.size.width - subOffset;
    return rect;
}

/// 限制rect的宽度，超过最大宽度则截断，否则保持rect的宽度不变
CG_INLINE CGRect
CGRectLimitMaxWidth(CGRect rect, CGFloat maxWidth) {
    CGFloat width = CGRectGetWidth(rect);
    rect.size.width = width > maxWidth ? maxWidth : width;
    return rect;
}

CG_INLINE CGRect
CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = flat(x);
    return rect;
}

CG_INLINE CGRect
CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = flat(y);
    return rect;
}

CG_INLINE CGRect
CGRectSetXY(CGRect rect, CGFloat x, CGFloat y) {
    rect.origin.x = flat(x);
    rect.origin.y = flat(y);
    return rect;
}

CG_INLINE CGRect
CGRectSetWidth(CGRect rect, CGFloat width) {
    rect.size.width = flat(width);
    return rect;
}

CG_INLINE CGRect
CGRectSetHeight(CGRect rect, CGFloat height) {
    rect.size.height = flat(height);
    return rect;
}

CG_INLINE CGRect
CGRectSetSize(CGRect rect, CGSize size) {
    rect.size = CGSizeFlatted(size);
    return rect;
}

CG_INLINE CGRect
CGRectToFixed(CGRect rect, NSUInteger precision) {
    CGRect result = CGRectMake(CGFloatToFixed(CGRectGetMinX(rect), precision),
                               CGFloatToFixed(CGRectGetMinY(rect), precision),
                               CGFloatToFixed(CGRectGetWidth(rect), precision),
                               CGFloatToFixed(CGRectGetHeight(rect), precision));
    return result;
}

CG_INLINE CGRect
CGRectRemoveFloatMin(CGRect rect) {
    CGRect result = CGRectMake(removeFloatMin(CGRectGetMinX(rect)),
                               removeFloatMin(CGRectGetMinY(rect)),
                               removeFloatMin(CGRectGetWidth(rect)),
                               removeFloatMin(CGRectGetHeight(rect)));
    return result;
}

/// outerRange 是否包含了 innerRange
CG_INLINE BOOL
NSContainingRanges(NSRange outerRange, NSRange innerRange) {
    if (innerRange.location >= outerRange.location && outerRange.location + outerRange.length >= innerRange.location + innerRange.length) {
        return YES;
    }
    return NO;
}
