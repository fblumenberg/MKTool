// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
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

#import "DDLog.h"

#import "InnerBand.h"
#import "NSArray+BlocksKit.h"
#import "NSSet+BlocksKit.h"


#import "INIParser.h"

#import "MKTRouteDropboxController.h"
#import "MKTRoute.h"
#import "MKTRoute+WPL.h"

#define kRouteDataPath @"RouteData"

#import "MKTRouteSyncModel.h"

///////////////////////////////////////////////////////////////////////////////
#pragma mark - DDRegisteredDynamicLogging
static int ddLogLevel = LOG_LEVEL_WARN;

@interface MKTRouteDropboxController (DDRegisteredDynamicLogging) <DDRegisteredDynamicLogging>
@end

@implementation MKTRouteDropboxController (DDRegisteredDynamicLogging)
+ (int)ddLogLevel {
  return ddLogLevel;
}

+ (void)ddSetLogLevel:(int)logLevel {
  ddLogLevel = logLevel;
}
@end
///////////////////////////////////////////////////////////////////////////////

@interface MKTRouteDropboxController () {

  MKTRouteDropboxSyncOption currentSyncOption;
  NSUInteger numberOfItemsToSync;
  NSUInteger numberOfItemsComplete;
}

@property(strong) MKTRouteSyncModel *syncModel;
@property(strong) NSArray *routesInDB;

- (void)startSynchronization;

- (void)uploadRoute:(MKTRoute *)route createFile:(BOOL)create;

- (void)downloadRoute:(DBFileInfo *)metaData;

- (void)deleteLocalRoute:(MKTRoute *)route;

- (void)deleteRemoteRoute:(DBFileInfo *)metaData;

@end

@implementation MKTRouteDropboxController

@synthesize delegate;
@synthesize isSyncing = _isSyncing;
@synthesize progessPercent = _progessPercent;

@synthesize syncModel = _syncModel;

#pragma mark - 

- (BOOL)isReady {
  return (self.routesInDB != nil);
}

#pragma mark - 


+ (MKTRouteDropboxController *)sharedController {

  static dispatch_once_t once;
  static MKTRouteDropboxController *sharedMKTRouteDropboxController__ = nil;

  dispatch_once(&once, ^{
    sharedMKTRouteDropboxController__ = [[MKTRouteDropboxController alloc] init];
  });

  return sharedMKTRouteDropboxController__;

}

- (id)init {

  self = [super init];
  if (self) {
    self.dataPath = [[DBPath root] childPath:kRouteDataPath];
    self.syncModel = [[MKTRouteSyncModel alloc] initWithRoutes:nil metaData:nil];
  }
  return self;
}


- (void)loadRouteFilesFromDropBox {
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

- (void)connectAndPrepareMetadataFromController:(UIViewController *)controller {

  self.routesInDB = nil;

  DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
  if (!account) {
    DDLogInfo(@"The app has no login for the DropBox, start App/Browser");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbUrlCalled:) name:kMKTDropboxResponseNotification object:nil];
    [[DBAccountManager sharedManager] linkFromController:controller];
    if ([self.delegate respondsToSelector:@selector(controllerPausedInit:)])
      [self.delegate controllerPausedInit:self];
  }
  else {
    [self loadRouteFilesFromDropBox];
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
    [self loadRouteFilesFromDropBox];
  }
}


- (void)sendSyncStateError {
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Synchronisation failed", @"Sync Error") forKey:@"error"];
  NSError *error = [NSError errorWithDomain:@"MKTool" code:1000 userInfo:userInfo];
  [self.delegate controller:self syncFailedWithError:error];
}

- (void)syncronizeRoute:(MKTRoute *)route fromController:(UIViewController *)controller {
  [self syncronizeRoute:route withOption:MKTRouteDropboxSyncOverrideOlder fromController:controller];
}

- (void)syncronizeRoute:(MKTRoute *)route withOption:(MKTRouteDropboxSyncOption)option fromController:(UIViewController *)controller {
  if (self.isSyncing) {
    [self sendSyncStateError];
    return;
  }

  _isSyncing = YES;
  currentSyncOption = option;
  self.syncModel.routes = [NSArray arrayWithObject:route];
  
  [self connectAndPrepareMetadataFromController:controller];
}

