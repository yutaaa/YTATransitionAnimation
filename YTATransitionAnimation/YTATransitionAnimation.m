//
//  YTATransitionAnimation.m
//  YTATransitionAnimation
//
//  Created by Yuta on 2016/09/04.
//  Copyright © 2016年 Yuta Takahashi. All rights reserved.
//

#import "YTATransitionAnimation.h"

static const NSTimeInterval kSlideTransitionDuration = 0.3;
static const NSTimeInterval kZoomTransitionDuration = 0.6;

@interface YTATransitionAnimation()

@property (nonatomic, assign) BOOL shouldCompleteTransition;
@property (nonatomic, assign) BOOL goingForward;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@property (nonatomic, readwrite) UINavigationController *navigationController;

@end

@implementation YTATransitionAnimation

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        [self commonSetup];
    }
    return self;
}

#pragma mark - Public

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    if (self = [super init])
    {
        self.navigationController = navigationController;
        self.navigationController.delegate = self;
        [self commonSetup];
    }
    return self;
}

#pragma mark - Private

- (void)commonSetup
{
    self.slideTransitionDuration = kSlideTransitionDuration;
    self.zoomTransitionDuration = kZoomTransitionDuration;
    self.animationType = YTATransitionAnimationTypeSlide;
    self.handleEdgePanBackGesture = YES;
}

- (void)animateSlideTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.goingForward)
    {
        UIViewController<YTATransitionAnimationProtocol> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController<YTATransitionAnimationProtocol> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:fromVC.view];
        [containerView addSubview:toVC.view];
        
        toVC.view.center = CGPointMake(toVC.view.center.x + containerView.bounds.size.width,
                                       toVC.view.center.y);
        
        UIImageView *fromImageView = [fromVC imageViewForTransition];
        UIImageView *toImageView = [toVC imageViewForTransition];
        
        // this is needed if the toImageView is using autoLayout
        [toImageView layoutIfNeeded];
        
        UIImageView *animatingImageView = [[UIImageView alloc] initWithImage:fromImageView.image];
        animatingImageView.frame = CGRectIntegral([fromImageView.superview convertRect:fromImageView.frame
                                                                                toView:containerView]);
        animatingImageView.contentMode = fromImageView.contentMode;
        animatingImageView.clipsToBounds = fromImageView.clipsToBounds;
        [containerView addSubview:animatingImageView];
        
        fromImageView.alpha = 0;
        toImageView.alpha = 0;
        
        // add edge pan gesture
        if (self.handleEdgePanBackGesture)
        {
            __block BOOL wasAdded = NO;
            [toVC.view.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gestureRecognizer, NSUInteger idx, BOOL *stop)
             {
                 if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
                 {
                     wasAdded = YES;
                     *stop = YES;
                 }
             }];
            if (!wasAdded)
            {
                UIScreenEdgePanGestureRecognizer *panRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                                    action:@selector(handleEdgePan:)];
                panRecognizer.edges = UIRectEdgeLeft;
                [toVC.view addGestureRecognizer:panRecognizer];
            }
        }
        
        [UIView animateWithDuration:self.slideTransitionDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             CGRect animatingImageViewRect = CGRectIntegral([toImageView.superview convertRect:toImageView.frame
                                                                                                        toView:containerView]);
                             animatingImageViewRect.origin.x -= containerView.bounds.size.width;
                             animatingImageView.frame = animatingImageViewRect;
                             
                             toVC.view.center = CGPointMake(toVC.view.center.x - containerView.bounds.size.width,
                                                            toVC.view.center.y);
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                             [animatingImageView removeFromSuperview];
                             
                             fromImageView.alpha = 1;
                             toImageView.alpha = 1;
                         }];
    }
    else
    {
        UIViewController<YTATransitionAnimationProtocol> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController<YTATransitionAnimationProtocol> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toVC.view];
        [containerView addSubview:fromVC.view];
        
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        
        UIImageView *fromImageView = [fromVC imageViewForTransition];
        UIImageView *toImageView = [toVC imageViewForTransition];
        
        // this is needed if the toImageView is using autoLayout
        [toImageView layoutIfNeeded];
        
        UIImageView *animatingImageView = [[UIImageView alloc] initWithImage:fromImageView.image];
        animatingImageView.frame = CGRectIntegral([fromImageView.superview convertRect:fromImageView.frame
                                                                                toView:containerView]);
        animatingImageView.contentMode = fromImageView.contentMode;
        animatingImageView.clipsToBounds = fromImageView.clipsToBounds;
        [containerView addSubview:animatingImageView];
        
        fromImageView.alpha = 0;
        toImageView.alpha = 0;
        
        [UIView animateWithDuration:self.slideTransitionDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             animatingImageView.frame = CGRectIntegral([toImageView.superview convertRect:toImageView.frame
                                                                                                   toView:containerView]);
                             
                             fromVC.view.center = CGPointMake(fromVC.view.center.x + containerView.bounds.size.width,
                                                              fromVC.view.center.y);
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                             [fromVC.view removeFromSuperview];
                             [animatingImageView removeFromSuperview];
                             
                             fromImageView.alpha = 1;
                             toImageView.alpha = 1;
                         }];
    }
}

