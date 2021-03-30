/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIImage+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/16.
//

#import "UIImage+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "QMUIThemeManagerCenter.h"
#import "QMUIThemePrivate.h"
#import "NSMethodSignature+QMUI.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"
#import <objc/message.h>

@interface UIImage (QMUITheme)

@property(nonatomic, assign) BOOL qmui_shouldUseSystemIMP;
+ (nullable UIImage *)qmui_dynamicImageWithOriginalImage:(UIImage *)image tintColor:(UIColor *)tintColor originalActionBlock:(UIImage * (^)(UIImage *aImage, UIColor *aTintColor))originalActionBlock;
@end

@interface QMUIThemeImageCache : NSCache

@end

@implementation QMUIThemeImageCache

- (instancetype)init {
    if (self = [super init]) {
        // NSCache 在 app 进入后台时会删除所有缓存，它的实现方式是在 init 的时候去监听 UIApplicationDidEnterBackgroundNotification ，一旦进入后台则调用 removeAllObjects，通过 removeObserver 可以禁用掉这个策略
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

@end

@interface QMUIAvoidExceptionProxy : NSProxy
@end

@implementation QMUIAvoidExceptionProxy

+ (instancetype)proxy {
    static dispatch_once_t onceToken;
    static QMUIAvoidExceptionProxy *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [super alloc];
    });
    return instance;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSMethodSignature qmui_avoidExceptionSignature];
}

@end

@interface QMUIThemeImage()

@property(nonatomic, strong) QMUIThemeImageCache *cachedRawImages;

@end

@implementation QMUIThemeImage

static IMP qmui_getMsgForwardIMP(NSObject *self, SEL selector) {
    
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method = class_getInstanceMethod(self.class, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            // 以下代码参考 JSPatch 的实现，但在 OpenCV 时会抛异常
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:encoding];
            if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location == NSNotFound) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {
            // 以下代码参考 Aspect 的实现，可以兼容 OpenCV
            @try {
                NSUInteger valueSize = 0;
                NSGetSizeAndAlignment(encoding, &valueSize, NULL);

                if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                    methodReturnsStructValue = NO;
                }
            } @catch (NSException *exception) {}
        }
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

- (void)dealloc {
    _themeProvider = nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (self.qmui_rawImage) {
        // 这里不能加上 [self.qmui_rawImage respondsToSelector:aSelector] 的判断，否则 UIImage 没有机会做消息转发
        return self.qmui_rawImage;
    }
    // 在 dealloc 的时候 UIImage 会调用 _isNamed 是用于判断 image 对象是否由 [UIImage imageNamed:] 创建的，并根据这个结果决定是否缓存 image，但是 QMUIThemeImage 仅仅是一个容器，真正的缓存工作会在 qmui_rawImage 的 dealloc 执行，所以可以忽略这个方法的调用
    NSArray *ignoreSelectorNames = @[@"_isNamed"];
    if (![ignoreSelectorNames containsObject:NSStringFromSelector(aSelector)]) {
        QMUILogWarn(@"UIImage+QMUITheme", @"QMUIThemeImage 试图执行 %@ 方法，但是 qmui_rawImage 为 nil", NSStringFromSelector(aSelector));
    }
    return [QMUIAvoidExceptionProxy proxy];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = [QMUIThemeImage class];
        UIImage *instance =  UIImage.new;
        // QMUIThemeImage 覆盖重写了大部分 UIImage 的方法，在这些方法调用时，会交给 qmui_rawImage 处理
        // 除此之外 UIImage 内部还有很多私有方法，无法全部在 QMUIThemeImage 重写一遍，这些方法将通过消息转发的形式交给 qmui_rawImage 调用。
        [NSObject qmui_enumrateInstanceMethodsOfClass:instance.class includingInherited:NO usingBlock:^(Method  _Nonnull method, SEL  _Nonnull selector) {
            // 如果 QMUIThemeImage 已经实现了该方法，则不需要消息转发
            if (class_getInstanceMethod(selfClass, selector) != method) return;
            const char * typeDescription = (char *)method_getTypeEncoding(method);
            class_addMethod(selfClass, selector, qmui_getMsgForwardIMP(instance, selector), typeDescription);
        }];
    });
}

// 让 QMUIThemeImage 支持 NSCopying 是为了修复 iOS 12 及以下版本，QMUIThemeImage 在搭配 resizable 使用的情况下可能无法跟随主题刷新的 bug，使用的地方在 UIView+QMUITheme qmui_themeDidChangeByManager:identifier:theme 内。
// https://github.com/Tencent/QMUI_iOS/issues/971
- (id)copyWithZone:(NSZone *)zone {
    QMUIThemeImage *image = (QMUIThemeImage *)[UIImage qmui_imageWithThemeManagerName:self.managerName provider:self.themeProvider];
    image.cachedRawImages = self.cachedRawImages;
    return image;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>, rawImage is %@", NSStringFromClass(self.class), self, self.qmui_rawImage.description];
}

