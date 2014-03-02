/////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////

#import "MKTConnectionViewController.h"
#import "MKTConnectionViewDataSource.h"
#import "MKTConnection.h"

#import "InnerBand.h"
//#import "NSObject+BlockObservation.h"

@implementation MKTConnectionViewController

#pragma mark -

- (id)initWithConnection:(MKTConnection *)theConnection {

  MKTConnectionViewDataSource *dataSource = [[MKTConnectionViewDataSource alloc] initWithModel:theConnection];

  if ((self = [super initWithNibName:nil bundle:nil formDataSource:dataSource])) {
    self.hidesBottomBarWhenPushed = NO;
    self.title = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Connection", @"Conncetion view title")];
    self.contentSizeForViewInPopover = CGSizeMake(320, 550);
  }
  return self;
}


#pragma mark -

- (void)loadView {
  [super loadView];

  UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

  UITableView *formTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
  [formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self setTableView:formTableView];

  [view addSubview:formTableView];
  [self setView:view];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.hidesBackButton = IS_IPAD();
}

- (void) viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.translucent=NO;
  self.navigationController.toolbar.translucent=NO;
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [[CoreDataStore mainStore] save];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (BOOL)shouldAutoScrollTableToActiveField {
  // Return YES if the table view should be automatically scrolled to the active field
  // Defaults to YES

  return NO;
}

@end

