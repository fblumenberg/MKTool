//
//  MKTConnection+MKTConnection_MKConnection.m
//  MKTool
//
//  Created by Frank Blumenberg on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKConnection.h"
#import "MKTConnection+MKConnection.h"

@implementation MKTConnection (MKTConnection_MKConnection)

- (NSDictionary *)asDictionary {

  return [NSDictionary dictionaryWithObjectsAndKeys:self.name, kKConnectionInfoName,
                                                    self.address, kKConnectionInfoAddress,
                                                    self.connectionClass, kKConnectionInfoConnectionClass,
                                                    self.connectionData, kKConnectionInfoExtra,
                                                    nil];
}

@end
