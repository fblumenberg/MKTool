//
//  MKTRouteMasterViewController.m
//  MKTool
//
//  Created by Frank Blumenberg on 23.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKTRouteMasterViewController.h"
#import "MKTRouteMapViewController.h"

#import "UIViewController+MGSplitViewController.h"

#import "InnerBand.h"

@interface MKTRouteMasterViewController (){
  MKTRouteMapViewController *mapController;
}
@end

@implementation MKTRouteMasterViewController


- (id)initWithRoute:(MKTRoute *)route
{
    self = [super initWithRoute:route];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];

  mapController = [[MKTRouteMapViewController alloc] initWithRoute:self.route];
  [[self detailViewController] pushViewController:mapController animated:YES];
  
  [[CoreDataStore mainStore].context.undoManager removeAllActions];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  [[self detailViewController] popViewControllerAnimated:YES];
  mapController=nil;
  [[CoreDataStore mainStore].context.undoManager removeAllActions];
}

- (void)showViewControllerForPoint:(MKTPoint *)point{
  [mapController clearAllSelections];
  [super showViewControllerForPoint:point];
}
@end
