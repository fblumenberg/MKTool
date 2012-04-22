//
//  YKUILayoutView.h
//  YelpKit
//
//  Created by Gabriel Handford on 6/19/09.
//  Copyright 2009 Yelp. All rights reserved.
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

#import "YKLayout.h"

typedef void (^YKUIViewSubviewNeedsLayoutBlock)(UIView *view, BOOL animated);

@interface YKUILayoutView : UIView {
  YKLayout *_layout;
  
  YKUIViewSubviewNeedsLayoutBlock _needsLayoutBlock;
}

@property (retain, nonatomic) YKLayout *layout;
@property (copy, nonatomic) YKUIViewSubviewNeedsLayoutBlock needsLayoutBlock;

/*!
 Subclasses can override this method to perform initialization tasks that occur during both initWithFrame: and initWithCoder:
 */
- (void)sharedInit;

/*!
 Force the layout, if using YKLayout.
 You can use this instead of setNeedsLayout + layoutIfNeeded.
 This is also useful when using animations and setNeedsLayout + layoutIfNeeded don't work as expected.
 */
- (void)layoutView;

/*!
 Calls needsLayoutBlock, in the case where you want to make the superview trigger an layout update.
 @param animated YES if the layout should animate
 */
- (void)notifyNeedsLayout:(BOOL)animated;

@end
