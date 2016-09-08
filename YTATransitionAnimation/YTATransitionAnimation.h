//
//  YTATransitionAnimation.h
//  YTATransitionAnimation
//
//  Created by Yuta on 2016/09/04.
//  Copyright © 2016年 Yuta Takahashi. All rights reserved.
//

#import "YTATransitionAnimationProtocol.h"

typedef NS_ENUM(NSInteger, YTATransitionAnimationType)
{
    YTATransitionAnimationTypeSlide = 0,
    YTATransitionAnimationTypeZoom
};

@interface YTATransitionAnimation : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate>

@property (nonatomic, assign) CGFloat slideTransitionDuration;
@property (nonatomic, assign) CGFloat zoomTransitionDuration;

@property (nonatomic, assign) BOOL handleEdgePanBackGesture;

@property (nonatomic, assign) YTATransitionAnimationType animationType;

@property (nonatomic, readonly) UINavigationController *navigationController;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
