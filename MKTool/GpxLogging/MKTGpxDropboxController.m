// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013, Frank Blumenberg
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

#import "Dropbox/Dropbox.h"
#import "DBSession+MKT.h"

#import "NSArray+BlocksKit.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "MKTGpxDropboxController.h"

#import "MKTGpxSession.h"
#import "MKTGpxSession+GPX.h"

#define kGpxDataPath @"Gpx"

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface MKTGpxDropboxController (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation MKTGpxDropboxController (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end
///////////////////////////////////////////////////////////////////////////////

@interface MKTGpxDropboxController ()

@property(strong) NSArray *routesInDB;

@end

///////////////////////////////////////////////////////////////////////////////

@implementation MKTGpxDropboxController

- (id)init {
  
  self = [super init];
  if (self) {
    self.dataPath = [[DBPath root] childPath:kGpxDataPath];
  }
  return self;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadGpxFilesFromDropBox {
  DDLogVerbose(@"Try to get the content for our datapath %@", self.dataPath);
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
    
    NSError *error = nil;
    
    if([[DBFilesystem sharedFilesystem] createFolder:self.dataPath error:&error]){
      self.routesInDB = [[DBFilesystem sharedFilesystem] listFolder:self.dataPath error:&error];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
      if (self.routesInDB) {
        [self.delegate dropboxReady:self];
      }
      else {
        [self.delegate controller:self dropboxInitFailedWithError:error];
      }
    });
  });
}


- (void)connectAndPrepareFromController:(UIViewController *)controller {
  
  DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
  if (!account) {
    DDLogInfo(@"The app has no login for the DropBox, start App/Browser");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbUrlCalled:) name:kMKTDropboxResponseNotification object:nil];
    [[DBAccountManager sharedManager] linkFromController:controller];
    if ([self.delegate respondsToSelector:@selector(controllerPausedInit:)])
      [self.delegate controllerPausedInit:self];
  }
  else {
    [self loadGpxFilesFromDropBox];
  }
}

- (void)dbUrlCalled:(NSNotification *)n {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
  if (!account) {
    DDLogInfo(@"The app has no login for the DropBox, login failed, show error");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Login failed", @"Sync Error") forKey:@"error"];
    NSError *error = [NSError errorWithDomain:@"MKTool" code:1001 userInfo:userInfo];
    [self.delegate controller:self dropboxInitFailedWithError:error];
  }
  else {
    if ([self.delegate respondsToSelector:@selector(controllerRestartedInit:)])
      [self.delegate controllerRestartedInit:self];
    
    [self loadGpxFilesFromDropBox];
  }
}


- (void)syncronizeSession:(MKTGpxSession*)session fromController:(UIViewController*)controller{
  [self syncronizeSessions:@[session] fromController:controller];
}

- (void)syncronizeSessions:(NSArray*)sessions fromController:(UIViewController*)controller{
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {

    BOOL ok=YES;
    DBError* error=nil;
    
    for (MKTGpxSession* session in sessions) {
      ok=[self writeGpxFileForSession:session error:&error];
      if(!ok)
        break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
      if (ok) {
        [self.delegate controllerSyncCompleted:self];
      }
      else {
        [self.delegate controller:self syncFailedWithError:error];
      }
    });
  });
}


-(BOOL) writeGpxFileForSession:(MKTGpxSession*)session error:(DBError **)error{
  
  DBFileInfo *data = [self.routesInDB bk_match:^(DBFileInfo *obj) {
    return [session.fileName isEqualToString:obj.path.name];
  }];

  
  DBFile* dbFile;
  if(data){
    DDLogVerbose(@"Open DB file %@",session.fileName);
    dbFile = [[DBFilesystem sharedFilesystem] openFile:[self.dataPath childPath:session.fileName] error:error];
  }
  else{
    DDLogVerbose(@"Create DB file %@",session.fileName);
    dbFile = [[DBFilesystem sharedFilesystem] createFile:[self.dataPath childPath:session.fileName] error:error];
  }
  
  BOOL writeOk = NO;
  if(dbFile){
    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:session.fileName];
    [session writeSessionToGPXFile:localPath];
    
    DDLogVerbose(@"Written temp file %@",localPath);
    
    writeOk = [dbFile writeContentsOfFile:localPath shouldSteal:YES error:error];
    [dbFile close];
  }
  
  return writeOk;
}

///////////////////////////////////////////////////////////////////////////////////
+ (void)showError:(NSError *)error withTitle:(NSString *)title{
  
}


@end
