//
//  UIButton+UIButton_Images.h
//  MKTool
//
//  Created by mtg on 04.05.12.
//  Copyright (c) 2012 media Tranfer AG. All rights reserved.
//

typedef enum {
	MKTButtonTypeWhite,
	MKTButtonTypeGrey,
  MKTButtonTypeDarkGrey,
  MKTButtonTypeBlack,
	MKTButtonTypeBlue,
	MKTButtonTypeGreen,
	MKTButtonTypeOrange,
	MKTButtonTypeTan
} MKTButtonType;
  
@interface UIButton (Images)

- (void)mkt_setType:(MKTButtonType)type;

@end