- (void)syncronizeAllRoutesFromController:(UIViewController *)controller {
  [self syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideOlder fromController:controller];
}

- (void)syncronizeAllRoutesWithOption:(MKTRouteDropboxSyncOption)option fromController:(UIViewController *)controller {

  if (self.isSyncing) {
    [self sendSyncStateError];
    return;
  }

  _isSyncing = YES;
  currentSyncOption = option;
  self.syncModel.routes = [MKTRoute all];
  self.syncModel.metaData = self.routesInDB;
  [self.syncModel prepareForSynchWithOption:currentSyncOption];
  
  numberOfItemsToSync =
  self.syncModel.itemsForUpload.count +
  self.syncModel.itemsForDownload.count +
  self.syncModel.itemsForDelete.count;
  
  numberOfItemsComplete = 0;
  
  [self startSynchronization];
}

- (void)startSynchronization {
  if (self.syncModel.itemsForUpload.count == 0 &&
          self.syncModel.itemsForDownload.count == 0 &&
          self.syncModel.itemsForDelete.count == 0) {
    DDLogInfo(@"Nothing to synchronize");
    _isSyncing = NO;
    [self.delegate controllerSyncCompleted:self];
  }
  else {

    numberOfItemsComplete++;
    if ([self.delegate respondsToSelector:@selector(controller:syncProgress:)])
      [self.delegate controller:self syncProgress:((CGFloat) numberOfItemsComplete / (CGFloat) numberOfItemsToSync)];


    if (self.syncModel.itemsForUpload.count > 0) {
      MKTSyncItem *item = [self.syncModel.itemsForUpload shiftObject];
      [self uploadRoute:item.route createFile:(item.metaData==nil)];
    }
    else if (self.syncModel.itemsForDownload.count > 0) {
      DBFileInfo *fileInfo = [[self.syncModel.itemsForDownload shiftObject] metaData];
      [self downloadRoute:fileInfo];
    }
    else if (self.syncModel.itemsForDelete.count > 0) {
      MKTSyncItem *item = [self.syncModel.itemsForDelete shiftObject];
      if (item.route)
        [self deleteLocalRoute:item.route];
      else
        [self deleteRemoteRoute:item.metaData];
    }
    else {
      DDLogInfo(@"Synchronize complete");
      _isSyncing = NO;
      [self.delegate controllerSyncCompleted:self];
    }
  }
}

- (void)uploadRoute:(MKTRoute *)route createFile:(BOOL)create {

  DDLogVerbose(@"Will start to upload the route %@ create file %d", route.fileName,create);

//  DDLogVerbose(@"Uploaded route %@ to file %@",route,destPath);
//  route.parentRev = metadata.rev;
//  route.lastUpdated = [NSDate distantPast]; //we need a definite change for last update
//  [[CoreDataStore mainStore] save];
  
  NSError* error=nil;
  DBFile* dbFile;
  if(create){
    dbFile = [[DBFilesystem sharedFilesystem] createFile:[self.dataPath childPath:route.fileName] error:&error];
  }
  else{
    dbFile = [[DBFilesystem sharedFilesystem] openFile:[self.dataPath childPath:route.fileName] error:&error];
  }
  
  if(dbFile){
    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:route.fileName];
    [route writeRouteToWplFile:localPath];
    
    [dbFile writeContentsOfFile:localPath shouldSteal:YES error:nil];
    
    route.lastUpdated = [NSDate distantPast]; //we need a definite change for last update
    [[CoreDataStore mainStore] save];
    
    route.lastUpdated = dbFile.info.modifiedTime;
    DDLogVerbose(@"Set date:%@",dbFile.info.modifiedTime);
    
    [[CoreDataStore mainStore] save];

    [dbFile close];

    [self performSelector:@selector(startSynchronization) withObject:self afterDelay:0.5];
  }
  else{
    DDLogCError(@"The Dropbox upload failed with error %@",error);
    _isSyncing = NO;
    [self.delegate controller:self syncFailedWithError:error];
  }
  
}