- (void)animateZoomTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController<YTATransitionAnimationProtocol> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<YTATransitionAnimationProtocol> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    UIView *alphaView = [[UIView alloc] initWithFrame:[transitionContext finalFrameForViewController:toVC]];
    alphaView.backgroundColor = fromVC.view.backgroundColor;
    [containerView addSubview:alphaView];
    
    UIImageView *sourceImageView = [[UIImageView alloc] initWithImage:[fromVC imageViewForTransition].image];
    sourceImageView.frame = CGRectIntegral([[fromVC imageViewForTransition].superview convertRect:[fromVC imageViewForTransition].frame
                                                                                           toView:containerView]);
    sourceImageView.contentMode = [fromVC imageViewForTransition].contentMode;
    sourceImageView.clipsToBounds = [fromVC imageViewForTransition].clipsToBounds;
    [containerView addSubview:sourceImageView];
    
    UIImageView *destinationTransitionImageView = [toVC imageViewForTransition];
    [destinationTransitionImageView layoutIfNeeded];
    destinationTransitionImageView.alpha = 0;
    
    if (self.goingForward)
    {
        // add edge pan gesture
        if (self.handleEdgePanBackGesture)
        {
            __block BOOL wasAdded = NO;
            [toVC.view.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gestureRecognizer, NSUInteger idx, BOOL *stop)
             {
                 if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
                 {
                     wasAdded = YES;
                     *stop = YES;
                 }
             }];
            if (!wasAdded)
            {
                UIScreenEdgePanGestureRecognizer *panRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                                    action:@selector(handleEdgePan:)];
                panRecognizer.edges = UIRectEdgeLeft;
                [toVC.view addGestureRecognizer:panRecognizer];
            }
        }
        
        [UIView animateWithDuration:self.zoomTransitionDuration
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:15.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             sourceImageView.frame = destinationTransitionImageView.frame;
                             sourceImageView.transform = CGAffineTransformIdentity;
                             alphaView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             destinationTransitionImageView.alpha = 1;
                             
                             sourceImageView.alpha = 0;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                             [alphaView removeFromSuperview];
                             [sourceImageView removeFromSuperview];
                         }];
    }
    else
    {
        [UIView animateWithDuration:self.zoomTransitionDuration
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:15.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             sourceImageView.frame = destinationTransitionImageView.frame;
                             sourceImageView.transform = CGAffineTransformIdentity;
                             alphaView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             destinationTransitionImageView.alpha = 1;
                             
                             sourceImageView.alpha = 0;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                             [alphaView removeFromSuperview];
                             [sourceImageView removeFromSuperview];
                         }];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animator:(id<UIViewControllerAnimatedTransitioning>)animator
                                 navigationController:(UINavigationController *)navigationController
                                     toViewController:(UIViewController *)toVC
{
    if (!animator || !self.handleEdgePanBackGesture)
    {
        navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)toVC;
    }
    
    return animator;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    switch (self.animationType)
    {
        case YTATransitionAnimationTypeSlide:
        {
            return self.slideTransitionDuration;
        }
        case YTATransitionAnimationTypeZoom:
        {
            return self.zoomTransitionDuration;
        }
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    switch (self.animationType)
    {
        case YTATransitionAnimationTypeSlide:
        {
            [self animateSlideTransition:transitionContext];
            break;
        }
        case YTATransitionAnimationTypeZoom:
        {
            [self animateZoomTransition:transitionContext];
            break;
        }
    }
}

#pragma mark - edge back gesture handling

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)panRecognizer
{
    CGPoint point = [panRecognizer translationInView:panRecognizer.view];
    switch (panRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.interactive = YES;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat percent = point.x / panRecognizer.view.frame.size.width;
            self.shouldCompleteTransition = (percent > 0.25);
            [self updateInteractiveTransition: (percent <= 0.0) ? 0.0 : percent];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (!self.shouldCompleteTransition || panRecognizer.state == UIGestureRecognizerStateCancelled)
            {
                [self cancelInteractiveTransition];
            }
            else
            {
                [self finishInteractiveTransition];
            }
            self.interactive = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (!navigationController)
    {
        return [self animator:nil navigationController:nil toViewController:nil];
    }
    
    id <YTATransitionAnimationProtocol> sourceTransition = (id<YTATransitionAnimationProtocol>)fromVC;
    id <YTATransitionAnimationProtocol> destinationTransition = (id<YTATransitionAnimationProtocol>)toVC;
    
    Protocol *protocol = @protocol(YTATransitionAnimationProtocol);
    if (![sourceTransition conformsToProtocol:protocol] ||
        ![destinationTransition conformsToProtocol:protocol])
    {
        return [self animator:nil navigationController:navigationController toViewController:toVC];
    }
    
    if (![sourceTransition respondsToSelector:@selector(imageViewForTransition)] ||
        ![destinationTransition respondsToSelector:@selector(imageViewForTransition)])
    {
        return [self animator:nil navigationController:navigationController toViewController:toVC];
    }
    
    [fromVC view];
    [toVC view];
    
    if (![sourceTransition imageViewForTransition] ||
        ![destinationTransition imageViewForTransition])
    {
        return [self animator:nil navigationController:navigationController toViewController:toVC];
    }
    
    self.goingForward = (operation == UINavigationControllerOperationPush);
    
    return [self animator:self navigationController:navigationController toViewController:toVC];
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if (!self.isInteractive)
    {
        return nil;
    }
    
    return self;
}

@end
