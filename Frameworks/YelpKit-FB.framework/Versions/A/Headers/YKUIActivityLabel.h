//
//  YKUIActivityLabel.h
//  YelpKit
//
//  Created by Gabriel Handford on 4/6/10.
//  Copyright 2010 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "YKUILayoutView.h"

/*!
 Label that includes an activity indicator or image and text, with optional detailed text below it.
 For example, the pull to refresh loading indicator.
 */
@interface YKUIActivityLabel : YKUILayoutView {
  UILabel *_textLabel;
  UILabel *_detailLabel;
  UIActivityIndicatorView *_activityIndicator;
  UIImageView *_imageView;
  
  BOOL _hidesWhenStopped;
}

@property (assign, nonatomic) BOOL hidesWhenStopped;

/*!
 Text label.
 */
@property (readonly, nonatomic) UILabel *textLabel;

/*!
 Detail label, which appears under the textLabel.
 */
@property (readonly, nonatomic) UILabel *detailLabel;

/*!
 Image view, when not animating (activity indicator).
 */
@property (readonly, nonatomic) UIImageView *imageView;

/*!
 Activity indicator style.
 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

/*!
 Set image to display when not animating.
 By default no image is shown.
 @param image Image
 */
- (void)setImage:(UIImage *)image;

/*!
 Set text.
 Alternatively, you can set textLabel.text.
 You should call setNeedsLayout.
 @param text Text
 */
- (void)setText:(NSString *)text;

/*!
 Set detail text.
 You should call setNeedsLayout.
 @param detailText Detail text
 */
- (void)setDetailText:(NSString *)detailText;

/*!
 Start activity indicator.
 */
- (void)startAnimating;

/*!
 Stop activity indicator.
 */
- (void)stopAnimating;

/*!
 Start or stop animating.
 @param animating
 */
- (void)setAnimating:(BOOL)animating;

/*!
 Check if animating (activity indicator).
 */
- (BOOL)isAnimating;

@end
