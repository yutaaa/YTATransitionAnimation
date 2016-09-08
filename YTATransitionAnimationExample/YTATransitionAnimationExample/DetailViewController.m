//
//  DetailViewController.m
//  YTATransitionAnimation
//
//  Created by Yuta on 2016/09/04.
//  Copyright © 2016年 Yuta Takahashi. All rights reserved.
//

#import "DetailViewController.h"

#import "YTATransitionAnimationProtocol.h"

@interface DetailViewController() <YTATransitionAnimationProtocol>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DetailViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
}

#pragma mark - YTATransitionAnimationProtocol

- (UIImageView *)imageViewForTransition
{
    return self.imageView;
}

@end
