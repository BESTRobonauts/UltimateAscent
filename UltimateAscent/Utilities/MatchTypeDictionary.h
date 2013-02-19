//
//  MatchTypeDictionary.h
//  UltimateAscent
//
//  Created by FRC on 2/18/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatchTypeDictionary : NSObject
-(NSString *)getMatchTypeString:(id) key;
-(id)getMatchTypeEnum:(NSString *) value;
@end
