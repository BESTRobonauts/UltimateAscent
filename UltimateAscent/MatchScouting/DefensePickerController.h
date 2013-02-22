//
//  DefensePickerController.h
//  UltimateAscent
//
//  Created by FRC on 2/22/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DefensePickerDelegate
- (void)defenseSelected:(NSString *)defenseButton;
@end

@interface DefensePickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *defenseChoices;
@property (nonatomic, assign) id<DefensePickerDelegate> delegate;

@end
