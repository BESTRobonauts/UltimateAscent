//
//  AlertPromptViewController.h
//  FieldDrawing
//
//  Created by FRC on 2/18/13.
//  Copyright (c) 2013 Kris. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertPromptDelegate
- (void)passCodeResult:(NSString *)passCodeAttempt;
@end

@interface AlertPromptViewController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, assign) id<AlertPromptDelegate> delegate;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *msgText;

@end
