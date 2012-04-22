/////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////

#import "MKTPointBulkViewController.h"
#import "MKTPointViewDataSource.h"
#import "MKTPoint.h"

#import "NSArray+BlocksKit.h"
#import "BKMacros.h"

#import "InnerBand.h"

@interface MKTPointBulkViewController ()

@property(strong) NSArray *points;

- (void)save;
- (void)cancel;

@end

@implementation MKTPointBulkViewController

@synthesize points = _points;

- (id)initWithPoints:(NSArray *)points {

  NSMutableDictionary *model = [[MKTPoint attributesForPoint] mutableCopy];
  
  NSArray* keys = SELECT([model allKeys],(![obj isEqualToString:@"index"]));
  [model removeAllObjects];
  
  if (points.count > 0) {
    MKTPoint *p = [points objectAtIndex:0];
    [keys each:^(NSString* key){
      [model setValue:[p valueForKey:key] forKey:key];
    }];
  }

  MKTPointViewDataSource *dataSource = [[MKTPointViewDataSource alloc] initWithModel:model];

  if ((self = [super initWithNibName:nil bundle:nil formDataSource:dataSource])) {
    self.points = points;
    self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Waypoints", @"Waypoint bulk view title"), points.count];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save bar button") style:UIBarButtonItemStyleDone
                                                                target:self action:@selector(save)];
  self.toolbarItems = [NSArray arrayWithObject:saveButton];

  UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel bar button") style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(cancel)];
  self.navigationItem.rightBarButtonItem = cancelButton;
  self.navigationController.toolbarHidden = NO;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)save {

  NSDictionary *model = self.formDataSource.model;
  for (MKTPoint *p in self.points) {
    [model enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      [p setValue:[model valueForKey:key] forKey:key];
    }];
  }
  [[CoreDataStore mainStore] save];

  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
