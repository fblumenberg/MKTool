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
#import <Foundation/Foundation.h>

@class DBPath;
@class MKTGpxSession;
@protocol MKTGpxDropboxControllerDelegate;

@interface MKTGpxDropboxController : NSObject

+ (void)showError:(NSError *)error withTitle:(NSString *)title;

- (void)connectAndPrepareFromController:(UIViewController*)controller;

- (void)syncronizeSession:(MKTGpxSession*)session fromController:(UIViewController*)controller;
- (void)syncronizeSessions:(NSArray*)sessions fromController:(UIViewController*)controller;


@property(strong) DBPath* dataPath;

@property(readonly) BOOL isSyncing;
@property(readonly) BOOL isReady;

@property(nonatomic, weak) id<MKTGpxDropboxControllerDelegate> delegate;

@end

@protocol MKTGpxDropboxControllerDelegate <NSObject>

- (void)dropboxReady:(MKTGpxDropboxController*)controller;
- (void)controller:(MKTGpxDropboxController*)crontroller dropboxInitFailedWithError:(NSError*)error;

- (void)controller:(MKTGpxDropboxController*)crontroller syncFailedWithError:(NSError*)error;
- (void)controllerSyncCompleted:(MKTGpxDropboxController*)crontroller;

@optional

- (void)controllerPausedInit:(MKTGpxDropboxController*)crontroller;
- (void)controllerRestartedInit:(MKTGpxDropboxController*)crontroller;

@end