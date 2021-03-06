// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2011, Frank Blumenberg
//
// See License.txt for complete licensing and attribution information.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ///////////////////////////////////////////////////////////////////////////////


#import <UIKit/UIKit.h>

@interface IKOutputSetting : UIControl <NSCoding>

@property(nonatomic, readwrite) NSInteger value;

@property(nonatomic, retain) UIColor *insetColorIdleOn;
@property(nonatomic, retain) UIColor *insetColorIdleOff;
@property(nonatomic, retain) UIColor *insetColorOn;
@property(nonatomic, retain) UIColor *insetColorOff;
@property(nonatomic, retain) UIColor *frameColor;

@property(nonatomic, readwrite) BOOL doDrawFrame;
@property(nonatomic, readwrite) BOOL shining;

@property(nonatomic, readwrite) BOOL showIdle;

@property(nonatomic, readwrite) CGFloat cornerRoundness;

@property(nonatomic, retain) NSString *key;

@end
