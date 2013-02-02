//
//  RecordScorePickerController.h
//  ReboundRumble
//
//  Created by FRC on 1/23/13.
//
//

#import <UIKit/UIKit.h>

@protocol RecordScorePickerDelegate
- (void)scoreSelected:(NSString *)scoreButton;
@end

@interface RecordScorePickerController : UITableViewController
@property (nonatomic, retain) NSMutableArray *scoreChoices;
@property (nonatomic, assign) id<RecordScorePickerDelegate> delegate;

@end
