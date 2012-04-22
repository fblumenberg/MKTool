//
//  YPUIRefreshTableView.h
//

//  Code adapted from: EGORefreshTableHeaderView.h
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
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

#import "YKUIActivityLabel.h"

typedef enum {
  YKUIPullRefreshPulling = 1,
  YKUIPullRefreshNormal = 2,
  YKUIPullRefreshLoading = 3, 
} YKUIPullRefreshState;

/*!
 Pull to refresh header view.
 */
@interface YKUIRefreshTableHeaderView : UIView {

  YKUIActivityLabel *_activityLabel;
  UIImageView *_imageView;
  
  CALayer *_iconLayer;
  UIImage *_icon;
  UIActivityIndicatorView *_activityView;
  
  CGFloat _pullHeight;
  CGFloat _pullAmount;
  BOOL _momentary;
  
  BOOL _pullIconDisabled; // Whether to disable pull icon; Defaults to YES!
  
  YKUIPullRefreshState _state;
  
}

@property (assign, nonatomic) YKUIPullRefreshState state;
@property (assign, nonatomic) CGFloat pullHeight;
@property (assign, nonatomic) CGFloat pullAmount;
@property (assign, nonatomic, getter=isMomentary) BOOL momentary; // If YES, will not stay pulled down while loading
@property (assign, nonatomic, getter=isPullIconDisabled) BOOL pullIconDisabled; // Whether to disable pull icon; Defaults to NO

@end
