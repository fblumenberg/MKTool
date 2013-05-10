//
//  MKTGPXExtensions.h
//  MKTool
//
//  Created by Frank Blumenberg on 09.05.13.
//
//

#import "GPX.h"

@interface MKTGPXExtensions : GPXExtensions

+ (MKTGPXExtensions *)extensionsWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property(strong) NSDictionary* dictionary;

@end
