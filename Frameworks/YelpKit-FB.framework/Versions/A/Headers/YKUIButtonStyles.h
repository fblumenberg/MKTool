//
//  YKUIButtonStyles.h
//  YelpKit
//
//  Created by Gabriel Handford on 10/25/11.
//  Copyright (c) 2011 Yelp. All rights reserved.
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

#import "YKUIButton.h"

/*!
 Button styles.
 */
typedef enum {
  YKUIButtonStyleNone, //! No style
  YKUIButtonStyleBasic, //! Basic (rounded) button white background, blueish text with gray selection background (similar to Apple default)
  YKUIButtonStyleBasicGrouped, //! Same as YKUIButtonStyleBasic, but with background matching that of grouped table views
  YKUIButtonStyleDarkBlue, //! Button with white (etched) text on dark blue linear shaded background
  YKUIButtonStyleGray, //! Gray background with linear shaded background and etched text
  YKUIButtonStyleDarkGray, //! Dark gray background with linear shaded background and etched text
  YKUIButtonStyleBlack,
  YKUIButtonStyleLink, //! Button with blue text on clear background
  YKUIButtonStyleBlackToolbar, //! Black translucent button with white text
  YKUIButtonStyleToggleBlue, //! Blueish toggle button
  YKUIButtonStyleTransparent, //! Transparent button
  YKUIButtonStyleMetal, //! Top/bottom gray with shadow
  YKUIButtonStyleGrayDisclosure, //! Gray, extra rounded with disclosure
  YKUIButtonStyleWhiteDisclosure, //! White, extra rounded with disclosure
  YKUIButtonStyleFatYellow, //! Yellow with white border
  YKUIButtonStyleSkinnyYellow, //! Yellow with smaller corner radius and font size
  YKUIButtonStyleGreen, //! Green
  YKUIButtonStyleBasicCellDisclosure, // Basic button, white background, blueish text with gray selection background (similar to Apple default), like cell with disclosure
} YKUIButtonStyle;


@interface YKUIButtonStyles : NSObject 

/*!
 Set a button style.
 @param style Style
 @param button Button
 */
+ (void)setStyle:(YKUIButtonStyle)style button:(YKUIButton *)button;

@end
