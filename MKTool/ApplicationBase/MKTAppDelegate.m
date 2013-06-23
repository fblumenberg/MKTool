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

#import <Crashlytics/Crashlytics.h>


#ifdef CYDIA
NSString* const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";
//#import "BWQuincyManager.h"
#else
#import "TestFlight.h"
//extern void UninstallCrashHandlers(BOOL restore);
#endif

#import "MGSplitViewController.h"

#import "MKTAppDelegate.h"

#import "MKTDetailViewController.h"

#import "MKTMainMenuController.h"

#import "MKConnectionController.h"

#import "BlocksKit.h"
#import "InnerBand.h"

#import "MBProgressHUD.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "Dropbox/Dropbox.h"
#import "DBSession+MKT.h"

// Here we import the Dropbox credentials. You have to get your own to compile.
#import "ExternalData.h"

#ifndef kDROPBOX_APP_KEY
#define kDROPBOX_APP_KEY @"<YOUR CONSUMER KEY>"
#endif

#ifndef kDROPBOX_APP_SECRET
#define kDROPBOX_APP_SECRET @"<YOUR CONSUMER SECRET>"
#endif

#ifndef kTESTFLIGHTTOKEN
#define kTESTFLIGHTTOKEN @"<YOUR TOKEN>"
#endif

@interface MKTAppDelegate ()

@property(strong, nonatomic) UINavigationController *navigationController;
@property(strong, nonatomic) MGSplitViewController *splitViewController;

@end

/////////////////////////////////////////////////////////////////////////////////

@implementation MKTAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#ifdef CYDIA
//  [[BWQuincyManager sharedQuincyManager] setSubmissionURL:@"http://frankblumenberg.de/crashlog/crash_v200.php"];
#else
  
#ifdef TESTING
  #pragma message("Build for Testflightapp. Use Device UUID")
  [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif

  [TestFlight takeOff:kTESTFLIGHTTOKEN];

//  UninstallCrashHandlers(NO);
//  UninstallCrashHandlers(YES);

#endif
  
  [Crashlytics startWithAPIKey:kCRASHLYTICS_KEY];
    
  [[DDLog registeredClassNames] enumerateObjectsUsingBlock:^(NSString *class, NSUInteger i, BOOL *stop) {
    NSLog(@"Set log level for class %@",class);
    [DDLog setLogLevel:LOG_LEVEL_VERBOSE forClassWithName:class];
  }];
  
  [DDLog addLogger:[DDTTYLogger sharedInstance]];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

  // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    MKTMainMenuController *routesViewControler = [[MKTMainMenuController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:routesViewControler];
    self.window.rootViewController = self.navigationController;
  }
  else {

    MKTMainMenuController *routesViewControler = [[MKTMainMenuController alloc] init];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:routesViewControler];

    MKTDetailViewController *detailViewController = [[MKTDetailViewController alloc] initWithNibName:@"MKTDetailViewController_iPad" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

    self.splitViewController = [[MGSplitViewController alloc] init];
    self.splitViewController.showsMasterInPortrait=YES;
    self.splitViewController.showsMasterInLandscape=YES;
    
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];

    self.window.rootViewController = self.splitViewController;
  }

  [self.window makeKeyAndVisible];

  NSUndoManager* contextUndoManager = [NSUndoManager new];
  contextUndoManager.levelsOfUndo = 20;
                                       
  [CoreDataStore mainStore].context.undoManager = contextUndoManager;
  
  
  // Load the default values for the user defaults
  NSString *pathToUserDefaultsValues = [[NSBundle mainBundle]
                                        pathForResource:@"userDefaults"
                                        ofType:@"plist"];
  NSDictionary *userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:pathToUserDefaultsValues];
  
  // Set them in the standard user defaults
  [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValues];

  
  // Initialize the Dropbox support
  // Set these variables before launching the app
  NSString *appKey = kDROPBOX_APP_KEY;
  NSString *appSecret = kDROPBOX_APP_SECRET;

  DBAccountManager *accountManager =
  [[DBAccountManager alloc] initWithAppKey:appKey secret:appSecret];
	[DBAccountManager setSharedManager:accountManager];

	DBAccount *account = [DBAccountManager sharedManager].linkedAccount;
	if (account) {
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];
  }
  
  return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
	if (account) {
    
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMKTDropboxResponseNotification object:self];
    return YES;
  }

  return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [MBProgressHUD hideAllHUDsForView:self.window animated:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [[CoreDataStore mainStore] save];

  [[MKConnectionController sharedMKConnectionController] stop];
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    ((UINavigationController *) [self.splitViewController masterViewController]).delegate = nil;
    ((UINavigationController *) [self.splitViewController detailViewController]).delegate = nil;
    
    [((UINavigationController *) [self.splitViewController masterViewController]) popToRootViewControllerAnimated:NO];
    [((UINavigationController *) [self.splitViewController detailViewController]) popToRootViewControllerAnimated:NO];
  }
  else {
    self.navigationController.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:NO];
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [[CoreDataStore mainStore] save];
}

@end
