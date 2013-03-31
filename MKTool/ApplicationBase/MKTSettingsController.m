//
//  MKTSettingsController.m
//  MKTool
//
//  Created by Frank Blumenberg on 12.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Dropbox/Dropbox.h"

#import "MKTSettingsController.h"
#import "IASKAppSettingsViewController.h"
#import "IASKSpecifier.h"

#import "InnerBand.h"

@interface MKTSettingsController ()<IASKSettingsDelegate>

@end

@implementation MKTSettingsController

+ (MKTSettingsController *)sharedController {
  
  static dispatch_once_t once;
  static MKTSettingsController *sharedMKTRouteDropboxController__ = nil;
  
  dispatch_once(&once, ^{
    sharedMKTRouteDropboxController__ = [[MKTSettingsController alloc] init];
  });
  
  return sharedMKTRouteDropboxController__;
  
}

- (void)showFromController:(UIViewController *)viewController{
  IASKAppSettingsViewController* controller = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
  UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:controller];
  controller.title=NSLocalizedString(@"Settings", @"Settings Dialog title");
  controller.showDoneButton = YES;
  //  controller.file = @"waypoints";
  controller.delegate = self;
  
  if (IS_IPAD()) {
    aNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController presentModalViewController:aNavController animated:YES];
  }
  else
    [viewController presentModalViewController:aNavController animated:YES];
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender{
  [sender dismissModalViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"MKTDropbox"] ||
      [[specifier key] isEqualToString:@"MKTVersion"]) {
		return 44;
	}
	return 0;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:specifier.key];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:specifier.key];
  }

  if ([specifier.key isEqualToString:@"MKTDropbox"] ){
    
    BOOL dbAccountLinked = [[DBAccountManager sharedManager] linkedAccount] != nil;
    cell.textLabel.text = NSLocalizedString(@"Unlink from Dropbbox",@"");
    cell.contentView.userInteractionEnabled = dbAccountLinked;
    
    cell.selectionStyle = dbAccountLinked?UITableViewCellSelectionStyleBlue:UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = dbAccountLinked?[UIColor darkTextColor]:[UIColor grayColor];
    [cell setNeedsLayout];
  }
  
  if ([[specifier key] isEqualToString:@"MKTVersion"]) {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    NSString *extra=@"";
#ifdef CYDIA
    extra = @"(CYDIA)";
#endif
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@%@, Version %@ (%@)",nil),appDisplayName,extra,majorVersion, minorVersion];
    
    [cell setUserInteractionEnabled:NO];
  }

  return cell;
}

- (void)settingsViewController:(IASKAppSettingsViewController *)sender tableView:(UITableView *)tableView didSelectCustomViewSpecifier:(IASKSpecifier *)specifier{
  BOOL dbAccountLinked = [[DBAccountManager sharedManager] linkedAccount] != nil;

	if ([specifier.key isEqualToString:@"MKTDropbox"] && dbAccountLinked) {
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    [tableView reloadData];
  }
}

@end
