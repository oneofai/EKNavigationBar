//
//  EKNavigationController.m
//  EKNavigationBar
//
//  Created by Sun on 2018/7/13.
//  Copyright © 2018年 YiKuNetwork. All rights reserved.
//

#import "EKNavigationController.h"
#import "UIViewController+EK.h"
#import "EKNavigationBar.h"

@interface EKNavigationController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readonly) EKNavigationBar *navigationBar;
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;
@property (nonatomic, assign) BOOL inGesture;

@end

@implementation EKNavigationController

@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[EKNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    NSAssert([navigationBarClass isSubclassOfClass:[EKNavigationBar class]], @"navigationBarClass Must be a subclass of EKNavigationBar");
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)init {
    return [super initWithNavigationBarClass:[EKNavigationBar class] toolbarClass:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handlePopGesture:)];
    self.delegate = self;
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
}

- (void)handlePopGesture:(UIScreenEdgePanGestureRecognizer *)recognizer {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        self.inGesture = YES;
        self.navigationBar.tintColor = blendColor(from.ek_tintColor, to.ek_tintColor, coordinator.percentComplete);
    } else {
        self.inGesture = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count > 1) {
        return self.topViewController.ek_backInteractive && self.topViewController.ek_swipeBackEnabled;
    }
    return NO;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item ) {
        if (!self.topViewController.ek_backInteractive) {
            [self resetSubviewsInNavBar:self.navigationBar];
            return NO;
        }
    }
    return [super navigationBar:navigationBar shouldPopItem:item];
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (coordinator) {
        UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (shouldShowFake(viewController, from, to)) {
                if (self.inGesture) {
                    self.navigationBar.titleTextAttributes = viewController.ek_titleTextAttributes;
                    self.navigationBar.barStyle = viewController.ek_barStyle;
                } else {
                    [self updateNavigationBarAnimatedForController:viewController];
                }
                [UIView performWithoutAnimation:^{
                    self.navigationBar.fakeView.alpha = 0;
                    self.navigationBar.shadowImageView.alpha = 0;
                    self.navigationBar.backgroundImageView.alpha = 0;
                    
                    // from
                    self.fromFakeImageView.image = from.ek_computedBarImage;
                    self.fromFakeImageView.alpha = from.ek_barAlpha;
                    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeImageView];
                    
                    self.fromFakeBar.subviews.lastObject.backgroundColor = from.ek_computedBarTintColor;
                    self.fromFakeBar.alpha = from.ek_barAlpha == 0 || from.ek_computedBarImage ? 0.01:from.ek_barAlpha;
                    if (from.ek_barAlpha == 0 || from.ek_computedBarImage) {
                        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
                    }
                    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
                    [from.view addSubview:self.fromFakeBar];
                    
                    self.fromFakeShadow.alpha = from.ek_computedBarShadowAlpha;
                    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
                    [from.view addSubview:self.fromFakeShadow];
                    
                    // to
                    self.toFakeImageView.image = to.ek_computedBarImage;
                    self.toFakeImageView.alpha = to.ek_barAlpha;
                    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeImageView];
                    
                    self.toFakeBar.subviews.lastObject.backgroundColor = to.ek_computedBarTintColor;
                    self.toFakeBar.alpha = to.ek_computedBarImage ? 0 : to.ek_barAlpha;
                    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
                    [to.view addSubview:self.toFakeBar];
                    
                    self.toFakeShadow.alpha = to.ek_computedBarShadowAlpha;
                    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
                    [to.view addSubview:self.toFakeShadow];
                }];
            } else {
                [self updateNavigationBarForViewController:viewController];
            }
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (context.isCancelled) {
                [self updateNavigationBarForViewController:from];
            } else {
                // 当 present 时 to 不等于 viewController
                [self updateNavigationBarForViewController:viewController];
            }
            if (to == viewController) {
                [self clearFake];
            }
        }];
        
        if (@available(iOS 10.0, *)) {
            [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (!context.isCancelled && self.inGesture) {
                    [self updateNavigationBarAnimatedForController:viewController];
                }
            }];
        } else {
            [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (!context.isCancelled && self.inGesture) {
                    [self updateNavigationBarAnimatedForController:viewController];
                }
            }];
        }
    } else {
        [self updateNavigationBarForViewController:viewController];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *vc = [super popViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.ek_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.ek_titleTextAttributes;
    return vc;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray *array = [super popToViewController:viewController animated:animated];
    self.navigationBar.barStyle = self.topViewController.ek_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.ek_titleTextAttributes;
    return array;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    NSArray *array = [super popToRootViewControllerAnimated:animated];
    self.navigationBar.barStyle = self.topViewController.ek_barStyle;
    self.navigationBar.titleTextAttributes = self.topViewController.ek_titleTextAttributes;
    return array;
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = vc.view.frame.origin.x;
    //  解决根视图为scrollView的时候，Push不正常
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        //  适配iPhoneX
        frame.origin.y = -([UIScreen mainScreen].bounds.size.height == 812.0 ? 88 : 64);
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorOrImageForViewController:vc];
    [self updateNavigationBarShadowIAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForController:vc];
}

- (void)updateNavigationBarAnimatedForController:(UIViewController *)vc {
    self.navigationBar.barStyle = vc.ek_barStyle;
    self.navigationBar.titleTextAttributes = vc.ek_titleTextAttributes;
    self.navigationBar.tintColor = vc.ek_tintColor;
}

- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.ek_computedBarImage) {
        self.navigationBar.fakeView.alpha = 0;
        self.navigationBar.backgroundImageView.alpha = vc.ek_barAlpha;
    } else {
        self.navigationBar.fakeView.alpha = vc.ek_barAlpha;
        self.navigationBar.backgroundImageView.alpha = 0;
    }
    self.navigationBar.shadowImageView.alpha = vc.ek_computedBarShadowAlpha;
}

- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.ek_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.ek_computedBarImage;
}

- (void)updateNavigationBarShadowIAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.ek_computedBarShadowAlpha;
}

BOOL shouldShowFake(UIViewController *vc,UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.ek_computedBarImage && to.ek_computedBarImage && isImageEqual(from.ek_computedBarImage, to.ek_computedBarImage)) {
        // 都有图片，并且是同一张图片
        if (ABS(from.ek_barAlpha - to.ek_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.ek_computedBarImage && !to.ek_computedBarImage && [from.ek_computedBarTintColor.description isEqual:to.ek_computedBarTintColor.description]) {
        // 都没图片，并且颜色相同
        if (ABS(from.ek_barAlpha - to.ek_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed = fromRed + (toRed - fromRed) * percent;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

@end

