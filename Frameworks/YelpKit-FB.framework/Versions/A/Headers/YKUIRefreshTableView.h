//
//  YKUIRefreshTableView.h
//  YelpKit
//
//  Created by Gabriel Handford on 8/23/11.
//  Copyright 2011 Yelp. All rights reserved.
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

#import "YKUIRefreshTableHeaderView.h"

@class YKUIRefreshTableView;

@protocol YKUIRefreshTableViewDelegate <NSObject>
- (void)refreshScrollViewShouldRefresh:(YKUIRefreshTableView *)refreshScrollView;
@end

/*!
 Pull to refresh table view.
 
 In your controller:
 
     - (void)viewDidLoad {
        [super viewDidLoad];
        [[self refreshTableView] setRefreshHeaderEnabled:YES];
        [[self refreshTableView] setRefreshDelegate:self];
     }

 
     - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [(YKUIRefreshTableView *)self.tableView scrollViewDidScroll:scrollView];
     }
     
     - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
        [(YKUIRefreshTableView *)self.tableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
     }
 
     - (void)refreshScrollViewShouldRefresh:(YKUIRefreshTableView *)refreshScrollView {
        [[self refreshTableView] setRefreshing:NO];
        // Do the refresh
     }

 
 To disable the pull to refresh loading indicator, use setRefreshing:NO:
 
     [[self refreshTableView] setRefreshing:NO];
 
 */
@interface YKUIRefreshTableView : UITableView {
  YKUIRefreshTableHeaderView *_refreshHeaderView;
  
  id<YKUIRefreshTableViewDelegate> _refreshDelegate;
}

@property (readonly, nonatomic) YKUIRefreshTableHeaderView *refreshHeaderView;
@property (assign, nonatomic) id<YKUIRefreshTableViewDelegate> refreshDelegate;

/*!
 Set refreshing indicator.
 
 @param refreshing YES if refreshing
 */
- (void)setRefreshing:(BOOL)refreshing;

/*!
 Enable or disable the header.
 
 @param enabled YES to enable
 */
- (void)setRefreshHeaderEnabled:(BOOL)enabled;

/*!
 Check if refresh header is enabled.
 */
- (BOOL)isRefreshHeaderEnabled;

/*!
 Expand the refresh header view.
 
 @param expand If YES, expand
 */
- (void)expandRefreshHeaderView:(BOOL)expand;

/*!
 View did scroll. Controllers must call this.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

/*!
 View did end dragging. Controllers must call this.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end
