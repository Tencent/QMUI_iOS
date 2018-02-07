//
//  UIImage+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIImage+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "UIBezierPath+QMUI.h"
#import "UIColor+QMUI.h"
#import <Accelerate/Accelerate.h>

CG_INLINE CGSize
CGSizeFlatSpecificScale(CGSize size, float scale) {
    return CGSizeMake(flatSpecificScale(size.width, scale), flatSpecificScale(size.height, scale));
}

@implementation UIImage (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(description), @selector(qmui_description));
    });
}

- (NSString *)qmui_description {
    return [NSString stringWithFormat:@"%@, scale = %@", [self qmui_description], @(self.scale)];
}

- (UIColor *)qmui_averageColor {
	unsigned char rgba[4] = {};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextInspectContext(context);
	CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	if(rgba[3] > 0) {
		return [UIColor colorWithRed:((CGFloat)rgba[0] / rgba[3])
			                   green:((CGFloat)rgba[1] / rgba[3])
			                    blue:((CGFloat)rgba[2] / rgba[3])
			                   alpha:((CGFloat)rgba[3] / 255.0)];
	} else {
		return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0
                               green:((CGFloat)rgba[1]) / 255.0
								blue:((CGFloat)rgba[2]) / 255.0
							   alpha:((CGFloat)rgba[3]) / 255.0];
	}
}

