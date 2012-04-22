//
//  YKCGUtils.h
//  YelpKit
//
//  Created by Gabriel Handford on 12/30/08.
//  Copyright 2008 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

// Represents NULL point (CoreGraphics only has CGRectNull)
extern const CGPoint YKCGPointNull;

// Check if point is Null (CoreGraphics only has CGRectIsNull)
extern bool YKCGPointIsNull(CGPoint point);

// Represents NULL size (CoreGraphics only has CGRectNull)
extern const CGSize YKCGSizeNull;

// Check if size is Null (CoreGraphics only has CGRectIsNull)
extern bool YKCGSizeIsNull(CGSize size);

/*!
 Add rounded rect to current context path.
 @param context
 @param rect
 @param strokeWidth Width of stroke (so that we can inset the rect); Since stroke occurs from center of path we need to inset by half the strong amount otherwise the stroke gets clipped.
 @param cornerRadius Corner radius
 */
void YKCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Draw rounded rect to current context.
 @param context
 @param rect
 @param fillColor If not NULL, will fill in rounded rect with color
 @param strokeColor Color of stroke
 @param strokeWidth Width of stroke
 @param cornerRadius Radius of rounded corners
 */
void YKCGContextDrawRoundedRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Draw (fill and/or stroke) path.
 @param context
 @param path
 @param fillColor If not NULL, will fill in rounded rect with color
 @param strokeColor Color of stroke
 @param strokeWidth Width of stroke
 
 */
void YKCGContextDrawPath(CGContextRef context, CGPathRef path, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth);

/*!
 Create rounded rect path.
 @param rect
 @param strokeWidth Width of stroke
 @param cornerRadius Radius of rounded corners
 */
CGPathRef YKCGPathCreateRoundedRect(CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Add line from (x, y) to (x2, y2) to context path.
 @param context
 @param x
 @param y
 @param x2
 @param y2
 */
void YKCGContextAddLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2);

/*!
 Draw line from (x, y) to (x2, y2).
 @param context
 @param x
 @param y
 @param x2
 @param y2
 @param strokeColor Line color
 @param strokeWidth Line width (draw from center of width (x+(strokeWidth/2), y+(strokeWidth/2)))
 */
void YKCGContextDrawLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2, CGColorRef strokeColor, CGFloat strokeWidth);

/*!
 Draws image inside rounded rect.
 
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param cornerRadius Corner radius for rounded rect
 @param contentMode Content Mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used.
 */
void YKCGContextDrawRoundedRectImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor);

/*!
 Draws image inside rounded rect with shadow.
 
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param cornerRadius Corner radius for rounded rect
 @param contentMode Content Mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used.
 @param shadowColor Shadow color (or NULL)
 @param shadowBlur Shadow blur amount
 */
void YKCGContextDrawRoundedRectImageWithShadow(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor, CGColorRef shadowColor, CGFloat shadowBlur);

/*!
 Draws image.
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param contentMode Content mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used. 
 */
void YKCGContextDrawImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, UIViewContentMode contentMode, CGColorRef backgroundColor);

/*!
 Figure out the rectangle to fit 'size' into 'inSize'.
 @param size
 @param inSize
 @param fill
 */
CGRect YKCGRectScaleAspectAndCenter(CGSize size, CGSize inSize, BOOL fill);

/*!
 Point to place region of size1 into size2, so that its centered.
 @param size1
 @param size2
 */
CGPoint YKCGPointToCenter(CGSize size1, CGSize size2);

/*!
 Point to place region of size1 into size2, so that its centered in Y position.
 */
CGPoint YKCGPointToCenterY(CGSize size, CGSize inSize);

/*!
 Returns if point is zero origin.
 */
BOOL YKCGPointIsZero(CGPoint p);

/*!
 Check if equal.
 @param p1
 @param p2
 */
BOOL YKCGPointIsEqual(CGPoint p1, CGPoint p2);

