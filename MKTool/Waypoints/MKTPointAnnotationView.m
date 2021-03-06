// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012, Frank Blumenberg
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

#import "MKTPointAnnotationView.h"

@interface MKTPointAnnotationView ()

@end

@implementation MKTPointAnnotationView

@synthesize point=_point;
- (MKTPoint*)point{
  return (MKTPoint*)self.annotation;
}

- (void)setPoint:(MKTPoint *)point{
  self.annotation = point;
  if(point.typeValue == MKTPointTypeWP)
    self.pinColor = point.indexValue==1?MKPinAnnotationColorRed:MKPinAnnotationColorGreen;
  else
    self.pinColor = MKPinAnnotationColorPurple;
}

+ (NSString *)viewReuseIdentifier{
  return @"MKTPointAnnotationView";
}

- (id)initWithPoint:(MKTPoint*)point{
  
  self = [super initWithAnnotation:point reuseIdentifier:[MKTPointAnnotationView viewReuseIdentifier]];
  if (self) {
    
    self.animatesDrop = NO;
    if(point.typeValue == MKTPointTypeWP)
      self.pinColor = point.indexValue==1?MKPinAnnotationColorRed:MKPinAnnotationColorGreen;
    else
      self.pinColor = MKPinAnnotationColorPurple;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 29, 29);
    [closeButton setImage:[UIImage imageNamed:@"delete-point-btn.png"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"delete-point-btn-pressed.png"] forState:UIControlStateHighlighted];
    
    self.leftCalloutAccessoryView = closeButton;
    self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    self.enabled = YES;
    self.canShowCallout = YES;
    self.draggable = YES;
  }
  return self;
}

@end
