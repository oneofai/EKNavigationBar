//
//  EKNavigationController.h
//  EKNavigationBar
//
//  Created by Sun on 2018/7/13.
//  Copyright © 2018年 YiKuNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EKNavigationController : UINavigationController

- (void)updateNavigationBarForViewController:(UIViewController *)vc;
- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc;
- (void)updateNavigationBarShadowIAlphaForViewController:(UIViewController *)vc;

@end

@interface UINavigationController(UINavigationBar) <UINavigationBarDelegate>

@end
