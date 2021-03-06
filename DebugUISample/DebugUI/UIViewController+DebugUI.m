//
//  UIViewController+DebugUI.m
//  DebugUISample
//
//  Created by Cong Can NGO on 3/1/17.
//  Copyright © 2017 vns. All rights reserved.
//

#import "UIViewController+DebugUI.h"
#import <objc/runtime.h>

#define kContentView  "kContentView"
#define kScreenImageView  "kScreenImageView"
#define kCommentLabel  "kCommentLabel"
#define kContentViewCenterXConstraint  "kContentViewCenterXConstraint"
#define kContentViewCenterYConstraint  "kContentViewCenterYConstraint"


@implementation UIViewController (DebugUI)

- (void)addDebugScreen:(NSString *)imageNamed {
    UIImage *screenImage = [UIImage imageNamed:imageNamed];
    if (!imageNamed) {
        NSLog(@"DebugUI - %@ does not exist", imageNamed);
        return;
    }
    
    UIView *contentView = [UIView new];
    contentView.layer.borderColor = [UIColor redColor].CGColor;
    contentView.layer.borderWidth = 0.5f;
    contentView.backgroundColor = [UIColor clearColor];
    
    NSArray *constraints = [self addSubViewWithFullSizeConstraints:contentView toView:self.view];
    objc_setAssociatedObject(self,kContentViewCenterXConstraint, constraints[0], OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self,kContentViewCenterYConstraint, constraints[1], OBJC_ASSOCIATION_ASSIGN);
    
    UIImageView *screenImageView = [UIImageView new];
    screenImageView.contentMode = UIViewContentModeScaleAspectFit;
    screenImageView.image = screenImage;
    screenImageView.alpha = 0.5;
    [self addSubViewWithFullSizeConstraints:screenImageView toView:contentView];
    
    [self addControlsToView:contentView];
    
    objc_setAssociatedObject(self,kContentView, contentView, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self,kScreenImageView, screenImageView, OBJC_ASSOCIATION_ASSIGN);
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    tap1.numberOfTapsRequired = 1;
    [contentView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    tap2.numberOfTapsRequired = 2;
    [contentView addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    tap3.numberOfTapsRequired = 3;
    [contentView addGestureRecognizer:tap3];

}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)sender {
 
    UIView *contentView = objc_getAssociatedObject(self, kContentView);
    
    switch (sender.numberOfTapsRequired) {
        case 1:
        {
            contentView.layer.borderWidth = 0.5f;
            for (UIView *subView in contentView.subviews) {
                if (![subView isKindOfClass:[UIImageView class]]) {
                    subView.hidden = NO;
                }
            }
        }
            break;
        case 2:
        {
            contentView.layer.borderWidth = 0.0f;
            for (UIView *subView in contentView.subviews) {
                if (![subView isKindOfClass:[UIImageView class]]) {
                    subView.hidden = YES;
                }
            }
        }
            break;
            
        case 3:
        {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [self logParametters:self.view result:&result count:0];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&err];
            NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"result -> \n %@", jsonString);
            
            
        }
            break;
            
        default:
            break;
    }
}

