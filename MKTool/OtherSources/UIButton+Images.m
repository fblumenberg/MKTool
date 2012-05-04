//
//  UIButton+UIButton_Images.m
//  MKTool
//
//  Created by mtg on 04.05.12.
//  Copyright (c) 2012 media Tranfer AG. All rights reserved.
//

#import "UIButton+Images.h"

@implementation UIButton (Images)

- (void)mkt_setType:(MKTButtonType)type{

  NSString* imageName;
  NSString* imageNameHightlight;

  switch (type) {
    case MKTButtonTypeWhite:
      imageName=@"whiteButton.png";
      imageNameHightlight=@"whiteButtonHighlight.png";
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeGrey:
      imageName=@"greyButton.png";
      imageNameHightlight=@"greyButtonHighlight.png";
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeDarkGrey:
      imageName=@"darkGreyButton.png";
      imageNameHightlight=@"darkGreyButtonHighlight.png";
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeBlack:
      imageName=@"blackButton.png";
      imageNameHightlight=@"blackButtonHighlight.png";
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeGreen:
      imageName=@"greenButton.png";
      imageNameHightlight=@"greenButtonHighlight.png";
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeBlue:
      imageName=@"blueButton.png";
      imageNameHightlight=@"blueButtonHighlight.png";
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeOrange:
      imageName=@"orangeButton.png";
      imageNameHightlight=@"orangeButtonHighlight.png";
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      break;
    case MKTButtonTypeTan:
      imageName=@"tanButton.png";
      imageNameHightlight=@"tanButtonHighlight.png";
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
      [self setTitleColor:[UIColor darkTextColor] forState:UIControlStateHighlighted];
      break;
  }

  UIImage* buttonImage = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:18 topCapHeight:18];
  UIImage* buttonImageHighlight = [[UIImage imageNamed:imageNameHightlight] stretchableImageWithLeftCapWidth:18 topCapHeight:18];
  
  [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
  [self setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

@end