- (instancetype)init {
    return ((id (*)(id, SEL))[NSObject instanceMethodForSelector:_cmd])(self, _cmd);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.qmui_rawImage respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == QMUIThemeImage.class) return YES;
    return [self.qmui_rawImage isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == QMUIThemeImage.class) return YES;
    return [self.qmui_rawImage isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.qmui_rawImage conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

- (CGSize)size {
    return self.qmui_rawImage.size;
}

- (CGImageRef)CGImage {
    return self.qmui_rawImage.CGImage;
}

- (CIImage *)CIImage {
    return self.qmui_rawImage.CIImage;
}

- (UIImageOrientation)imageOrientation {
    return self.qmui_rawImage.imageOrientation;
}

- (CGFloat)scale {
    return self.qmui_rawImage.scale;
}

- (NSArray<UIImage *> *)images {
    return self.qmui_rawImage.images;
}

- (NSTimeInterval)duration {
    return self.qmui_rawImage.duration;
}

- (UIEdgeInsets)alignmentRectInsets {
    return self.qmui_rawImage.alignmentRectInsets;
}

- (void)drawAtPoint:(CGPoint)point {
    [self.qmui_rawImage drawAtPoint:point];
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.qmui_rawImage drawAtPoint:point blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect {
    [self.qmui_rawImage drawInRect:rect];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.qmui_rawImage drawInRect:rect blendMode:blendMode alpha:alpha];
}

- (void)drawAsPatternInRect:(CGRect)rect {
    [self.qmui_rawImage drawAsPatternInRect:rect];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self.qmui_rawImage resizableImageWithCapInsets:capInsets];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    return [self.qmui_rawImage resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
}

- (UIEdgeInsets)capInsets {
    return [self.qmui_rawImage capInsets];
}

- (UIImageResizingMode)resizingMode {
    return [self.qmui_rawImage resizingMode];
}

- (UIImage *)imageWithAlignmentRectInsets:(UIEdgeInsets)alignmentInsets {
    return [self.qmui_rawImage imageWithAlignmentRectInsets:alignmentInsets];
}

- (UIImage *)imageWithRenderingMode:(UIImageRenderingMode)renderingMode {
    return [self.qmui_rawImage imageWithRenderingMode:renderingMode];
}

- (UIImageRenderingMode)renderingMode {
    return self.qmui_rawImage.renderingMode;
}

- (UIGraphicsImageRendererFormat *)imageRendererFormat {
    return self.qmui_rawImage.imageRendererFormat;
}

- (UITraitCollection *)traitCollection {
    return self.qmui_rawImage.traitCollection;
}

- (UIImageAsset *)imageAsset {
    return self.qmui_rawImage.imageAsset;
}

- (UIImage *)imageFlippedForRightToLeftLayoutDirection {
    return self.qmui_rawImage.imageFlippedForRightToLeftLayoutDirection;
}

- (BOOL)flipsForRightToLeftLayoutDirection {
    return self.qmui_rawImage.flipsForRightToLeftLayoutDirection;
}

- (UIImage *)imageWithHorizontallyFlippedOrientation {
    return self.qmui_rawImage.imageWithHorizontallyFlippedOrientation;
}

- (BOOL)isSymbolImage {
    return self.qmui_rawImage.isSymbolImage;
}

- (CGFloat)baselineOffsetFromBottom {
    return self.qmui_rawImage.baselineOffsetFromBottom;
}

- (BOOL)hasBaseline {
    return self.qmui_rawImage.hasBaseline;
}

- (UIImage *)imageWithBaselineOffsetFromBottom:(CGFloat)baselineOffset {
    return [self.qmui_rawImage imageWithBaselineOffsetFromBottom:baselineOffset];
}

- (UIImage *)imageWithoutBaseline {
    return self.qmui_rawImage.imageWithoutBaseline;
}

- (UIImageConfiguration *)configuration {
    return self.qmui_rawImage.configuration;
}

- (UIImage *)imageWithConfiguration:(UIImageConfiguration *)configuration {
    return [self.qmui_rawImage imageWithConfiguration:configuration];
}

- (UIImageSymbolConfiguration *)symbolConfiguration {
    return self.qmui_rawImage.symbolConfiguration;
}

- (UIImage *)imageByApplyingSymbolConfiguration:(UIImageSymbolConfiguration *)configuration {
    return [self.qmui_rawImage imageByApplyingSymbolConfiguration:configuration];
}

#pragma mark - <QMUIDynamicImageProtocol>

- (UIImage *)qmui_rawImage {
    if (!_themeProvider) return nil;
    QMUIThemeManager *manager = [QMUIThemeManagerCenter themeManagerWithName:self.managerName];
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",manager.name, manager.currentThemeIdentifier];
    UIImage *rawImage = [self.cachedRawImages objectForKey:cacheKey];
    if (!rawImage) {
        rawImage = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).qmui_rawImage;
        if (rawImage) [self.cachedRawImages setObject:rawImage forKey:cacheKey];
    }
    return rawImage;
}

