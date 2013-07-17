//
//  ValuePromptViewController.h
//  UltimateAscent
//
//  Created by FRC on 7/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ValuePromptDelegate
- (void)valueEnteredAtPrompt:(NSString *)valueEntered;
@end

@interface ValuePromptViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) id<ValuePromptDelegate> delegate;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *msgText;
@end
