//
//  IRRadioButton.h
//  IRRadioButton-iOS
//
//  Created by irons on 2019/12/15.
//  Copyright © 2019年 irons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRRadioButton : UIButton

// Outlet collection of links to other buttons in the group.
@property (nonatomic, strong) IBOutletCollection(IRRadioButton) NSArray *groupButtons;

// Currently selected radio button in the group.
// If there are multiple buttons selected then it returns the first one.
@property (nonatomic, readonly) IRRadioButton *selectedButton;

// If selected==YES, then it selects the button and deselects other buttons in the group.
// If selected==NO, then it deselects the button and if there are only two buttons in the group, then it selects second.
- (void)setSelected:(BOOL)selected;

// Find first radio with given tag and makes it selected.
// All of other buttons in the group become deselected.
- (void)setSelectedWithTag:(NSInteger)tag;

- (void)deselectAllButtons;

@end

NS_ASSUME_NONNULL_END
