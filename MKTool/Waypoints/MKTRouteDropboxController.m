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

#import "DropboxSDK/DropboxSDK.h"
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
@interface MKTRouteDropboxController (DDRegisteredDynamicLogging)<DDRegisteredDynamicLogging> @end
@implementation MKTRouteDropboxController (DDRegisteredDynamicLogging)
+ (int)ddLogLevel{return ddLogLevel;}
+ (void)ddSetLogLevel:(int)logLevel{ddLogLevel = logLevel;}
@end
///////////////////////////////////////////////////////////////////////////////

@interface MKTRouteDropboxController () <DBRestClientDelegate>{

  MKTRouteDropboxSyncOption currentSyncOption;
  NSUInteger numberOfItemsToSync;
  NSUInteger numberOfItemsComplete;
}

@property(readonly) DBRestClient* restClient;
@property(strong) DBMetadata* dataPathMeta;
@property(strong) MKTRouteSyncModel* syncModel;

- (void)startSynchronization;

- (void)uploadRoute:(MKTRoute*)route;
- (void)downloadRoute:(DBMetadata*)metaData;
- (void)deleteLocalRoute:(MKTRoute*)route;
- (void)deleteRemoteRoute:(DBMetadata*)metaData;

- (void)metaDataReady;

@end

@implementation MKTRouteDropboxController

@synthesize delegate;
@synthesize isSyncing=_isSyncing;
@synthesize progessPercent=_progessPercent;

@synthesize dataPath=_dataPath;
@synthesize dataPathMeta=_dataPathMeta;
@synthesize restClient=_restClient;

@synthesize syncModel=_syncModel;

#pragma mark - 

- (DBRestClient *)restClient {
  if (_restClient == nil) {
    _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    _restClient.delegate = self;
  }
  
  return _restClient;
}

- (BOOL)isReady {
  return (self.dataPathMeta!=nil);
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
    self.dataPath = [@"/" stringByAppendingPathComponent:kRouteDataPath];
    self.syncModel = [[MKTRouteSyncModel alloc] initWithRoutes:nil metaData:nil];
  }
  return self;
}


- (void)connectAndPrepareMetadataFromController:(UIViewController*)controller {
  
  if (![[DBSession sharedSession] isLinked]) {
    DDLogInfo(@"The app has no login for the DropBox, start App/Browser");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbUrlCalled:) name:kMKTDropboxResponseNotification object:nil];
    [[DBSession sharedSession] linkFromController:controller];
    [self.delegate controllerPausedInit:self];
  }
  else {
    DDLogVerbose(@"Try to get the Metadata for our datapath %@",self.dataPath);
    [self.restClient loadMetadata:self.dataPath withHash:[self.dataPathMeta hash]];
  }
}

- (void) dbUrlCalled:(NSNotification*)n{
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  if(![[DBSession sharedSession] isLinked]){
    DDLogInfo(@"The app has no login for the DropBox, login failed, show error");
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Login failed", @"Sync Error") forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:@"MKTool" code:1001 userInfo:userInfo];
    [self.delegate controller:self dropboxInitFailedWithError:error];
  }
  else{
    [self.delegate controllerRestartedInit:self];
    DDLogVerbose(@"Try to get the Metadata for our datapath %@",self.dataPath);
    [self.restClient loadMetadata:self.dataPath withHash:[self.dataPathMeta hash]];
  }
}


- (void)sendSyncStateError {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Synchronisation failed", @"Sync Error") forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:@"MKTool" code:1000 userInfo:userInfo];
    [self.delegate controller:self syncFailedWithError:error];
}

- (void)syncronizeRoute:(MKTRoute*)route fromController:(UIViewController *)controller{
  [self syncronizeRoute:route withOption:MKTRouteDropboxSyncOverrideOlder fromController:controller];
}

- (void)syncronizeRoute:(MKTRoute*)route withOption:(MKTRouteDropboxSyncOption)option fromController:(UIViewController *)controller{
  if(self.isSyncing){
    [self sendSyncStateError];
    return;
  }

  _isSyncing = YES;
  currentSyncOption = option;
  self.syncModel.routes = [NSArray arrayWithObject:route];
  [self connectAndPrepareMetadataFromController:controller];
}

