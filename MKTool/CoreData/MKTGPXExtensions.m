//
//  MKTGPXExtensions.m
//  MKTool
//
//  Created by Frank Blumenberg on 09.05.13.
//
//

#import "MKTGPXExtensions.h"
#import "GPXElementSubclass.h"
#import "NSDictionary+BlocksKit.h"

@implementation MKTGPXExtensions

+ (MKTGPXExtensions *)extensionsWithDictionary:(NSDictionary *)dictionary{
  return [[MKTGPXExtensions alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary{

  self = [super init];
  if (self) {
    _dictionary=dictionary;
  }
  return self;
}

#pragma mark - tag

+ (NSString *)tagName
{
  return @"extensions";
}

#pragma mark - GPX

- (void)addChildTagToGpx:(NSMutableString *)gpx indentationLevel:(NSInteger)indentationLevel {
  
  [super addChildTagToGpx:gpx indentationLevel:indentationLevel];
  
  [self.dictionary each:^(id key, id obj){
    [self gpx:gpx addPropertyForValue:[obj description] tagName:key indentationLevel:indentationLevel];
  }];
}


@end
