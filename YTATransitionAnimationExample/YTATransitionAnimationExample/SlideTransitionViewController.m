//
//  SlideTransitionViewController.m
//  YTATransitionAnimation
//
//  Created by Yuta on 2016/09/05.
//  Copyright © 2016年 Yuta Takahashi. All rights reserved.
//

#import "SlideTransitionViewController.h"
#import "DetailViewController.h"

#import "YTATransitionAnimationProtocol.h"
#import "YTATransitionAnimation.h"

@interface SlideTransitionViewController() <YTATransitionAnimationProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) YTATransitionAnimation *transition;

@end

@implementation SlideTransitionViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transition = [[YTATransitionAnimation alloc] initWithNavigationController:self.navigationController];
    self.transition.animationType = YTATransitionAnimationTypeSlide;
}

#pragma mark - segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"toDetailViewController"])
    {
        DetailViewController *detailViewController  = segue.destinationViewController;
        detailViewController.image = self.imageView.image;
    }
}

#pragma mark - YTATransitionAnimationProtocol

- (UIImageView *)imageViewForTransition
{
    return self.imageView;
}

@end
