//
//  YKUIImageActivityView.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 12/14/10.
//  Copyright 2010 Yelp. All rights reserved.
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

#import "YKUIImageView.h"
#import "YKUIActivityView.h"
#import "YKUIControl.h"


@protocol YKUIImageActivityView <YKUIImageView>
@property (readonly, nonatomic) YKUIImageViewStatus status;
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityStyle;
- (void)startActivity;
- (void)stopActivity;
- (void)cancel;
@end


/*!
 YKUIImageView that includes an activity indicator/label while loading images.
 */
@interface YKUIImageActivityView : YKUIImageView <YKUIImageActivityView> {
  YKUIActivityView *_activityView;
  BOOL _autoActivityDisabled;
}

@property (readonly, nonatomic) YKUIActivityView *activityView;

/*!
 The activity indicator will show on image load start automatically. Defaults to NO.
 You can disabled it by setting autoActivityDisabled to YES.
 */
@property (assign, nonatomic, getter=isAutoActivityDisabled) BOOL autoActivityDisabled;

- (void)startActivity;
- (void)stopActivity;

@end
