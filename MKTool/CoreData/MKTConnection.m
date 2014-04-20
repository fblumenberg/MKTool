// ///////////////////////////////////////////////////////////////////////////////
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
// ///////////////////////////////////////////////////////////////////////////////

#import "InnerBand.h"
#import "MKTConnection.h"

@implementation MKTConnection

- (UIImage *)cellImage {
  if ([self.connectionClass isEqualToString:@"MKIpConnection"])
    return [UIImage imageNamed:@"icon-wifi.png"];
  if ([self.connectionClass isEqualToString:@"MKSerialConnection"])
    return [UIImage imageNamed:@"icon-usb.png"];
  if ([self.connectionClass isEqualToString:@"MKBluetoothConnection"])
    return [UIImage imageNamed:@"icon-bluetooth.png"];
  if ([self.connectionClass isEqualToString:@"MKBleConnection"])
    return [UIImage imageNamed:@"icon-bluetooth.png"];

  return [UIImage imageNamed:@"icon-phone.png"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 
///////////////////////////////////////////////////////////////////////////////////////////////////

+ (NSFetchedResultsController *)fetchedResultsController {

  IBCoreDataStore *store = [IBCoreDataStore mainStore];

  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  fetchRequest.entity = [MKTConnection entityInManagedObjectContext:store.context];
  fetchRequest.fetchBatchSize = 20;

  // Edit the sort key as appropriate.
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
  fetchRequest.sortDescriptors = sortDescriptors;

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                              managedObjectContext:store.context
                                                                                                sectionNameKeyPath:nil cacheName:nil];
  return aFetchedResultsController;
}

+ (NSFetchedResultsController *)fetchedResultsControllerLastUsed {

  IBCoreDataStore *store = [IBCoreDataStore mainStore];

  // Create the fetch request for the entity.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  fetchRequest.entity = [MKTConnection entityInManagedObjectContext:store.context];
  fetchRequest.fetchBatchSize = 20;

  // Edit the sort key as appropriate.
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastUsed" ascending:YES]];
  fetchRequest.sortDescriptors = sortDescriptors;

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                              managedObjectContext:store.context
                                                                                                sectionNameKeyPath:nil cacheName:nil];
  return aFetchedResultsController;
}

@end
