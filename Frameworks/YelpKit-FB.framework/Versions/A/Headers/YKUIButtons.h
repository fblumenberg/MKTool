//
//  YKUIButtons.h
//  YelpKit
//
//  Created by Gabriel Handford on 3/22/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
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

#import "YKUILayoutView.h"
@class YKUIButton;

typedef enum {
  YKUIButtonsStyleHorizontal = 0, // Default
  YKUIButtonsStyleVertical,
  YKUIButtonsStyleHorizontalRounded, // Horizontal with rounded ends
  YKUIButtonsStyleVerticalRounded, // Vertical with rounded ends
} YKUIButtonsStyle;

typedef void (^YKUIButtonsApplyBlock)(YKUIButton *button, NSInteger index);

/*!
 A group of buttons (either horizontal or vertical). This is similar to a segmented control.
 */
@interface YKUIButtons : YKUILayoutView {
  NSMutableArray *_buttons;
  
  YKUIButtonsStyle _style;
}

/*!
 Create a number of buttons.
 @param count
 @param style Style, use rounded style if you want the YKUIButton border style to be automatically set.
 @param apply
 */
- (id)initWithCount:(NSInteger)count style:(YKUIButtonsStyle)style apply:(YKUIButtonsApplyBlock)apply;

/*!
 Create a set of buttons.
 @param buttons List of YKUIButton
 @param style Style, use rounded style if you want the YKUIButton border style to be automatically set.
 @param apply
 */
- (id)initWithButtons:(NSArray */*of YKUIButton*/)buttons style:(YKUIButtonsStyle)style apply:(YKUIButtonsApplyBlock)apply;

/*!
 @result The buttons
 */
- (NSArray *)buttons;

/*!
 Set disabled at button index.
 @param enabled
 @param index
 */
- (void)setEnabled:(BOOL)enabled index:(NSInteger)index;

@end
