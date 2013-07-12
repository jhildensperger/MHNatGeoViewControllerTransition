//
// MHNatGeoViewControllerTransition.m
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MHNatGeoViewControllerTransition.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@implementation MHNatGeoViewControllerTransition

- (id)initWithSourceView:(UIView *)sourceView destinationView:(UIView *)destinationView duration:(NSTimeInterval)duration {
    if(self = [super init]) {
        self.sourceView = sourceView;
        self.destinationView = destinationView;
        self.duration = duration;
    }
    return self;
}

- (void)perform {
    [self perform:nil];
}

- (void)perform:(void (^)(BOOL finished))completion {
    if (self.isDimissing) {
        // Reset to initial transform
        sourceLastTransform([self.sourceView layer]);
        destinationLastTransform([self.destinationView layer]);
        
         //Perform animation
        [UIView animateWithDuration:0.8f*self.duration delay:0.2f*self.duration options:UIViewAnimationOptionCurveLinear animations:^{
            destinationFirstTransform([self.destinationView layer]);
        } completion:^(BOOL finished) {
            completion(YES);
        }];
        
        [UIView animateWithDuration:self.duration delay:0.0f options:0 animations:^{
            sourceFirstTransform([self.sourceView layer]);
        } completion:nil];
    } else {
        // Change anchor point and reposition it.
        CGRect oldFrame = [[self.sourceView layer]frame];
        [[self.sourceView layer] setAnchorPoint:CGPointMake(0.0,0.5f)];
        [[self.sourceView layer] setFrame:oldFrame];
        
        // Reset to initial transform
        sourceFirstTransform([self.sourceView layer]);
        destinationFirstTransform([self.destinationView layer]);
        
        //Perform animation
        [UIView animateWithDuration:self.duration delay:0.0f options:0 animations:^{
            destinationLastTransform([self.destinationView layer]);
        } completion:nil];
        
        [UIView animateWithDuration:0.8*self.duration delay:0.2*self.duration options:0 animations:^{
            sourceLastTransform([self.sourceView layer]);
        } completion:^(BOOL finished) {
            completion(YES);
        }];
    }
}


#pragma mark - Required 3d Transform
void sourceFirstTransform(CALayer *layer) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1.0/ -500;
    t = CATransform3DTranslate(t, 0.0f, 0.0f,  0.0f);
    layer.transform = t;
}

void sourceLastTransform(CALayer *layer) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1.0/ -500;
    t = CATransform3DRotate(t, radianFromDegree(80), 0.0f,1.0f, 0.0f);
    t = CATransform3DTranslate(t, 0.0f, 0.0f,  -30.0f);
    t = CATransform3DTranslate(t,170.0f, 0.0f,  0.0f);
    layer.transform = t;
}

void destinationFirstTransform(CALayer * layer) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1.0 / -500;
    // Rotate 5 degrees within the axis of z axis
    t = CATransform3DRotate(t, radianFromDegree(5.0f), 0.0f,0.0f, 1.0f);
    // Reposition toward to the left where it initialized
    t = CATransform3DTranslate(t, 320.0f, -40.0f,  150.0f);
    // Rotate it -45 degrees within the y axis
    t = CATransform3DRotate(t, radianFromDegree(-45), 0.0f,1.0f, 0.0f);
    // Rotate it 10 degrees within thee x axis
    t = CATransform3DRotate(t, radianFromDegree(10), 1.0f,0.0f, 0.0f);
    layer.transform = t;
}

void destinationLastTransform(CALayer * layer) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1.0 / -500;
    // Rotate to 0 degrees within z axis
    t = CATransform3DRotate(t, radianFromDegree(0), 0.0f,0.0f, 1.0f);
    // Bring back to the final position
    t = CATransform3DTranslate(t, 0.0f, 0.0f,  0.0f);
    // Rotate 0 degrees within y axis
    t = CATransform3DRotate(t, radianFromDegree(0), 0.0f,1.0f, 0.0f);
    // Rotate 0 degrees within  x axis
    t = CATransform3DRotate(t, radianFromDegree(0), 1.0f,0.0f, 0.0f);
    layer.transform = t;
}


#pragma mark - Convert Degrees to Radian
double radianFromDegree(float degrees) {
    return (degrees / 180) * M_PI;
}


#pragma mark - ViewController Transition
+ (void)presentViewControllerTransition:(UIViewController *)destination source:(UIViewController *)source duration:(NSTimeInterval) duration completion:(void (^)(BOOL finished))completion {
    __block UIView *destinationView = [destination view];
    destinationView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:destinationView];
    
    MHNatGeoViewControllerTransition *natGeoTransition = [[MHNatGeoViewControllerTransition alloc] initWithSourceView:[source view] destinationView:[destination view] duration:duration];
    
    [natGeoTransition perform:^(BOOL finished) {
        [destinationView removeFromSuperview];
        destinationView = nil;
        [source presentViewController:destination animated:NO completion:^{
            if (completion)
                completion(YES);
        }];
    }];
}

+ (void)dismissViewController:(UIViewController *)viewController duration:(NSTimeInterval)duration completion:(void (^)(BOOL finished))completion {
    __block UIView *sourceView = [viewController.presentingViewController view];
    sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [sourceView setFrame:[[UIScreen mainScreen] applicationFrame]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:sourceView];
    
    MHNatGeoViewControllerTransition *natGeoTransition = [[MHNatGeoViewControllerTransition alloc] initWithSourceView:sourceView destinationView:[viewController view] duration:duration];
    
    [natGeoTransition setDismissing:YES];
    [natGeoTransition perform:^(BOOL finished) {
        if(finished){
            [viewController dismissViewControllerAnimated:NO completion:^{
                if (completion)
                    completion(YES);
            }];
        }
    }];
}

@end


#pragma mark - UIViewController(MHNatGeoViewControllerTransition)
@implementation UIViewController(MHNatGeoViewControllerTransition)

- (void)presentNatGeoViewController:(UIViewController *)viewController completion:(void (^)(BOOL finished))completion {
	[MHNatGeoViewControllerTransition presentViewControllerTransition:viewController source:self duration:0.6f completion:completion];
}

- (void)presentNatGeoViewController:(UIViewController *)viewController {
    [self presentNatGeoViewController:viewController completion:nil];
}

-(void)dismissNatGeoViewControllerWithCompletion:(void (^)(BOOL finished))completion {
    [MHNatGeoViewControllerTransition dismissViewController:self duration:0.5f completion:completion];
}

- (void)dismissNatGeoViewController {
    [self dismissNatGeoViewControllerWithCompletion:nil];
}

@end
