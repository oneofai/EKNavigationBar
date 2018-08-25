//
//  UIViewController+EK.m
//  EKNavigationBar
//
//  Created by Sun on 2018/7/13.
//  Copyright © 2018年 YiKuNetwork. All rights reserved.
//

#import "UIViewController+EK.h"
#import <objc/runtime.h>
#import "EKNavigationController.h"

@implementation UIViewController (EK)

- (UIBarStyle)ek_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setEk_barStyle:(UIBarStyle)ek_barStyle {
    objc_setAssociatedObject(self, @selector(ek_barStyle), @(ek_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)ek_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEk_barTintColor:(UIColor *)tintColor {
     objc_setAssociatedObject(self, @selector(ek_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)ek_barImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEk_barImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(ek_barImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)ek_tintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].tintColor;
}

- (void)setEk_tintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(ek_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)ek_titleTextAttributes {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].titleTextAttributes;
}

- (void)setEk_titleTextAttributes:(NSDictionary *)attributes {
    objc_setAssociatedObject(self, @selector(ek_titleTextAttributes), attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)ek_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.ek_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setEk_barAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(ek_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)ek_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setEk_barHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(ek_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)ek_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return  self.ek_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setEk_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(ek_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)ek_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

-(void)setEk_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(ek_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ek_swipeBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setEk_swipeBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(ek_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)ek_computedBarShadowAlpha {
    return  self.ek_barShadowHidden ? 0 : self.ek_barAlpha;
}

- (UIImage *)ek_computedBarImage {
    UIImage *image = self.ek_barImage;
    if (!image) {
        if (self.ek_barTintColor) {
            return nil;
        }
        return [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    return image;
}

- (UIColor *)ek_computedBarTintColor {
    if (self.ek_barImage) {
        return nil;
    }
    UIColor *color = self.ek_barTintColor;
    if (!color) {
        if ([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]) {
            return nil;
        }
        if ([UINavigationBar appearance].barTintColor) {
            color = [UINavigationBar appearance].barTintColor;
        } else {
            color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ? [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.8]: [UIColor colorWithRed:28/255.0 green:28/255.0 blue:28/255.0 alpha:0.729];
        }
    }
    return color;
}

- (void)ek_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[EKNavigationController class]]) {
        EKNavigationController *nav = (EKNavigationController *)self.navigationController;
        [nav updateNavigationBarForViewController:self];
    }
}

-(void)ek_setNeedsUpdateNavigationBarAlpha {
    if (self.navigationController && [self.navigationController isKindOfClass:[EKNavigationController class]]) {
        EKNavigationController *nav = (EKNavigationController *)self.navigationController;
        [nav updateNavigationBarAlphaForViewController:self];
    }
}

- (void)ek_setNeedsUpdateNavigationBarColorOrImage {
    if (self.navigationController && [self.navigationController isKindOfClass:[EKNavigationController class]]) {
        EKNavigationController *nav = (EKNavigationController *)self.navigationController;
        [nav updateNavigationBarColorOrImageForViewController:self];
    }
}

- (void)ek_setNeedsUpdateNavigationBarShadowAlpha {
    if (self.navigationController && [self.navigationController isKindOfClass:[EKNavigationController class]]) {
        EKNavigationController *nav = (EKNavigationController *)self.navigationController;
        [nav updateNavigationBarShadowIAlphaForViewController:self];
    }
}

@end