- (void)syncronizeAllRoutesFromController:(UIViewController *)controller{
  [self syncronizeAllRoutesWithOption:MKTRouteDropboxSyncOverrideOlder fromController:controller];
}

- (void)syncronizeAllRoutesWithOption:(MKTRouteDropboxSyncOption)option fromController:(UIViewController *)controller{

  if(self.isSyncing){
    [self sendSyncStateError];
    return;
  }

  _isSyncing = YES;
  currentSyncOption = option;
  self.syncModel.routes = [MKTRoute all];
  [self connectAndPrepareMetadataFromController:controller];
}


- (void)startSynchronization{
  if(self.syncModel.itemsForUpload.count==0 && 
     self.syncModel.itemsForDownload.count==0 && 
     self.syncModel.itemsForDelete.count==0){
    DDLogInfo(@"Nothing to synchronize");
    _isSyncing = NO;
    [self.delegate controllerSyncCompleted:self];
  }
  else {
    
    numberOfItemsComplete++;
    if([self.delegate respondsToSelector:@selector(controller:syncProgress:)])
      [self.delegate controller:self syncProgress:((CGFloat)numberOfItemsComplete/(CGFloat)numberOfItemsToSync)];
    
    
    if(self.syncModel.itemsForUpload.count>0){
      MKTRoute* r = [[self.syncModel.itemsForUpload firstObject] route];
      [self uploadRoute:r];
    }
    else if(self.syncModel.itemsForDownload.count>0){
      DBMetadata* metaData = [[self.syncModel.itemsForDownload shiftObject] metaData];
      [self downloadRoute:metaData];
    }
    else if(self.syncModel.itemsForDelete.count>0){
      MKTSyncItem* item = [self.syncModel.itemsForDelete shiftObject];
      if(item.route)
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

- (void)uploadRoute:(MKTRoute*)route{
 
  DDLogVerbose(@"Will start to upload the route %@",route.fileName);

  NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:route.fileName];
  [route writeRouteToWplFile:localPath];
  
  [self.restClient uploadFile:route.fileName toPath:self.dataPath withParentRev:route.parentRev fromPath:localPath];
}

- (void)downloadRoute:(DBMetadata*)metaData{
  DDLogVerbose(@"Will start to download the route %@",metaData.filename);

  NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:metaData.filename];
  [self.restClient loadFile:metaData.path intoPath:localPath];
}

- (void)deleteLocalRoute:(MKTRoute*)route{
  DDLogVerbose(@"Will delete the local route %@",route.fileName);
  [route destroy];
  [self startSynchronization];
}

- (void)deleteRemoteRoute:(DBMetadata*)metaData{
  DDLogVerbose(@"Will delete the remote route %@",metaData.filename);
  [self.restClient deletePath:metaData.path];  
}


////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)metaDataReady{
  if(self.isSyncing){
    self.syncModel.metaData = self.dataPathMeta.contents;
    [self.syncModel prepareForSynchWithOption:currentSyncOption];
    
    numberOfItemsToSync =  
    self.syncModel.itemsForUpload.count +
    self.syncModel.itemsForDownload.count +
    self.syncModel.itemsForDelete.count;

    numberOfItemsComplete = 0;
    
    [self startSynchronization];
  }
  else
    [self.delegate dropboxReady:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - DBRestClientDelegate methods

- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder {
  
  if ([folder.path isEqualToDropboxPath:self.dataPath]) {
    self.dataPathMeta = folder;
    [self metaDataReady];
  }
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error {
  if(self.isSyncing)
    [self.delegate controller:self syncFailedWithError:error];
  else
    [self.delegate controller:self dropboxInitFailedWithError:error];
}

//------------------------------------------------------------------------------------------------------

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)newMetadata {
  if ([newMetadata.path isEqualToDropboxPath:self.dataPath]) {
    self.dataPathMeta = newMetadata;
    if(newMetadata.isDeleted){
      DDLogInfo(@"The Dropbox data path %@ for the routes is not there, create one",self.dataPath);
      [self.restClient createFolder:self.dataPath];
    }
    else
      [self metaDataReady];
  }
}

- (void)restClient:(DBRestClient *)client metadataUnchangedAtPath:(NSString *)path {
  [self metaDataReady];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
  
  NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
  
  if ([error code] == 404) {
    DDLogInfo(@"The Dropbox data path %@ for the routes is not there, create one",self.dataPath);
    [self.restClient createFolder:self.dataPath];
  }
  else {
    DDLogWarn(@"The Dropbox loadMetadataFailedWithError %@",error);
    if(self.isSyncing)
      [self.delegate controller:self syncFailedWithError:error];
    else
      [self.delegate controller:self dropboxInitFailedWithError:error];
  }
}

//------------------------------------------------------------------------------------------------------

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata{
  
  MKTRoute* route = [[self.syncModel.itemsForUpload shiftObject] route];
  NSAssert([srcPath hasSuffix:route.fileName],@"Inconsitent file names for route sync");

  DDLogVerbose(@"Uploaded route %@ to file %@",route,destPath);
  route.parentRev = metadata.rev;
  route.lastUpdated = [NSDate distantPast]; //we need a definite change for last update 
  [[CoreDataStore mainStore] save];

  route.lastUpdated = metadata.lastModifiedDate;
  DDLogVerbose(@"Set rev:%@ date:%@",metadata.rev,metadata.lastModifiedDate);
  [[CoreDataStore mainStore] save];
  
  [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
  
  [self startSynchronization];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error{
  DDLogCError(@"The Dropbox upload failed with error %@",error);
  _isSyncing = NO;
  [self.delegate controller:self syncFailedWithError:error];
}

- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath{
  NSLog(@"########################## %f",progress);
}

//------------------------------------------------------------------------------------------------------

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata{
  MKTRoute* route = [[MKTRoute allForPredicate:[NSPredicate predicateWithFormat:@"fileName=%@", metadata.filename]]firstObject];
  
  if(!route){
    route = [MKTRoute create];
  }
  
  if([route loadRouteFromWplFile:destPath]){
    DDLogVerbose(@"Loaded route %@ from file %@",route,destPath);
    route.parentRev = metadata.rev;
    route.lastUpdated = [NSDate distantPast]; //we need a definite change for last update 
    [[CoreDataStore mainStore] save];
    
    route.lastUpdated = metadata.lastModifiedDate;
    DDLogVerbose(@"Set rev:%@ date:%@",metadata.rev,metadata.lastModifiedDate);
    
    [[CoreDataStore mainStore] save];
  }
  else {
    DDLogWarn(@"Faile to load the roure %@ from file %@",route,destPath);
    [[CoreDataStore mainStore].context rollback];
  }
  
  [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
  
  [self startSynchronization];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error{
  DDLogCError(@"The Dropbox load failed with error %@",error);
  _isSyncing = NO;
  [self.delegate controller:self syncFailedWithError:error];
}

//------------------------------------------------------------------------------------------------------

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
  [self startSynchronization];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
  DDLogCError(@"The Dropbox load failed with error %@",error);
  _isSyncing = NO;
  [self.delegate controller:self syncFailedWithError:error];
}

+ (void)showError:(NSError *)error withTitle:(NSString *)title {
  
  NSString *message;
  if ([error.domain isEqual:NSURLErrorDomain]) {
    message = NSLocalizedString(@"There was an error connecting to Dropbox.", @"DB Login Err Msg");
  } else {
    NSObject *errorResponse = [[error userInfo] objectForKey:@"error"];
    if ([errorResponse isKindOfClass:[NSString class]]) {
      message = [[NSBundle mainBundle] localizedStringForKey:(NSString *) errorResponse value:@"" table:nil];
    } else if ([errorResponse isKindOfClass:[NSDictionary class]]) {
      NSDictionary *errorDict = (NSDictionary *) errorResponse;
      message = [[NSBundle mainBundle] localizedStringForKey:([errorDict objectForKey:[[errorDict allKeys] objectAtIndex:0]]) value:@"" table:nil];
    } else {
      message = NSLocalizedString(@"An unknown error has occurred.", @"DB Login Err Unknown Msg");
    }
  }
  
  [[[UIAlertView alloc] initWithTitle:title 
                              message:message 
                             delegate:nil 
                    cancelButtonTitle:@"OK" 
                    otherButtonTitles:nil] show];
}

@end
