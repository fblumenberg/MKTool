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

#import "MKTTableSection.h"

@interface MKTTableSection (){
  
}

@end

@implementation MKTTableSection

@synthesize expanded = _expanded;
@synthesize expandabel = _expandabel;
@synthesize items = _items;

- (id)initWithExpandabel:(BOOL)expandabel {
  self = [super init];
  if (self) {
    _items=[NSMutableArray array];
    _expandabel=expandabel;
    _expanded=NO;
  }
  return self;
}

- (MKTTableItem*) itemForIndexPath:(NSIndexPath*)indexPath{
  return [_items objectAtIndex:indexPath.row];
}

@end


@implementation MKTTableItem

@synthesize title = _title;
@synthesize detail = _detail;
@synthesize executionBlock = _executionBlock;
@synthesize accessoryType = _accessoryType;
@synthesize accessoryView = _accessoryView;
@synthesize selectionStyle = _selectionStyle;

- (id)initWithTitle:(NSString*)title{
  self = [super init];
  if (self) {
    _title =title;
    _executionBlock = NULL;
    _accessoryType = UITableViewCellAccessoryNone;
    _selectionStyle = UITableViewCellSelectionStyleNone;

  }
  return self;
}

- (id)initWithTitle:(NSString *)title andExecutionBlock:(MKTTableItemBlock)block{
  self = [self init];
  if (self) {
    _title =title;
    _executionBlock = block;
    _accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _selectionStyle = UITableViewCellSelectionStyleBlue;
  }  
  
  return self;
}


- (void)execute{
  
  if(_executionBlock){
    _executionBlock();
  }
}


@end