- (void)processDownloadedRouteData:(NSString *)data metaData:(DBFileInfo *)metaData error:(NSError *)error {
  if(data){
    MKTRoute* route = [[MKTRoute allForPredicate:[NSPredicate predicateWithFormat:@"fileName=%@", metaData.path.name]]firstObject];
    
    if(!route){
      route = [MKTRoute create];
    }
    
    if([route loadRouteFromWplString:data withFilename:metaData.path.name]){
      
      DDLogVerbose(@"Loaded route %@ from file %@",route,metaData.path.name);
      route.lastUpdated = [NSDate distantPast]; //we need a definite change for last update
      [[CoreDataStore mainStore] save];
      
      route.lastUpdated = metaData.modifiedTime;
      DDLogVerbose(@"Set date:%@",metaData.modifiedTime);
      
      [[CoreDataStore mainStore] save];
    }
    else {
      DDLogWarn(@"Faile to load the route %@ from file %@",route,metaData.path.name);
      [[CoreDataStore mainStore].context rollback];
    }
    [self performSelector:@selector(startSynchronization) withObject:self afterDelay:0.5];
  }
  else{
    DDLogCError(@"The Dropbox download failed with error %@",error);
    _isSyncing = NO;
    [self.delegate controller:self syncFailedWithError:error];
  }
}

- (void)processDownloadedRouteFile:(DBFile *)dbFile metaData:(DBFileInfo *)metaData {
  
  
  DBFileStatus *status = dbFile.status;
  if (!status.cached) {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
      
      NSError* error=nil;

      NSString* data =[dbFile readString:&error];
      [dbFile close];

      dispatch_async(dispatch_get_main_queue(), ^() {
        [self processDownloadedRouteData:data metaData:metaData error:error];
      });
    });

  }
  else{
    NSError* error=nil;
    NSString* data =[dbFile readString:&error];
    [dbFile close];
    [self processDownloadedRouteData:data metaData:metaData error:error];
  }
}

- (void)downloadRoute:(DBFileInfo *)metaData {
  DDLogVerbose(@"Will start to download the route %@", metaData.path.name);

  NSError* error=nil;
  DBFile* dbFile = [[DBFilesystem sharedFilesystem] openFile:metaData.path error:&error];
  
  if(dbFile){
    [self processDownloadedRouteFile:dbFile metaData:metaData];
  }
  else{
    DDLogError(@"The Dropbox download failed with error %@",error);
    _isSyncing = NO;
    [self.delegate controller:self syncFailedWithError:error];
  }
}

- (void)deleteLocalRoute:(MKTRoute *)route {
  DDLogVerbose(@"Will delete the local route %@", route.fileName);
  [route destroy];
  [self startSynchronization];
}

- (void)deleteRemoteRoute:(DBFileInfo *)metaData {
  DDLogVerbose(@"Will delete the remote route %@", metaData.path.name);
  
  NSError* error=nil;
  
  if([[DBFilesystem sharedFilesystem] deletePath:metaData.path error:&error]){
    [self performSelector:@selector(startSynchronization) withObject:self afterDelay:0.5];
  }
  else{
    DDLogCError(@"The Dropbox delete failed with error %@",error);
    _isSyncing = NO;
    [self.delegate controller:self syncFailedWithError:error];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////

+ (void)showError:(NSError *)error withTitle:(NSString *)title {

  NSString *message;
  if ([error.domain isEqual:NSURLErrorDomain]) {
    message = NSLocalizedString(@"There was an error connecting to Dropbox.", @"DB Login Err Msg");
  }
  else {
    NSObject *errorResponse = [[error userInfo] objectForKey:@"error"];
    if ([errorResponse isKindOfClass:[NSString class]]) {
      message = [[NSBundle mainBundle] localizedStringForKey:(NSString *) errorResponse value:@"" table:nil];
    }
    else if ([errorResponse isKindOfClass:[NSDictionary class]]) {
      NSDictionary *errorDict = (NSDictionary *) errorResponse;
      message = [[NSBundle mainBundle] localizedStringForKey:([errorDict objectForKey:[[errorDict allKeys] objectAtIndex:0]]) value:@"" table:nil];
    }
    else {
      message = NSLocalizedString(@"An unknown error has occurred.", @"DB Login Err Unknown Msg");
    }
  }

  [[[UIAlertView alloc] initWithTitle:title
                              message:message
                             delegate:nil cancelButtonTitle:@"OK"
                    otherButtonTitles:nil] show];
}

@end
