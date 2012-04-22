//
//  YKUIBorder.h
//  YelpKit
//
//  Created by Gabriel Handford on 12/29/08.
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

#import "YKCGUtils.h"

/*!
 
 Border view component.
 
 For example,
   UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
   YKUIBorder *border = [[YKUIBorder alloc] initWithFrame:CGRectMake(10, 10, 300, 0) style:YKUIBorderStyleRounded stroke:1.0 color:[UIColor grayColor]];
   border.fillColor = [UIColor whiteColor]; 
 */
@interface YKUIBorder : UIView {
  YKUIBorderStyle _style;
  CGFloat _cornerRadius;
  UIColor *_color;
  CGFloat _strokeWidth;
  CGFloat _alternateStrokeWidth;
  UIColor *_fillColor;
  UIColor *_highlightedColor;
  UIColor *_cornerColor;
  
  BOOL _highlighted;
  
  YKUIShadingType _shadingType;
  UIColor *_shadingColor;
  UIColor *_shadingAlternateColor;
  
  UIColor *_shadowColor;
  CGFloat _shadowBlur;
  UIEdgeInsets _insets;
}

@property (retain, nonatomic) UIView *contentView;
@property (assign, nonatomic) YKUIBorderStyle style;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (retain, nonatomic) UIColor *color;
@property (assign, nonatomic) CGFloat strokeWidth;
@property (assign, nonatomic) CGFloat alternateStrokeWidth;
@property (retain, nonatomic) UIColor *fillColor;
@property (retain, nonatomic) UIColor *cornerColor;
@property (retain, nonatomic) UIColor *highlightedColor;
@property (assign, nonatomic, getter=isHighlighted) BOOL highlighted;

@property (assign, nonatomic) YKUIShadingType shadingType;
@property (retain, nonatomic) UIColor *shadingColor;
@property (retain, nonatomic) UIColor *shadingAlternateColor;

@property (retain, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGFloat shadowBlur;
@property (assign, nonatomic) UIEdgeInsets insets;

/*!
 Create border view with style.
 @param frame
 @param style The border style
 */
- (id)initWithFrame:(CGRect)frame style:(YKUIBorderStyle)style;

/*!
 Create border view with style.
 @param frame
 @param style The border style
 @param stroke Border width
 @param color Border color
 */
- (id)initWithFrame:(CGRect)frame style:(YKUIBorderStyle)style stroke:(CGFloat)stroke color:(UIColor *)color;

/*!
 Draw border in a given rect. Useful for directly drawing YKUIBorder to a context.
 @param rect The rect in which to draw the border
 */
- (void)drawInRect:(CGRect)rect;

@end