/*!
 Check if equal.
 @param size1
 @param size2
 */
BOOL YKCGSizeIsEqual(CGSize size1, CGSize size2);

/*!
 Check if size is zero.
 */
BOOL YKCGSizeIsZero(CGSize size);

/*!
 Check if equal within some accuracy.
 @param rect1
 @param rect2
 */
BOOL YKCGRectIsEqual(CGRect rect1, CGRect rect2);

/*!
 Returns a rect that is centered vertically in inRect but horizontally unchanged
 @param rect The inner rect
 @param inRect The rect to center inside of
 */
CGRect YKCGRectToCenterY(CGRect rect, CGRect inRect);

/*!
 TODO(gabe): Document
 */
CGPoint YKCGPointToRight(CGSize size, CGSize inSize);

/*!
 Center size in size.
 @param size Size for element to center
 @param inSize Containing size
 @result Centered on x and y, returning a size same as size (1st argument)
 */
CGRect YKCGRectToCenter(CGSize size, CGSize inSize);

BOOL YKCGSizeIsEmpty(CGSize size);

/*!
 TODO(gabe): Document
 */
CGRect YKCGRectToCenterInRect(CGSize size, CGRect inRect);

/*!
 TODO(gabe): Document
 */
CGFloat YKCGFloatToCenter(CGFloat length, CGFloat inLength, CGFloat min);

/*!
 Adds two rectangles.
 TODO(gabe): Document
 */
CGRect YKCGRectAdd(CGRect rect1, CGRect rect2);


/*!
 Get rect to right align width inside inWidth with maxWidth and padding on the right.
 */
CGRect YKCGRectRightAlign(CGFloat y, CGFloat width, CGFloat inWidth, CGFloat maxWidth, CGFloat padRight, CGFloat height);

/*!
 Copy of CGRect with (x, y) origin set to 0.
 */
CGRect YKCGRectZeroOrigin(CGRect rect);

/*!
 Set size on rect.
 */
CGRect YKCGRectSetSize(CGRect rect, CGSize size);

/*!
 Set height on rect.
 */
CGRect YKCGRectSetHeight(CGRect rect, CGFloat height);

/*
 Set width on rect.
 */
CGRect YKCGRectSetWidth(CGRect rect, CGFloat width);

/*!
 Set x on rect.
 */
CGRect YKCGRectSetX(CGRect rect, CGFloat x);

/*!
 Set y on rect.
 */
CGRect YKCGRectSetY(CGRect rect, CGFloat y);


CGRect YKCGRectSetOrigin(CGRect rect, CGFloat x, CGFloat y);

CGRect YKCGRectSetOriginPoint(CGRect rect, CGPoint p);

CGRect YKCGRectOriginSize(CGPoint origin, CGSize size);

CGRect YKCGRectAddPoint(CGRect rect, CGPoint p);

CGRect YKCGRectAddHeight(CGRect rect, CGFloat height);

CGRect YKCGRectAddX(CGRect rect, CGFloat add);

CGRect YKCGRectAddY(CGRect rect, CGFloat add);

/*!
 Bottom right point in rect. (x + width, y + height).
 */
CGPoint YKCGPointBottomRight(CGRect rect);

CGFloat YKCGDistanceBetween(CGPoint pointA, CGPoint pointB);

/*!
 Returns a rect that is inset inside of size.
 */
CGRect YKCGRectWithInsets(CGSize size, UIEdgeInsets insets);

#pragma mark Border Styles

