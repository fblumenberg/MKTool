//
//  YKUIActionSheet.h
//  YelpIPhone
//
//  Created by Gabriel Handford on 6/29/10.
//  Copyright 2010 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

/*! 
 Action sheet with target and actions associated with titles.
 Useful for conditional titles and not having to deal with a single delegate, and button index.
 
     YKUIActionSheet *actionSheet = [[YKUIActionSheet alloc] initWithTitle:nil target:self cancelButtonTitle:NSLocalizedString(@"Cancel") cancelAction:NULL
        destructiveButtonTitle:nil destructiveAction:NULL];
     
     if (...) [actionSheet addButtonWithTitle:NSLocalizedString(@"Use My Facebook Photo") action:@selector(_useFacebookProfilePhoto)];
     if (...) [actionSheet addButtonWithTitle:YKLocalizedString(@"TakePhoto") action:@selector(_takePhoto)];
     [actionSheet addButtonWithTitle:YKLocalizedString(@"ChooseExistingPhoto") action:@selector(_choosePhoto)];
     actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
     [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
     [actionSheet autorelease];

 */
@interface YKUIActionSheet : NSObject <UIActionSheetDelegate> {
  UIActionSheet *_actionSheet;
  UIActionSheetStyle _actionSheetStyle;
  
  NSString *_title;
  
  NSMutableArray *_titles;
  NSMutableArray *_actions;
  
  NSString *_cancelButtonTitle;
  NSValue *_cancelAction;
  NSString *_destructiveButtonTitle;
  NSValue *_destructiveAction;
  
  id _target; // weak
}

@property (assign, nonatomic) UIActionSheetStyle actionSheetStyle;

/*!
 Create action sheet.
 @param title
 @param target
 @param cancelButtonTitle
 @param cancelAction
 @param destructiveButtonTitle
 @param destructiveAction
 */
- (id)initWithTitle:(NSString *)title target:(id)target cancelButtonTitle:(NSString *)cancelButtonTitle cancelAction:(SEL)cancelAction destructiveButtonTitle:(NSString *)destructiveButtonTitle destructiveAction:(SEL)destructiveAction;

/*!
 Add button to action sheet.
 @param title
 @param action
 */
- (void)addButtonWithTitle:(NSString *)title action:(SEL)action;

/*!
 Show action sheet from toolbar.
 @param view Source view
 */
- (void)showFromToolbar:(UIToolbar *)view;

/*!
 Show action sheet from tab bar.
 @param view Source view
 */
- (void)showFromTabBar:(UITabBar *)view;

/*!
 Show action sheet from view.
 @param view Source view
 */
- (void)showInView:(UIView *)view;

/*!
 Show action sheet from bar button item.
 @param item
 @param animated
 
 Available in iOS3.2 and later.
 */
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

/*!
 Show action sheet in rect.
 @param rect
 @param view
 @param animated
 
 Available in iOS3.2 and later.
 */
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

/*!
 Dismiss sheet as if the buttonIndex was pressed.
 @param buttonIndex
 @param animated
 */
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

/*!
 Dismiss the sheet.
 */
- (void)cancel;

@end
