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

#import "DropboxSDK/DropboxSDK.h"

// Here we import the Dropbox credentials. You have to get your own to compile.
#import "ExternalData.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#ifndef kDROPBOX_APP_KEY
#define kDROPBOX_APP_KEY @"<YOUR CONSUMER KEY>"
#endif

#ifndef kDROPBOX_APP_SECRET
#define kDROPBOX_APP_SECRET @"<YOUR CONSUMER SECRET>"
#endif


@interface MKTTestAppDelegate () <DBSessionDelegate>

@end


@implementation MKTTestAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[DDLog registeredClassNames] enumerateObjectsUsingBlock:^(NSString *class, NSUInteger i, BOOL *stop) {
    [DDLog setLogLevel:LOG_LEVEL_VERBOSE forClassWithName:class];
  }];

  [DDLog addLogger:[DDTTYLogger sharedInstance]];

  [super applicationDidFinishLaunching:application];

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

#pragma mark - DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
  [[DBSession sharedSession] linkUserId:userId];
}


@end
