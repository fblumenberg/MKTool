//
//  GHCGUtils.h
//
//  Created by Gabriel Handford on 12/30/08.
//  Copyright 2008 Gabriel Handford
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

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif

/*!
 Add rounded rect.
 
 @param context Context
 @param rect Rect
 @param cornerWidth Corner width
 @param cornerHeight Corner height
 @param strokeWidth Stroke width
 */
extern void GHContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight, CGFloat strokeWidth);

/*!
 Draw rounded rect.
 
 @param context Context
 @param rect Rect
 @param fillColor Fill color
 @param strokeColor Stroke color
 @param strokeWidth Stroke width
 @param cornerWidth Corner width
 @param cornerHeight Corner height
 */
extern void GHContextDrawRoundedRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerWidth, CGFloat cornerHeight);
