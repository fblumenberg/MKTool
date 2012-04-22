//
//  YKUINavigationBar.h
//  YelpKit
//
//  Created by Gabriel Handford on 3/31/12.
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

@interface YKUINavigationBar : UIView {
  UIView *_contentView;
  UIView *_leftButton;
  UIView *_rightButton;
  
  CGSize _defaultContentViewSize;
}

@property (retain, nonatomic) UIView *leftButton;
@property (retain, nonatomic) UIView *rightButton;
@property (retain, nonatomic) UIView *contentView;

/*!
 Set the content view to a UILabel with title.
 @param title
 @param animated
 */
- (void)setTitle:(NSString *)title animated:(BOOL)animated;

/*!
 Set the content view.
 Content view must return a valid sizeThatFits: method.
 @param contentView
 @param animated
 */
- (void)setContentView:(UIView *)contentView animated:(BOOL)animated;

/*!
 Set right button.
 @param rightButton
 @param animated
 */
- (void)setRightButton:(UIView *)rightButton animated:(BOOL)animated;

/*!
 Set left button.
 @param leftButton
 @param animated
 */
- (void)setLeftButton:(UIView *)leftButton animated:(BOOL)animated;

@end
