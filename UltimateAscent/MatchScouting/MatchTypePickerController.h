//
//  MatchTypePickerController.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchTypePickerDelegate
- (void)matchTypeSelected:(NSString *)newMatchType;
@end

@interface MatchTypePickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *matchTypeChoices;
@property (nonatomic, assign) id<MatchTypePickerDelegate> delegate;

@end
