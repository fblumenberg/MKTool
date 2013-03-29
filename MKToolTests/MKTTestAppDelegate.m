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

#import "MKTTestAppDelegate.h"
#import "GHUnit.h"

#import <Dropbox/Dropbox.h>

// Here we import the Dropbox credentials. You have to get your own to compile.
//#import "ExternalData.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#ifndef kDROPBOX_APP_KEY
#define kDROPBOX_APP_KEY @"te98jbc5b21851p"
#endif

#ifndef kDROPBOX_APP_SECRET
#define kDROPBOX_APP_SECRET @"ngqgi9dy7opc9w9"
#endif


@interface MKTTestAppDelegate ()

@end


@implementation MKTTestAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Load the default values for the user defaults
  NSString *pathToUserDefaultsValues = [[NSBundle mainBundle]
          pathForResource:@"userDefaults"
                   ofType:@"plist"];
  NSDictionary *userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:pathToUserDefaultsValues];
  // Set them in the standard user defaults
  [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValues];

  [[DDLog registeredClassNames] enumerateObjectsUsingBlock:^(NSString *class, NSUInteger i, BOOL *stop) {
    [DDLog setLogLevel:LOG_LEVEL_VERBOSE forClassWithName:class];
  }];

  [DDLog addLogger:[DDTTYLogger sharedInstance]];

  [super applicationDidFinishLaunching:application];

  // Initialize the Dropbox support
  // Set these variables before launching the app
  NSString *appKey = kDROPBOX_APP_KEY;
  NSString *appSecret = kDROPBOX_APP_SECRET;

  DBAccountManager *accountManager =
  [[DBAccountManager alloc] initWithAppKey:appKey secret:appSecret];
	[DBAccountManager setSharedManager:accountManager];

  return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
	if (account) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMKTDropboxResponseNotification object:self];
    return YES;
  }
  
  return NO;
}

@end
