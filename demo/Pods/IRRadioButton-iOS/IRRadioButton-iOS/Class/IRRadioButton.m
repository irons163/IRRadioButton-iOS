//
//  IRRadioButton.m
//  IRRadioButton-iOS
//
//  Created by irons on 2019/12/15.
//  Copyright © 2019年 irons. All rights reserved.
//

#import "IRRadioButton.h"

@interface IRRadioButton() {
    NSMutableArray *_sharedLinks;
}
@end

@implementation IRRadioButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if(![[self allTargets] containsObject:self]) {
            [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)awakeFromNib {
    if(![[self allTargets] containsObject:self]) {
        [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    // 'self' should be the first target
    if(![[self allTargets] containsObject:self]) {
        [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (void)onTouchUpInside {
    [self setSelected:YES distinct:YES sendControlEvent:YES];
}

- (void)setGroupButtons:(NSArray *)buttons {
    if(!_sharedLinks) {
        for(IRRadioButton* rb in buttons) {
            if(rb->_sharedLinks) {
                _sharedLinks = rb->_sharedLinks;
                break;
            }
        }
        if(!_sharedLinks) {
            _sharedLinks = [[NSMutableArray alloc] initWithCapacity:[buttons count]+1];
        }
    }
    
    BOOL (^btnExistsInList)(NSArray*, IRRadioButton*) = ^(NSArray* list, IRRadioButton* rb){
        for(NSValue* v in list) {
            if([v nonretainedObjectValue]==rb) {
                return YES;
            }
        }
        return NO;
    };
    
    if(!btnExistsInList(_sharedLinks, self)) {
        [_sharedLinks addObject:[NSValue valueWithNonretainedObject:self]];
    }
    
    for(IRRadioButton* rb in buttons) {
        if(rb->_sharedLinks!=_sharedLinks) {
            if(!rb->_sharedLinks) {
                rb->_sharedLinks = _sharedLinks;
            } else {
                for(NSValue* v in rb->_sharedLinks) {
                    IRRadioButton* vrb = [v nonretainedObjectValue];
                    if(!btnExistsInList(_sharedLinks, vrb)) {
                        [_sharedLinks addObject:v];
                        vrb->_sharedLinks = _sharedLinks;
                    }
                }
            }
        }
        if(!btnExistsInList(_sharedLinks, rb)) {
            [_sharedLinks addObject:[NSValue valueWithNonretainedObject:rb]];
        }
    }
}

- (NSArray *)groupButtons {
    if([_sharedLinks count]) {
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:[_sharedLinks count]];
        for(NSValue* v in _sharedLinks) {
            [buttons addObject:[v nonretainedObjectValue]];
        }
        return buttons;
    }
    return nil;
}

- (IRRadioButton*)selectedButton {
    if([self isSelected]) {
        return self;
    } else {
        for(NSValue* v in _sharedLinks) {
            IRRadioButton* rb = [v nonretainedObjectValue];
            if([rb isSelected]) {
                return rb;
            }
        }
    }
    return nil;
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected distinct:YES sendControlEvent:NO];
}

- (void)setButtonSelected:(BOOL)selected sendControlEvent:(BOOL)sendControlEvent {
    BOOL valueChanged = (self.selected != selected);
    [super setSelected:selected];
    if(valueChanged && sendControlEvent) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelected:(BOOL)selected distinct:(BOOL)distinct sendControlEvent:(BOOL)sendControlEvent {
    [self setButtonSelected:selected sendControlEvent:sendControlEvent];
    
    if( distinct && (selected || [_sharedLinks count]==2) )
    {
        selected = !selected;
        for(NSValue* v in _sharedLinks) {
            IRRadioButton* rb = [v nonretainedObjectValue];
            if(rb!=self) {
                [rb setButtonSelected:selected sendControlEvent:sendControlEvent];
            }
        }
    }
}

- (void)deselectAllButtons {
    for(NSValue* v in _sharedLinks) {
        IRRadioButton* rb = [v nonretainedObjectValue];
        [rb setButtonSelected:NO sendControlEvent:NO];
    }
}

- (void)setSelectedWithTag:(NSInteger)tag {
    if(self.tag == tag) {
        [self setSelected:YES distinct:YES sendControlEvent:NO];
    } else {
        for(NSValue* v in _sharedLinks) {
            IRRadioButton* rb = [v nonretainedObjectValue];
            if(rb.tag == tag) {
                [rb setSelected:YES distinct:YES sendControlEvent:NO];
                break;
            }
        }
    }
}

- (void)dealloc {
    for(NSValue* v in _sharedLinks) {
        if([v nonretainedObjectValue]==self) {
            [_sharedLinks removeObjectIdenticalTo:v];
            break;
        }
    }
}

@end

