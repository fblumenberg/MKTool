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


#import "MGSplitViewController.h"

#import "MKTAppDelegate.h"

#import "MKTMasterViewController.h"
#import "MKTDetailViewController.h"

#import "MKTRoutesListViewController.h"

#import "BlocksKit.h"

#import "DropboxSDK/DropboxSDK.h"

// Here we import the Dropbox credentials. You have to get your own to compile.
#import "ExternalData.h"

#ifndef kDROPBOX_APP_KEY
#define kDROPBOX_APP_KEY @"<YOUR CONSUMER KEY>"
#endif

#ifndef kDROPBOX_APP_SECRET
#define kDROPBOX_APP_SECRET @"<YOUR CONSUMER SECRET>"
#endif


@interface MKTAppDelegate () <DBSessionDelegate>

@property(strong, nonatomic) UINavigationController *navigationController;
@property(strong, nonatomic) MGSplitViewController *splitViewController;

@end

/////////////////////////////////////////////////////////////////////////////////

@implementation MKTAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//    MKTMasterViewController *masterViewController = [[MKTMasterViewController alloc] initWithNibName:@"MKTMasterViewController_iPhone" bundle:nil];
    MKTRoutesListViewController *routesViewControler = [[MKTRoutesListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:routesViewControler];
    self.window.rootViewController = self.navigationController;
  }
  else {
//    MKTMasterViewController *masterViewController = [[MKTMasterViewController alloc] initWithNibName:@"MKTMasterViewController_iPad" bundle:nil];

    MKTRoutesListViewController *routesViewControler = [[MKTRoutesListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:routesViewControler];

    MKTDetailViewController *detailViewController = [[MKTDetailViewController alloc] initWithNibName:@"MKTDetailViewController_iPad" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

//    masterViewController.detailViewController = detailViewController;

    self.splitViewController = [[MGSplitViewController alloc] init];
//    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];

    self.window.rootViewController = self.splitViewController;
  }
  [self.window makeKeyAndVisible];

  // Initialize the Dropbox support
  // Set these variables before launching the app
  NSString *appKey = kDROPBOX_APP_KEY;
  NSString *appSecret = kDROPBOX_APP_SECRET;
  NSString *root = kDBRootAppFolder;

  DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
  session.delegate = self;
  [DBSession setSharedSession:session];

  return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  if ([[DBSession sharedSession] handleOpenURL:url]) {
    return YES;
  }

  return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
  [[DBSession sharedSession] linkUserId:userId];
}

@end