- (UIImage *)qmui_grayImage {
    // CGBitmapContextCreate 是无倍数的，所以要自己换算成1倍
    NSInteger width = self.size.width * self.scale;
    NSInteger height = self.size.height * self.scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    CGContextInspectContext(context);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGRect imageRect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(context, imageRect, self.CGImage);
    
    UIImage *grayImage = nil;
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    if (self.qmui_opaque) {
        grayImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    } else {
        CGContextRef alphaContext = CGBitmapContextCreate(NULL, width, height, 8, 0, nil, kCGImageAlphaOnly);
        CGContextDrawImage(alphaContext, imageRect, self.CGImage);
        CGImageRef mask = CGBitmapContextCreateImage(alphaContext);
		CGImageRef maskedGrayImageRef = CGImageCreateWithMask(imageRef, mask);
        grayImage = [UIImage imageWithCGImage:maskedGrayImageRef scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(mask);
		CGImageRelease(maskedGrayImageRef);
        CGContextRelease(alphaContext);
        
        // 用 CGBitmapContextCreateImage 方式创建出来的图片，CGImageAlphaInfo 总是为 CGImageAlphaInfoNone，导致 qmui_opaque 与原图不一致，所以这里再做多一步
        UIGraphicsBeginImageContextWithOptions(grayImage.size, NO, grayImage.scale);
        [grayImage drawInRect:imageRect];
        grayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    return grayImage;
}

- (UIImage *)qmui_imageWithAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    CGRect drawingRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:drawingRect blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (BOOL)qmui_opaque {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL opaque = alphaInfo == kCGImageAlphaNoneSkipLast
                  || alphaInfo == kCGImageAlphaNoneSkipFirst
                  || alphaInfo == kCGImageAlphaNone;
    return opaque;
}

- (UIImage *)qmui_imageWithTintColor:(UIColor *)tintColor {
    UIImage *imageIn = self;
    CGRect rect = CGRectMake(0, 0, imageIn.size.width, imageIn.size.height);
    UIGraphicsBeginImageContextWithOptions(imageIn.size, self.qmui_opaque, imageIn.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    CGContextTranslateCTM(context, 0, imageIn.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextClipToMask(context, rect, imageIn.CGImage);
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextFillRect(context, rect);
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (UIImage *)qmui_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point {
    UIImage *imageIn = self;
    UIImage *imageOut = nil;
    UIGraphicsBeginImageContextWithOptions(imageIn.size, self.qmui_opaque, imageIn.scale);
    [imageIn drawInRect:CGRectMakeWithSize(imageIn.size)];
    [image drawAtPoint:point];
    imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (UIImage *)qmui_imageWithSpacingExtensionInsets:(UIEdgeInsets)extension {
    CGSize contextSize = CGSizeMake(self.size.width + UIEdgeInsetsGetHorizontalValue(extension), self.size.height + UIEdgeInsetsGetVerticalValue(extension));
    UIGraphicsBeginImageContextWithOptions(contextSize, self.qmui_opaque, self.scale);
    [self drawAtPoint:CGPointMake(extension.left, extension.top)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage *)qmui_imageWithClippedRect:(CGRect)rect {
    CGContextInspectSize(rect.size);
    CGRect imageRect = CGRectMakeWithSize(self.size);
    if (CGRectContainsRect(rect, imageRect)) {
        // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
        return self;
    }
    // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
    CGRect scaledRect = CGRectApplyScale(rect, self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
    UIImage *imageOut = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return imageOut;
}

- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size {
    return [self qmui_imageWithScaleToSize:size contentMode:UIViewContentModeScaleAspectFit];
}

- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    return [self qmui_imageWithScaleToSize:size contentMode:contentMode scale:self.scale];
}

- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode scale:(CGFloat)scale {
    size = CGSizeFlatSpecificScale(size, scale);
    CGContextInspectSize(size);
    CGSize imageSize = self.size;
    CGRect drawingRect = CGRectZero;
    
    if (contentMode == UIViewContentModeScaleToFill) {
        drawingRect = CGRectMakeWithSize(size);
    } else {
        CGFloat horizontalRatio = size.width / imageSize.width;
        CGFloat verticalRatio = size.height / imageSize.height;
        CGFloat ratio = 0;
        if (contentMode == UIViewContentModeScaleAspectFill) {
            ratio = fmaxf(horizontalRatio, verticalRatio);
        } else {
            // 默认按 UIViewContentModeScaleAspectFit
            ratio = fminf(horizontalRatio, verticalRatio);
        }
        drawingRect.size.width = flatSpecificScale(imageSize.width * ratio, scale);
        drawingRect.size.height = flatSpecificScale(imageSize.height * ratio, scale);
    }
    
    UIGraphicsBeginImageContextWithOptions(drawingRect.size, self.qmui_opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    [self drawInRect:drawingRect];
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (UIImage *)qmui_imageWithOrientation:(UIImageOrientation)orientation {
    if (orientation == UIImageOrientationUp) {
        return self;
    }
    
    CGSize contextSize = self.size;
    if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
        contextSize = CGSizeMake(contextSize.height, contextSize.width);
    }
    
    contextSize = CGSizeFlatSpecificScale(contextSize, self.scale);
    
    UIGraphicsBeginImageContextWithOptions(contextSize, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    
    // 画布的原点在左上角，旋转后可能图片就飞到画布外了，所以旋转前先把图片摆到特定位置再旋转，图片刚好就落在画布里
    switch (orientation) {
        case UIImageOrientationUp:
            // 上
            break;
        case UIImageOrientationDown:
            // 下
            CGContextTranslateCTM(context, contextSize.width, contextSize.height);
            CGContextRotateCTM(context, AngleWithDegrees(180));
            break;
        case UIImageOrientationLeft:
            // 左
            CGContextTranslateCTM(context, 0, contextSize.height);
            CGContextRotateCTM(context, AngleWithDegrees(-90));
            break;
        case UIImageOrientationRight:
            // 右
            CGContextTranslateCTM(context, contextSize.width, 0);
            CGContextRotateCTM(context, AngleWithDegrees(90));
            break;
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            // 向上、向下翻转是一样的
            CGContextTranslateCTM(context, 0, contextSize.height);
            CGContextScaleCTM(context, 1, -1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            // 向左、向右翻转是一样的
            CGContextTranslateCTM(context, contextSize.width, 0);
            CGContextScaleCTM(context, -1, 1);
            break;
    }
    
    // 在前面画布的旋转、移动的结果上绘制自身即可，这里不用考虑旋转带来的宽高置换的问题
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageOut;
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor path:(UIBezierPath *)path {
    if (!borderColor) {
        return self;
    }
    
    UIImage *oldImage = self;
    UIImage *resultImage;
    CGRect rect = CGRectMake(0, 0, oldImage.size.width, oldImage.size.height);
    UIGraphicsBeginImageContextWithOptions(oldImage.size, self.qmui_opaque, oldImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    [oldImage drawInRect:rect];
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    [path stroke];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius {
    return [self qmui_imageWithBorderColor:borderColor borderWidth:borderWidth cornerRadius:cornerRadius dashedLengths:0];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius dashedLengths:(const CGFloat *)dashedLengths {
    if (!borderColor || !borderWidth) {
        return self;
    }
    
    UIBezierPath *path;
    CGRect rect = CGRectInset(CGRectMake(0, 0, self.size.width, self.size.height), borderWidth / 2, borderWidth / 2);// 调整rect，从而保证绘制描边时像素对齐
    if (cornerRadius > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    
    path.lineWidth = borderWidth;
    if (dashedLengths) {
        [path setLineDash:dashedLengths count:2 phase:0];
    }
    return [self qmui_imageWithBorderColor:borderColor path:path];
}

- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderPosition:(QMUIImageBorderPosition)borderPosition {
    if (borderPosition == QMUIImageBorderPositionAll) {
        return [self qmui_imageWithBorderColor:borderColor borderWidth:borderWidth cornerRadius:0];
    } else {
        // TODO 使用bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:这个系统接口
        UIBezierPath* path = [UIBezierPath bezierPath];
        if ((QMUIImageBorderPositionBottom & borderPosition) == QMUIImageBorderPositionBottom) {
            [path moveToPoint:CGPointMake(0, self.size.height - borderWidth / 2)];
            [path addLineToPoint:CGPointMake(self.size.width, self.size.height - borderWidth / 2)];
        }
        if ((QMUIImageBorderPositionTop & borderPosition) == QMUIImageBorderPositionTop) {
            [path moveToPoint:CGPointMake(0, borderWidth / 2)];
            [path addLineToPoint:CGPointMake(self.size.width, borderWidth / 2)];
        }
        if ((QMUIImageBorderPositionLeft & borderPosition) == QMUIImageBorderPositionLeft) {
            [path moveToPoint:CGPointMake(borderWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(borderWidth / 2, self.size.height)];
        }
        if ((QMUIImageBorderPositionRight & borderPosition) == QMUIImageBorderPositionRight) {
            [path moveToPoint:CGPointMake(self.size.width - borderWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(self.size.width - borderWidth / 2, self.size.height)];
        }
        [path setLineWidth:borderWidth];
        [path closePath];
        return [self qmui_imageWithBorderColor:borderColor path:path];
    }
    return self;
}

- (UIImage *)qmui_imageWithMaskImage:(UIImage *)maskImage usingMaskImageMode:(BOOL)usingMaskImageMode {
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef mask;
    if (usingMaskImageMode) {
        // 用CGImageMaskCreate创建生成的 image mask。
        // 黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。
        mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                 CGImageGetHeight(maskRef),
                                 CGImageGetBitsPerComponent(maskRef),
                                 CGImageGetBitsPerPixel(maskRef),
                                 CGImageGetBytesPerRow(maskRef),
                                 CGImageGetDataProvider(maskRef), nil, YES);
    } else {
        // 用一个纯CGImage作为mask。这个image必须是单色(例如：黑白色、灰色)、没有alpha通道、不能被其他图片mask。系统的文档：If `mask' is an image, then it must be in a monochrome color space (e.g. DeviceGray, GenericGray, etc...), may not have alpha, and may not itself be masked by an image mask or a masking color.
        // 白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
         mask = maskRef;
    }
    CGImageRef maskedImage = CGImageCreateWithMask(self.CGImage, mask);
    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage scale:self.scale orientation:self.imageOrientation];
    if (usingMaskImageMode) {
        CGImageRelease(mask);
    }
    CGImageRelease(maskedImage);
    return returnImage;
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size path:(UIBezierPath *)path addClip:(BOOL)addClip {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    UIImage *resultImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    if (addClip) [path addClip];
    [path stroke];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius {
    CGContextInspectSize(size);
    // 往里面缩一半的lineWidth，应为stroke绘制线的时候是往两边绘制的
    // 如果cornerRadius为0的时候使用bezierPathWithRoundedRect:cornerRadius:会有问题，左上角老是会多出一点，所以区分开
    UIBezierPath *path;
    CGRect rect = CGRectInset(CGRectMake(0, 0, size.width, size.height), lineWidth / 2, lineWidth / 2);
    if (cornerRadius > 0) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    [path setLineWidth:lineWidth];
    return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
}

+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition {
    CGContextInspectSize(size);
    if (borderPosition == QMUIImageBorderPositionAll) {
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size lineWidth:lineWidth cornerRadius:0];
    } else {
        // TODO 使用bezierPathWithRoundedRect:byRoundingCorners:cornerRadii:这个系统接口
        UIBezierPath* path = [UIBezierPath bezierPath];
        if ((QMUIImageBorderPositionBottom & borderPosition) == QMUIImageBorderPositionBottom) {
            [path moveToPoint:CGPointMake(0, size.height - lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, size.height - lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionTop & borderPosition) == QMUIImageBorderPositionTop) {
            [path moveToPoint:CGPointMake(0, lineWidth / 2)];
            [path addLineToPoint:CGPointMake(size.width, lineWidth / 2)];
        }
        if ((QMUIImageBorderPositionLeft & borderPosition) == QMUIImageBorderPositionLeft) {
            [path moveToPoint:CGPointMake(lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(lineWidth / 2, size.height)];
        }
        if ((QMUIImageBorderPositionRight & borderPosition) == QMUIImageBorderPositionRight) {
            [path moveToPoint:CGPointMake(size.width - lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height)];
        }
        [path setLineWidth:lineWidth];
        [path closePath];
        return [UIImage qmui_imageWithStrokeColor:strokeColor size:size path:path addClip:NO];
    }
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color {
    return [UIImage qmui_imageWithColor:color size:CGSizeMake(4, 4) cornerRadius:0];
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    
    UIImage *resultImage = nil;
    color = color ? color : UIColorClear;

	BOOL opaque = (cornerRadius == 0.0 && [color qmui_alpha] == 1.0);
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    if (cornerRadius > 0) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadius:cornerRadius];
        [path addClip];
        [path fill];
    } else {
        CGContextFillRect(context, CGRectMakeWithSize(size));
    }
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    
    color = color ? color : UIColorWhite;
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    UIBezierPath *path = [UIBezierPath qmui_bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadiusArray:cornerRadius lineWidth:0];
    [path addClip];
    [path fill];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size lineWidth:(CGFloat)lineWidth tintColor:(UIColor *)tintColor {
    size = CGSizeFlatted(size);
    CGContextInspectSize(size);
    
    UIImage *resultImage = nil;
    tintColor = tintColor ? tintColor : UIColorWhite;
    
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    UIBezierPath *path = nil;
    BOOL drawByStroke = NO;
    CGFloat drawOffset = lineWidth / 2;
    switch (shape) {
        case QMUIImageShapeOval: {
            path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize(size)];
        }
            break;
        case QMUIImageShapeTriangle: {
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, size.height)];
            [path addLineToPoint:CGPointMake(size.width / 2, 0)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
            [path closePath];
        }
            break;
        case QMUIImageShapeNavBack: {
            drawByStroke = YES;
            path = [UIBezierPath bezierPath];
            path.lineWidth = lineWidth;
            [path moveToPoint:CGPointMake(size.width - drawOffset, drawOffset)];
            [path addLineToPoint:CGPointMake(0 + drawOffset, size.height / 2.0)];
            [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height - drawOffset)];
        }
            break;
        case QMUIImageShapeDisclosureIndicator: {
            path = [UIBezierPath bezierPath];
            drawByStroke = YES;
            path.lineWidth = lineWidth;
            [path moveToPoint:CGPointMake(drawOffset, drawOffset)];
            [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height / 2)];
            [path addLineToPoint:CGPointMake(drawOffset, size.height - drawOffset)];
        }
            break;
        case QMUIImageShapeCheckmark: {
            CGFloat lineAngle = M_PI_4;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, size.height / 2)];
            [path addLineToPoint:CGPointMake(size.width / 3, size.height)];
            [path addLineToPoint:CGPointMake(size.width, lineWidth * sin(lineAngle))];
            [path addLineToPoint:CGPointMake(size.width - lineWidth * cos(lineAngle), 0)];
            [path addLineToPoint:CGPointMake(size.width / 3, size.height - lineWidth / sin(lineAngle))];
            [path addLineToPoint:CGPointMake(lineWidth * sin(lineAngle), size.height / 2 - lineWidth * sin(lineAngle))];
            [path closePath];
        }
            break;
        case QMUIImageShapeNavClose: {
            drawByStroke = YES;
            path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
            [path closePath];
            [path moveToPoint:CGPointMake(size.width, 0)];
            [path addLineToPoint:CGPointMake(0, size.height)];
            [path closePath];
            path.lineWidth = lineWidth;
            path.lineCapStyle = kCGLineCapRound;
        }
            break;
        default:
            break;
    }
    
    if (drawByStroke) {
        CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
        [path stroke];
    } else {
        CGContextSetFillColorWithColor(context, tintColor.CGColor);
        [path fill];
    }
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat lineWidth = 0;
    switch (shape) {
        case QMUIImageShapeNavBack:
            lineWidth = 2.0f;
            break;
        case QMUIImageShapeDisclosureIndicator:
            lineWidth = 1.5f;
            break;
        case QMUIImageShapeCheckmark:
            lineWidth = 1.5f;
            break;
        case QMUIImageShapeNavClose:
            lineWidth = 1.2f;   // 取消icon默认的lineWidth
            break;
        default:
            break;
    }
    return [UIImage qmui_imageWithShape:shape size:size lineWidth:lineWidth tintColor:tintColor];
}

+ (UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString {
    CGSize stringSize = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    stringSize = CGSizeCeil(stringSize);
    UIGraphicsBeginImageContextWithOptions(stringSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    [attributedString drawInRect:CGRectMake(0, 0, stringSize.width, stringSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithView:(UIView *)view {
    CGContextInspectSize(view.frame.size);
    // 老方式，因为drawViewHierarchyInRect:afterScreenUpdates:有一定的使用条件，有些情况下不一定截得到图，所有这种情况下可以使用老方式。
    // 如果可以用新方式，则建议使用新方式，性能上好很多
    UIImage *resultImage = nil;
    // 第二个参数是不透明度，这里默认设置为YES，不用出来alpha通道的事情，可以提高性能
    // 第三个参数是scale，设置为0的时候，意思是使用屏幕的scale
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextInspectContext(context);
    [view.layer renderInContext:context];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)qmui_imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates {
    // iOS7截图新方式，性能好会好一点，不过不一定适用，因为这个方法的使用条件是：界面要已经render完，否则截到得图将会是empty。
    // 如果是iOS6调用这个接口，将会使用老的方式。
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        UIImage *resultImage = nil;
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
        [view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)) afterScreenUpdates:afterUpdates];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImage;
    } else {
        return [self qmui_imageWithView:view];
    }
}

@end
