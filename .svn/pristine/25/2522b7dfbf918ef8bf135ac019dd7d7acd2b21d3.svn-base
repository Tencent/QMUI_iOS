//
//  UIImage+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CGContextInspectSize(size) [QMUIHelper inspectContextSize:size]

#ifdef DEBUG
    #define CGContextInspectContext(context) [QMUIHelper inspectContextIfInvalidatedInDebugMode:context]
#else
    #define CGContextInspectContext(context) if(![QMUIHelper inspectContextIfInvalidatedInReleaseMode:context]){return nil;}
#endif

typedef NS_ENUM(NSInteger, QMUIImageShape) {
    QMUIImageShapeOval,                 // 椭圆
    QMUIImageShapeTriangle,             // 三角形
    QMUIImageShapeDisclosureIndicator,  // 列表cell右边的箭头
    QMUIImageShapeCheckmark,            // 列表cell右边的checkmark
    QMUIImageShapeNavBack,              // 返回按钮的箭头
    QMUIImageShapeNavClose              // 导航栏的关闭icon
};

typedef NS_OPTIONS(NSInteger, QMUIImageBorderPosition) {
    QMUIImageBorderPositionAll      = 0,
    QMUIImageBorderPositionTop      = 1 << 0,
    QMUIImageBorderPositionLeft     = 1 << 1,
    QMUIImageBorderPositionBottom   = 1 << 2,
    QMUIImageBorderPositionRight    = 1 << 3,
};

@interface UIImage (QMUI)

/**
 *  获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
 *  @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
 *
 *  @return 代表图片平均颜色的UIColor对象
 */
- (UIColor *)qmui_averageColor;

/**
 *  置灰当前图片
 *
 *  @return 已经置灰的图片
 */
- (UIImage *)qmui_grayImage;

/**
 *  设置一张图片的透明度
 *
 *  @param alpha 要用于渲染透明度
 *
 *  @return 设置了透明度之后的图片
 */
- (UIImage *)qmui_imageWithAlpha:(CGFloat)alpha;

/**
 *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
 */
- (BOOL)qmui_opaque;

/**
 *  保持当前图片的形状不变，使用指定的颜色去重新渲染它，生成一张新图片并返回
 *
 *  @param tintColor 要用于渲染的新颜色
 *
 *  @return 与当前图片形状一致但颜色与参数tintColor相同的新图片
 */
- (UIImage *)qmui_imageWithTintColor:(UIColor *)tintColor;

/**
 *  在当前图片的基础上叠加一张图片，并指定绘制叠加图片的起始位置
 *
 *  叠加上去的图片将保持原图片的大小不变，不被压缩、拉伸
 *
 *  @param image 要叠加的图片
 *  @param point 所叠加图片的绘制的起始位置
 *
 *  @return 返回一张与原图大小一致的图片，所叠加的图片若超出原图大小，则超出部分被截掉
 */
- (UIImage *)qmui_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point;

/**
 *  在当前图片的上下左右增加一些空白（不支持负值），通常用于调节NSAttributedString里的图片与文字的间距
 *  @param extension 要拓展的大小
 *  @return 拓展后的图片
 */
- (UIImage *)qmui_imageWithSpacingExtensionInsets:(UIEdgeInsets)extension;

/**
 *  切割出在指定位置中的图片
 *
 *  @param rect 要切割的rect
 *
 *  @return 切割后的新图片
 */
- (UIImage *)qmui_imageWithClippedRect:(CGRect)rect;

/**
 *  将原图按 UIViewContentModeScaleAspectFit 的方式进行缩放，并返回缩放后的图片，处理完的图片的 scale 保持与原图一致。
 *  @param size 缩放后的图片尺寸不超过这个尺寸
 *
 *  @return 处理完的图片
 *  @see qmui_imageWithScaleToSize:contentMode:scale:
 */
- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size;

/**
 *  将原图按指定的 UIViewContentMode 缩放到指定的大小，返回处理完的图片，处理完的图片的 scale 保持与原图一致
 *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同
 *  @param contentMode 希望使用的缩放模式，目前仅支持 UIViewContentModeScaleToFill、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit（默认）
 *
 *  @return 处理完的图片
 *  @see qmui_imageWithScaleToSize:contentMode:scale:
 */
- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;

/**
 *  将原图按指定的 UIViewContentMode 缩放到指定的大小，返回处理完的图片
 *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 contentMode 不同而不同
 *  @param contentMode 希望使用的缩放模式，目前仅支持 UIViewContentModeScaleToFill、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit（默认）
 *  @param scale 处理后返回的图片的 scale
 *
 *  @return 处理完的图片
 */
- (UIImage *)qmui_imageWithScaleToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode scale:(CGFloat)scale;

/**
 *  将原图进行旋转，只能选择上下左右四个方向
 *
 *  @param  direction 旋转的方向
 *
 *  @return 处理完的图片
 */
