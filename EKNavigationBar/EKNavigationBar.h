//
//  EKNavigationBar.h
//  EKNavigationBar
//
//  Created by Sun on 2018/7/13.
//  Copyright © 2018年 YiKuNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EKNavigationBar : UINavigationBar

@property (nonatomic, strong, readonly) UIImageView *shadowImageView;
@property (nonatomic, strong, readonly) UIVisualEffectView *fakeView;
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@end
