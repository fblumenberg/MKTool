//
//  YKUIListView.h
//  YelpKit
//
//  Created by Gabriel Handford on 3/24/12.
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

@class YKUIListViewAppearance;

@protocol YKUIListViewSubview <NSObject>
/*!
 If subview returns YES, then we won't draw list appearance for that view.
 */
- (BOOL)hasCustomListViewAppearance;
@end

/*!
 A view which lays out its subviews vertically, and can apply line separators.
 */
@interface YKUIListView : YKUILayoutView {
  NSMutableArray *_views;
  UIEdgeInsets _insets;

  UIColor *_lineSeparatorColor;
  UIColor *_topBorderColor;
  UIEdgeInsets _lineInsets;
  
  NSInteger _tagRemovalAnimating;
}

@property (retain, nonatomic) UIColor *topBorderColor;
@property (retain, nonatomic) UIColor *lineSeparatorColor;
@property (assign, nonatomic) UIEdgeInsets lineInsets;

- (NSArray *)listSubviews;

- (NSInteger)count;

/*!
 Add view.
 @param view
 */
- (void)addView:(UIView *)view;

/*!
 Remove views with tag.
 @param tag
 */
- (void)removeViewsWithTag:(NSInteger)tag;

/*!
 @result Views with tag
 */
- (NSArray *)viewsWithTag:(NSInteger)tag;

/*!
 Set views hidden with tag.
 Useful for animating a fade.
 @param hidden
 @param tag
 @param animationDuration If 0, not animated
 */
- (void)setViewsHidden:(BOOL)hidden tag:(NSInteger)tag animationDuration:(NSTimeInterval)animationDuration;

/*!
 */
- (void)removeAllViews;

@end