// Border styles:
// So far only borders for the group text field; And allow you to have top, middle, middle, middle, bottom.
//
//   YKUIBorderStyleNormal
//   -------
//   |     |
//   -------
//
//   YKUIBorderStyleRoundedTop:
//   ╭----╮
//   |     |
//
//
//   YKUIBorderStyleLeftRightWithAlternateTop
//   -------  (alternate stroke on top)
//   |     |
//
//  
//   YKUIBorderStyleRoundedBottomWithAlternateTop
//   -------  (alternate stroke on top)
//   |     |
//   ╰----╯
//
typedef enum {
  YKUIBorderStyleNone = 0,
  YKUIBorderStyleNormal,
  YKUIBorderStyleRounded, // Rounded top, right, bottom, left
  YKUIBorderStyleTopOnly, // Top (straight) only
  YKUIBorderStyleBottomOnly, // Bottom (straight) only
  YKUIBorderStyleTopBottom, // Top and bottom only
  YKUIBorderStyleRoundedTop, // Rounded top with left and right sides (no bottom); Uses strokeWidth for all sides
  YKUIBorderStyleLeftRightWithAlternateTop, // Left and right sides (no bottom) in strokeWidth; Top in alternateStrokeWidth
  YKUIBorderStyleRoundedBottomWithAlternateTop, // Rounded bottom with left and right sides in strokeWidth; Top in alternateStrokeWidth  
  //YKUIBorderStyleTopBottomRight, // Top bottom and right sides in strokeWidth
  YKUIBorderStyleRoundedTopOnly, // Rounded top with no sides
  YKUIBorderStyleRoundedLeftCap,
  YKUIBorderStyleRoundedRightCap,
} YKUIBorderStyle;

CGPathRef YKCGPathCreateStyledRect(CGRect rect, YKUIBorderStyle style, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius);

/*!
 Create path for line.
 @param x1
 @param y1
 @param x2
 @param y2
 */
CGPathRef YKCGPathCreateLine(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2);

void YKCGContextAddStyledRect(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius);

BOOL YKCGContextAddAlternateBorderToPath(CGContextRef context, CGRect rect, YKUIBorderStyle style);

void YKCGContextDrawBorder(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius);

void YKCGContextDrawBorderWithShadow(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius, CGColorRef shadowColor, CGFloat shadowBlur);

void YKCGContextDrawRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth);

#pragma mark Colors

void YKCGColorGetComponents(CGColorRef color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);

#pragma mark Shading

typedef enum {
  YKUIShadingTypeUnknown = -1,
  YKUIShadingTypeNone = 0,
  YKUIShadingTypeLinear, // Linear color blend (for color to color2)
  YKUIShadingTypeHorizontalEdge, // Horizontal edge (for color to color2 and color3 to color4)
  YKUIShadingTypeHorizontalReverseEdge, // Horizontal edge reversed
  YKUIShadingTypeExponential,
  YKUIShadingTypeMetalEdge,
} YKUIShadingType;

void YKCGContextDrawShadingWithHeight(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGFloat height, YKUIShadingType shadingType);

void YKCGContextDrawShading(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGPoint start, CGPoint end, YKUIShadingType shadingType, 
                            BOOL extendStart, BOOL extendEnd);


/*!
 Convert rect for size with content mode.
 @param rect Bounds
 @param size Size of view
 @param contentMode Content mode
 */
CGRect YKCGRectConvert(CGRect rect, CGSize size, UIViewContentMode contentMode);

/*!
 Description for content mode.
 For debugging.
 */
NSString *YKNSStringFromUIViewContentMode(UIViewContentMode contentMode);

/*!
 Scale a CGRect's size while maintaining a fixed center point.
 @param rect CGRect to scale
 @param scale Scale factor by which to increaase the size of the rect
 */
CGRect YKCGRectScaleFromCenter(CGRect rect, CGFloat scale);


void YKCGTransformHSVRGB(float *components);
void YKTransformRGBHSV(float *components);

void YKCGContextDrawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);

UIImage *YKCreateVerticalGradientImage(CGFloat height, CGColorRef topColor, CGColorRef bottomColor);


/*!
 Get a rounded corner mask. For example, for using as a CALayer mask.
 */
UIImage *YKCGContextRoundedMask(CGRect rect, CGFloat cornerRadius);
