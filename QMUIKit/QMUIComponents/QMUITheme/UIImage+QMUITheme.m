//
//  UIImage+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/16.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIImage+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "NSMethodSignature+QMUI.h"
#import "QMUICore.h"

@interface QMUIThemeImage : NSObject <QMUIDynamicImageProtocol>

@property(nonatomic, copy) UIImage *(^themeProvider)(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

@implementation QMUIThemeImage

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

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <QMUIDynamicImageProtocol>

- (UIImage *)qmui_rawImage {
    QMUIThemeManager *manager = QMUIThemeManager.sharedInstance;
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).qmui_rawImage;
}

- (BOOL)qmui_isDynamicImage {
    return YES;
}

@end

@implementation UIImage (QMUITheme)

+ (UIImage *)qmui_imageWithThemeProvider:(UIImage * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    QMUIThemeImage *image = [[QMUIThemeImage alloc] init];
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