- (UIImage *)qmui_imageWithOrientation:(UIImageOrientation)direction;

/**
 *  为图片加上一个border，border的路径为path
 *
 *  @param borderColor  border的颜色
 *  @param path         border的路径
 *
 *  @return 带border的UIImage
 *  @warning 注意通过`path.lineWidth`设置边框大小，同时注意路径要考虑像素对齐（`path.lineWidth / 2.0`）
 */
- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor path:(UIBezierPath *)path;

/**
 *  为图片加上一个border，border的路径为borderColor、cornerRadius和borderWidth所创建的path
 *
 *  @param borderColor   border的颜色
 *  @param borderWidth    border的宽度
 *  @param cornerRadius  border的圆角
 *
 *  @param dashedLengths 一个CGFloat的数组，例如`CGFloat dashedLengths[] = {2, 4}`。如果不需要虚线，则传0即可
 *
 *  @return 带border的UIImage
 */
- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius dashedLengths:(const CGFloat *)dashedLengths;
- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;


/**
 *  为图片加上一个border（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
 *
 *  @param borderColor       border的颜色
 *  @param borderWidth        border的宽度
 *  @param borderPosition    border的位置
 *
 *  @return 带border的UIImage
 */
- (UIImage *)qmui_imageWithBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderPosition:(QMUIImageBorderPosition)borderPosition;

/**
 *  返回一个被mask的图片
 *
 *  @param maskImage             mask图片
 *  @param usingMaskImageMode    是否使用“mask image”的方式，若为 YES，则黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。若为 NO，则 maskImage 要求必须为灰度颜色空间的图片（黑白图），白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
 *
 *  @return 被mask的图片
 */
- (UIImage *)qmui_imageWithMaskImage:(UIImage *)maskImage usingMaskImageMode:(BOOL)usingMaskImageMode;

/**
 *  创建一个size为(4, 4)的纯色的UIImage
 *
 *  @param color 图片的颜色
 *
 *  @return 纯色的UIImage
 */
+ (UIImage *)qmui_imageWithColor:(UIColor *)color;

/**
 *  创建一个纯色的UIImage
 *
 *  @param  color           图片的颜色
 *  @param  size            图片的大小
 *  @param  cornerRadius    图片的圆角
 *
 * @return 纯色的UIImage
 */
+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/**
 *  创建一个纯色的UIImage，支持为四个角设置不同的圆角
 *  @param  color               图片的颜色
 *  @param  size                图片的大小
 *  @param  cornerRadius   四个角的圆角值的数组，长度必须为4，顺序分别为[左上角、左下角、右下角、右上角]
 */
+ (UIImage *)qmui_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius;

/**
 *  创建一个带边框路径，没有背景色的路径图片，border的路径为path
 *
 *  @param strokeColor  border的颜色
 *  @param path         border的路径
 *  @param addClip      是否要调path的addClip
 *
 *  @return 带border的UIImage
 */
+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size path:(UIBezierPath *)path addClip:(BOOL)addClip;

/**
 *  创建一个带边框路径，没有背景色的路径图片，border的路径为strokeColor、cornerRadius和lineWidth所创建的path
 *
 *  @param strokeColor  border的颜色
 *  @param lineWidth    border的宽度
 *  @param cornerRadius border的圆角
 *
 *  @return 带border的UIImage
 */
+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;

/**
 *  创建一个带边框路径，没有背景色的路径图片（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
 *
 *  @param strokeColor        路径的颜色
 *  @param size               图片的大小
 *  @param lineWidth          路径的大小
 *  @param borderPosition     图片的路径位置，上左下右
 *
 *  @return 带路径，没有背景色的UIImage
 */
+ (UIImage *)qmui_imageWithStrokeColor:(UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition;
/**
 *  创建一个指定大小和颜色的形状图片
 *  @param shape 图片形状
 *  @param size 图片大小
 *  @param tintColor 图片颜色
 */
+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size tintColor:(UIColor *)tintColor;

/**
 *  创建一个指定大小和颜色的形状图片
 *  @param shape 图片形状
 *  @param size 图片大小
 *  @param lineWidth 路径大小，不会影响最终size
 *  @param tintColor 图片颜色
 */
+ (UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size lineWidth:(CGFloat)lineWidth tintColor:(UIColor *)tintColor;

/**
 *  将文字渲染成图片，最终图片和文字一样大
 */
+ (UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString;

/**
 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回

 @param view 要截图的 `UIView`

 @return `UIView` 的截图
 */
+ (UIImage *)qmui_imageWithView:(UIView *)view;

/**
 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回

 @param view         要截图的 `UIView`
 @param afterUpdates 是否要在界面更新完成后才截图

 @return `UIView` 的截图
 */
+ (UIImage *)qmui_imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates;

@end
