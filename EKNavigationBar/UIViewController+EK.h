//
//  UIViewController+EK.h
//  EKNavigationBar
//
//  Created by Sun on 2018/7/13.
//  Copyright © 2018年 YiKuNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (EK)

@property (nonatomic, assign) UIBarStyle ek_barStyle;
@property (nonatomic, strong) UIColor *ek_barTintColor;
@property (nonatomic, strong) UIImage *ek_barImage;
@property (nonatomic, strong) UIColor *ek_tintColor;
@property (nonatomic, strong) NSDictionary *ek_titleTextAttributes;
@property (nonatomic, assign) float ek_barAlpha;
@property (nonatomic, assign) BOOL ek_barHidden;
@property (nonatomic, assign) BOOL ek_barShadowHidden;
@property (nonatomic, assign) BOOL ek_backInteractive;
@property (nonatomic, assign) BOOL ek_swipeBackEnabled;

// computed
@property (nonatomic, assign, readonly) float ek_computedBarShadowAlpha;
@property (nonatomic, strong, readonly) UIColor *ek_computedBarTintColor;
@property (nonatomic, strong, readonly) UIImage *ek_computedBarImage;

- (void)ek_setNeedsUpdateNavigationBar;
- (void)ek_setNeedsUpdateNavigationBarAlpha;
- (void)ek_setNeedsUpdateNavigationBarColorOrImage;
- (void)ek_setNeedsUpdateNavigationBarShadowAlpha;

@end
