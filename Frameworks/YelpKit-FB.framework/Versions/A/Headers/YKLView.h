//
//  YKLView.h
//  YelpKit
//
//  Created by Gabriel Handford on 4/11/12.
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

/*!
 Base class for YKLayout subviews.
 */
@interface YKLView : NSObject {
  CGRect _frame;
}

@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) CGPoint origin;

/*!
 Size that fits for this view.
 */
- (CGSize)sizeThatFits:(CGSize)size;

/*!
 Returns rect for this view in the superview frame based on content mode.
 @param rect Superview frame
 @param contentMode Where to place view in rect
 */
- (CGRect)sizeThatFitsInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode;

/*!
 Draw view in rect.
 @param rect Rect to draw at/in.
 */
- (void)drawInRect:(CGRect)rect;

/*!
 Draw this view at the current frame.
 Defaults to [self drawInRect:self.frame];.
 @param rect Dirty rect
 */
- (void)drawRect:(CGRect)rect;

/*!
 Draw this view.
 Defaults to [self drawRect:self.frame];.
 */
- (void)draw;

@end
