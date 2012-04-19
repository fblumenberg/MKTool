//
//  MKTMasterViewController.h
//  MKTool
//
//  Created by Frank Blumenberg on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKTDetailViewController;

@interface MKTMasterViewController : UITableViewController

@property (strong, nonatomic) MKTDetailViewController *detailViewController;

@end