- (BOOL)qmui_isDynamicImage {
    return YES;
}

#pragma mark - Translator

// 由于 QMUIThemeImage 的实现里，如果某些方法 QMUIThemeImage 本身没实现，那么就会以消息转发的方式转发给 rawImage，这就导致我们无法直接用 method swizzle 的方式去重写 UIImage.class 的 imageWithTintColor 系列方法并期望它能同时作用于 UIImage 和 QMUIThemeImage（后者总是无效的，因为最终接收消息的总是 rawImage 而不是 QMUIThemeImage），所以这里需要这么冗余地显式写一遍

- (UIImage *)imageWithTintColor:(UIColor *)color {
    return [UIImage qmui_dynamicImageWithOriginalImage:self tintColor:color originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
        aImage.qmui_shouldUseSystemIMP = YES;
        return [aImage imageWithTintColor:color];
    }];
}

- (UIImage *)imageWithTintColor:(UIColor *)color renderingMode:(UIImageRenderingMode)renderingMode {
    return [UIImage qmui_dynamicImageWithOriginalImage:self tintColor:color originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
        aImage.qmui_shouldUseSystemIMP = YES;
        return [aImage imageWithTintColor:color renderingMode:renderingMode];
    }];
}

- (UIImage *)qmui_imageWithTintColor:(UIColor *)color {
    return [UIImage qmui_dynamicImageWithOriginalImage:self tintColor:color originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
        aImage.qmui_shouldUseSystemIMP = YES;
        return [aImage qmui_imageWithTintColor:color];
    }];
}

@end

@implementation UIImage (QMUITheme)

