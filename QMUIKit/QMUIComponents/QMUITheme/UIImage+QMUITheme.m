/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
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
#import <objc/message.h>

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

@interface QMUIThemeImage()

@property(nonatomic, strong) QMUIThemeImageCache *cachedRawImages;

@end

@implementation QMUIThemeImage


static IMP qmui_getMsgForwardIMP(NSObject *self, SEL selector) {
    IMP msgForwardIMP = _objc_msgForward;
    #if !defined(__arm64__)
        Class cls = self.class;
        Method method = class_getInstanceMethod(cls, selector);
        const char *typeDescription = method_getTypeEncoding(method);
        if (typeDescription[0] == '{') {
            // 以下代码参考 JSPatch 的实现：
            //In some cases that returns struct, we should use the '_stret' API:
            //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
            //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
            if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
                msgForwardIMP = (IMP)_objc_msgForward_stret;
            }
        }
    #endif
    return msgForwardIMP;
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
        
        // dealloc 时，不应该转发给 qmui_rawImage 处理，因为 qmui_rawImage 可能会有其他对象引用，不一定在 QMUIThemeImage 释放后就随之释放
        // 这里不能在 QMUIThemeImage 直接写 '- (void)dealloc { _themeProvider = nil; }' ，因为这样写会先调用 super dealloc，而 UIImage 的 dealloc 方法里会调用其他方法，从而再次触发消息转发、访问 qmui_rawImage，这可能会导致一些野指针问题，通过下面的方式，保持在执行 super dealloc 之前，先清空 _themeProvider
        OverrideImplementation([QMUIThemeImage class], NSSelectorFromString(@"dealloc"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(__unsafe_unretained QMUIThemeImage *selfObject) {
                selfObject->_themeProvider = nil;
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    });
}

- (instancetype)init {
    return ((id (*)(id, SEL))[NSObject instanceMethodForSelector:_cmd])(self, _cmd);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.qmui_rawImage methodSignatureForSelector:aSelector];
    if (result && [self.qmui_rawImage respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature qmui_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.qmui_rawImage respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.qmui_rawImage];
    }
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

- (BOOL)isSymbolImage {
    return self.qmui_rawImage.isSymbolImage;
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

- (UIImage *)imageWithTintColor:(UIColor *)color {
    return [self.qmui_rawImage imageWithTintColor:color];
}

- (UIImage *)imageWithTintColor:(UIColor *)color renderingMode:(UIImageRenderingMode)renderingMode {
    return [self.qmui_rawImage imageWithTintColor:color renderingMode:renderingMode];
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

@end

@implementation UIImage (QMUITheme)

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

#pragma mark - <QMUIDynamicImageProtocol>

- (UIImage *)qmui_rawImage {
    return self;
}

- (BOOL)qmui_isDynamicImage {
    return NO;
}

@end
