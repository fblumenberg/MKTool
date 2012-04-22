//
//  YKUISwitch.h
//  YelpKit
//
//  Created by Gabriel Handford on 3/1/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

@protocol YKUISwitch <NSObject>
- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (BOOL)isOn;
@end


@protocol YKUISwitchCustom
- (void)setOnText:(NSString *)onText;
- (void)setOffText:(NSString *)offText;
@end