QMUISynthesizeBOOLProperty(qmui_shouldUseSystemIMP, setQmui_shouldUseSystemIMP)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 支持用一个动态颜色直接生成一个动态图片
        OverrideImplementation(object_getClass(UIImage.class), @selector(qmui_imageWithColor:size:cornerRadius:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImage *selfObject, UIColor *color, CGSize size, CGFloat cornerRadius) {
                
                // call super
                UIImage * (^callSuperBlock)(UIColor *, CGSize, CGFloat) = ^UIImage *(UIColor *aColor, CGSize aSize, CGFloat aCornerRadius) {
                    UIImage * (*originSelectorIMP)(id, SEL, UIColor *, CGSize, CGFloat);
                    originSelectorIMP = (UIImage * (*)(id, SEL, UIColor *, CGSize, CGFloat))originalIMPProvider();
                    UIImage * result = originSelectorIMP(selfObject, originCMD, aColor, aSize, aCornerRadius);
                    return result;
                };
                
                if ([color isKindOfClass:QMUIThemeColor.class]) {
                    return [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
                        return callSuperBlock(((QMUIThemeColor *)color).themeProvider(manager, identifier, theme), size, cornerRadius);
                    }];
                }
                return callSuperBlock(color, size, cornerRadius);
            };
        });
        
        OverrideImplementation(object_getClass(UIImage.class), @selector(qmui_imageWithColor:size:cornerRadiusArray:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImage *selfObject, UIColor *color, CGSize size, NSArray<NSNumber *> *cornerRadius) {
                
                // call super
                UIImage * (^callSuperBlock)(UIColor *, CGSize, NSArray<NSNumber *> *) = ^UIImage *(UIColor *aColor, CGSize aSize, NSArray<NSNumber *> * aCornerRadius) {
                    UIImage * (*originSelectorIMP)(id, SEL, UIColor *, CGSize, NSArray<NSNumber *> *);
                    originSelectorIMP = (UIImage * (*)(id, SEL, UIColor *, CGSize, NSArray<NSNumber *> *))originalIMPProvider();
                    UIImage * result = originSelectorIMP(selfObject, originCMD, aColor, aSize, aCornerRadius);
                    return result;
                };
                
                if ([color isKindOfClass:QMUIThemeColor.class]) {
                    return [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
                        return callSuperBlock(((QMUIThemeColor *)color).themeProvider(manager, identifier, theme), size, cornerRadius);
                    }];
                }
                return callSuperBlock(color, size, cornerRadius);
            };
        });
        
        // 令一个静态图片叠加动态颜色可以转换成动态图片
        OverrideImplementation([UIImage class], @selector(qmui_imageWithTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIImage *(UIImage *selfObject, UIColor *tintColor) {
                
                UIImage *result = [UIImage qmui_dynamicImageWithOriginalImage:selfObject tintColor:tintColor originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
                    aImage.qmui_shouldUseSystemIMP = YES;
                    return [aImage qmui_imageWithTintColor:aTintColor];
                }];
                if (!result) {
                    // call super
                    UIImage *(*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (UIImage * (*)(id, SEL, UIColor *))originalIMPProvider();
                    result = originSelectorIMP(selfObject, originCMD, tintColor);
                }
                return result;
            };
        });
        if (@available(iOS 13.0, *)) {
            // 如果一个静态的 UIImage 通过 imageWithTintColor: 传入一个动态的颜色，那么这个 UIImage 也会变成动态的，但这个动态图片是 iOS 13 系统原生的动态图片，无法响应 QMUITheme，所以这里需要为 QMUIThemeImage 做特殊处理。
            // 注意，系统的 imageWithTintColor: 不会调用 imageWithTintColor:renderingMode:，所以要分开重写两个方法
            OverrideImplementation([UIImage class], @selector(imageWithTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UIImage *selfObject, UIColor *tintColor) {
                    
                    UIImage *result = [UIImage qmui_dynamicImageWithOriginalImage:selfObject tintColor:tintColor originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
                        aImage.qmui_shouldUseSystemIMP = YES;
                        return [aImage imageWithTintColor:aTintColor];
                    }];
                    if (!result) {
                        // call super
                        UIImage *(*originSelectorIMP)(id, SEL, UIColor *);
                        originSelectorIMP = (UIImage * (*)(id, SEL, UIColor *))originalIMPProvider();
                        result = originSelectorIMP(selfObject, originCMD, tintColor);
                    }
                    return result;
                };
            });
            OverrideImplementation([UIImage class], @selector(imageWithTintColor:renderingMode:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UIImage *selfObject, UIColor *tintColor, UIImageRenderingMode renderingMode) {
                    
                    UIImage *result = [UIImage qmui_dynamicImageWithOriginalImage:selfObject tintColor:tintColor originalActionBlock:^UIImage *(UIImage *aImage, UIColor *aTintColor) {
                        aImage.qmui_shouldUseSystemIMP = YES;
                        return [aImage imageWithTintColor:aTintColor renderingMode:renderingMode];
                    }];
                    if (!result) {
                        // call super
                        UIImage *(*originSelectorIMP)(id, SEL, UIColor *, UIImageRenderingMode);
                        originSelectorIMP = (UIImage * (*)(id, SEL, UIColor *, UIImageRenderingMode))originalIMPProvider();
                        result = originSelectorIMP(selfObject, originCMD, tintColor, renderingMode);
                    }
                    return result;
                };
            });
        }
    });
}

+ (UIImage *)qmui_imageWithThemeProvider:(UIImage * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIImage qmui_imageWithThemeManagerName:QMUIThemeManagerNameDefault provider:provider];
}

+ (UIImage *)qmui_imageWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIImage * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    QMUIThemeImage *image = [[QMUIThemeImage alloc] init];
    image.cachedRawImages = [[QMUIThemeImageCache alloc] init];
    image.managerName = name;
    image.themeProvider = provider;
    return (UIImage *)image;
}

+ (nullable UIImage *)qmui_dynamicImageWithOriginalImage:(UIImage *)image tintColor:(UIColor *)tintColor originalActionBlock:(UIImage * (^)(UIImage *aImage, UIColor *aTintColor))originalActionBlock {
    if (image.qmui_shouldUseSystemIMP) {
        image.qmui_shouldUseSystemIMP = NO;
        return nil;
    }
    if ([image isKindOfClass:QMUIThemeImage.class]) {
        // 当前是动态 image，不管 tintColor 是否为动态的，都返回一个动态 image
        QMUIThemeImage *themeImage = (QMUIThemeImage *)image;
        return [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
            return originalActionBlock(themeImage.themeProvider(manager, identifier, theme), tintColor);
        }];
    }
    if ([tintColor isKindOfClass:QMUIThemeColor.class]) {
        // 当前是静态 image，则只有当 tintColor 是动态的时候才将静态 image 转换为动态 image
        return [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
            QMUIThemeColor *themeColor = (QMUIThemeColor *)tintColor;
            return originalActionBlock(image, themeColor.themeProvider(manager, identifier, theme));
        }];
    }
    
    return nil;
}

#pragma mark - <QMUIDynamicImageProtocol>

- (UIImage *)qmui_rawImage {
    return self;
}

- (BOOL)qmui_isDynamicImage {
    return NO;
}

@end