- (void)addControlsToView:(UIView *)view {
    
    [self.view layoutIfNeeded];
    CGFloat height = CGRectGetHeight(view.frame);
    CGFloat width = CGRectGetWidth(view.frame);
    CGFloat numberOfButton = 6;
    CGSize buttonSize = CGSizeMake(width/numberOfButton, width/numberOfButton);
    NSArray *buttonTitles = @[@"<-", @"->", @"alfa+", @"alfa-", @"^", @"v"];
    for (int idx = 0; idx < numberOfButton; idx ++) {
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(idx * buttonSize.width, height - buttonSize.height, buttonSize.width, buttonSize.height);
        button.tag = idx;
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderColor = [UIColor blueColor].CGColor;
        button.layer.borderWidth = 0.5f;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setTitle:buttonTitles[idx] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidPressAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    UILabel *commentLabel = [UILabel new];
    commentLabel.textColor = [UIColor redColor];
    [view addSubview:commentLabel];
    commentLabel.numberOfLines = 4;
    commentLabel.textAlignment = NSTextAlignmentCenter;
    commentLabel.text = @"Tap 1/2 to show/hide the controls. Tap 3 to log parameters";
    commentLabel.frame =  CGRectMake(0, height - buttonSize.height - 100, width, 100);
    objc_setAssociatedObject(self,kCommentLabel, commentLabel, OBJC_ASSOCIATION_ASSIGN);

}

- (void) buttonDidPressAction:(UIButton *)sender {
    
    NSString *value = @"";
    
    switch (sender.tag) {
        case 0:
        {
            NSLayoutConstraint *centerX = objc_getAssociatedObject(self, kContentViewCenterXConstraint);
            centerX.constant += 1;
            if (centerX.constant != 0) {
                value = [NSString stringWithFormat:@"%.0f px", centerX.constant];
            }
            
        }
            break;
        case 1:
        {
            NSLayoutConstraint *centerX = objc_getAssociatedObject(self, kContentViewCenterXConstraint);
            centerX.constant -= 1;
            if (centerX.constant != 0) {
                value = [NSString stringWithFormat:@"%.0f px", centerX.constant];
            }
            
        }
            break;
        case 2:
        {
            UIView *screenImageView = objc_getAssociatedObject(self, kScreenImageView);
            screenImageView.alpha += 0.1;
            
        }
            break;
        case 3:
        {
            UIView *screenImageView = objc_getAssociatedObject(self, kScreenImageView);
            screenImageView.alpha -= 0.1;
        }
            break;
        case 4:
        {
            NSLayoutConstraint *centerY = objc_getAssociatedObject(self, kContentViewCenterYConstraint);
            centerY.constant += 1;
            if (centerY.constant != 0) {
                value = [NSString stringWithFormat:@"%.0f px", centerY.constant];
            }

        }
            break;
        case 5:
        {
            NSLayoutConstraint *centerY = objc_getAssociatedObject(self, kContentViewCenterYConstraint);
            centerY.constant -= 1;
            if (centerY.constant != 0) {
                value = [NSString stringWithFormat:@"%.0f px", centerY.constant];
            }

        }
            break;

            
        default:
            break;
    }
    
    
    UILabel *commentLabel = objc_getAssociatedObject(self, kCommentLabel);
    NSString *title = commentLabel.text;
    NSArray *splitTitles = [title componentsSeparatedByString:@"\n"];
    NSString *newTitle = [NSString stringWithFormat:@"%@\n%@", splitTitles[0], value];
    commentLabel.text = newTitle;
}

- (NSArray *)addSubViewWithFullSizeConstraints:(UIView *)subView toView:(UIView *)supperView  {
    
    [supperView addSubview:subView];
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:supperView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:supperView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *equalWidth = [NSLayoutConstraint constraintWithItem:supperView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *equalHeight = [NSLayoutConstraint constraintWithItem:supperView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:subView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSArray *constraints = @[centerX, centerY, equalWidth, equalHeight];
    [supperView addConstraints:constraints];
    return constraints;
    
}

- (void)logParametters:(UIView *)targetView result:(NSMutableDictionary** )result count:(NSUInteger)count {
    NSLog(@"%@ - %lu", NSStringFromClass([targetView class]), (unsigned long)targetView.subviews.count);
    if (targetView.subviews.count == 0) {
        NSString *key = [NSString stringWithFormat:@"Child-%lu", (unsigned long)count];
        
        NSMutableDictionary *extensionParameters = [NSMutableDictionary dictionary];
        if ([targetView isKindOfClass:[UILabel class]]) {
            NSString *text = [(UILabel *) targetView text];
            if (text) {
                [extensionParameters setObject:text forKey:@"text"];
            }
            UIColor *textColor = [(UILabel *) targetView textColor];
            [extensionParameters setObject:[self hexStringFromColor:textColor] forKey:@"textColor"];
            UIFont *font = [(UILabel *) targetView font];
            [extensionParameters setObject:[font description] forKey:@"font"];
        } else if ([targetView isKindOfClass:[UITextField class]]) {
            NSString *text = [(UITextField *) targetView text];
            if (text) {
                [extensionParameters setObject:text forKey:@"text"];
            }
            UIColor *textColor = [(UITextField *) targetView textColor];
            [extensionParameters setObject:[self hexStringFromColor:textColor] forKey:@"textColor"];
            UIFont *font = [(UITextField *) targetView font];
            [extensionParameters setObject:[font description] forKey:@"font"];
        } else if ([targetView isKindOfClass:[UITextView class]]) {
            NSString *text = [(UITextView *) targetView text];
            if (text) {
                [extensionParameters setObject:text forKey:@"text"];
            }
            UIColor *textColor = [(UITextView *) targetView textColor];
            [extensionParameters setObject:[self hexStringFromColor:textColor] forKey:@"textColor"];
            UIFont *font = [(UITextView *) targetView font];
            [extensionParameters setObject:[font description] forKey:@"font"];
        } else if ([targetView isKindOfClass:[UIButton class]]) {
            NSString *currentTitle = [(UIButton *) targetView currentTitle];
            if (currentTitle) {
                [extensionParameters setObject:currentTitle forKey:@"currentTitle"];
            }
            UIColor *textColor = [[(UIButton *) targetView titleLabel] textColor];
            [extensionParameters setObject:[self hexStringFromColor:textColor] forKey:@"textColor"];
            UIFont *font = [[(UIButton *) targetView titleLabel] font];
            [extensionParameters setObject:[font description] forKey:@"font"];
        }

        
        UIColor *nullableBackgroundColor = targetView.backgroundColor;
        CGFloat alpha = targetView.alpha;
        
        NSDictionary *parameters = @{@"frame": NSStringFromCGRect(targetView.frame),
                                     @"className" : NSStringFromClass([targetView class]),
                                     @"alpha" : @(alpha),
                                     @"backgroundColor" : [self hexStringFromColor:nullableBackgroundColor],
                                     @"more-info" : extensionParameters
                                     };

        NSMutableArray *array = [*result objectForKey:key];
        if (!array) {
            array = [NSMutableArray array];
        }
        [array addObject:parameters];
        [*result setObject:array forKey:key];
    } else if ([targetView isEqual:objc_getAssociatedObject(self, kContentView)]) {
        return;
    }
    else for (UIView *subView in targetView.subviews) {
        [self logParametters:subView result:result count:count + 1];
    }
    
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    if (!color) {
        return @"transparent";
    }
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}
@end
