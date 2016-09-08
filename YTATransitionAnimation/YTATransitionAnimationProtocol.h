//
//  YTATransitionAnimationProtocol.h
//  YTATransitionAnimation
//
//  Created by Yuta on 2016/09/04.
//  Copyright © 2016年 Yuta Takahashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YTATransitionAnimationProtocol <NSObject>

@required

- (UIImageView *)imageViewForTransition;

@end
