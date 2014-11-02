//
//  ImageViewController.m
//  TopPlaces
//
//  Created by Brian Li on 8/28/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadSpinner;
@end

@implementation ImageViewController

#pragma mark - Properties

// lazy instantiate scroll view
- (UIScrollView *) scrollView {
    if (!_scrollView && self.image) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = self.image ? self.image.size:CGSizeZero;

        [self setScrollViewScaleToSize:self.image.size];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    if ([self.scrollView.subviews containsObject:self.imageView]) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    if ([self.view.subviews containsObject:self.scrollView]) {
        [self.scrollView removeFromSuperview];
    }
    self.scrollView = nil;
    [self startDownloadingImage];
}

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc]init];
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    [self.loadSpinner stopAnimating];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.zoomScale = 1.0;
    [self setImageToFit];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (UIImage *)image {
    return self.imageView.image;
}

#pragma mark - download

- (void)startDownloadingImage {
    [self.loadSpinner startAnimating];
    // start downloading in another queue, and once complete, assign the downloaded file to imageView
    if (self.imageURL) {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.imageURL];
        // configuration with out delegate queue => not on may queue
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task =
            [session downloadTaskWithRequest:imageRequest
                           completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                    if (!error) {
                                        if (imageRequest.URL == self.imageURL) {
                                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                            [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                                        }
                                    }
                                }];
        [task resume];
    }
}

#pragma mark - delegates
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setScrollViewScaleToSize:self.scrollView.contentSize];
}

#pragma mark - update view

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDisableBackground:)];
    [self.view addGestureRecognizer:tapOnce];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.image) {
        [self setImageToFit];
        [self setScrollViewScaleToSize:self.scrollView.contentSize];
    }
}

- (void)setImageToFit {
    // size of the scrollview that is being scrolled over (affected by zoom)
    CGFloat contentWidth = self.scrollView.contentSize.width;
    CGFloat contentHeight = self.scrollView.contentSize.height;
    // available size of view to display content
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;

    // ratio of the entire content size vs the size of the available view (used to fit the content inside the available view)
    CGFloat widthRatio = viewWidth/contentWidth;
    CGFloat heightRatio = viewHeight/contentHeight;
    
    // min zoom is set to fit the entire picture on the page
    self.scrollView.minimumZoomScale = MIN(widthRatio,heightRatio)*self.scrollView.zoomScale;
    // max zoom is equal to the zoom when the view is completely filled x2
    self.scrollView.maximumZoomScale = MAX(widthRatio,heightRatio)*self.scrollView.zoomScale * 2;
    
    self.scrollView.zoomScale = MAX(self.scrollView.minimumZoomScale, MIN(self.scrollView.zoomScale, self.scrollView.maximumZoomScale));

}

- (void)setScrollViewScaleToSize:(CGSize)bound {
    // get ratio of the image size to the screen
    CGFloat widthRatio = self.view.bounds.size.width/bound.width;
    CGFloat heightRatio = self.view.bounds.size.height/bound.height;
    CGFloat imageAspectRatio = self.image.size.height/self.image.size.width;
    CGRect frame;
    // set the bounds to be a scalar of the image size to fit inside view
    if (widthRatio > heightRatio) {
        frame.size = CGSizeMake(bound.width, self.view.bounds.size.height);
        if (frame.size.width > self.view.bounds.size.width) {
            frame.size.width = self.view.bounds.size.width;
        }
        if (bound.height < self.view.bounds.size.height) {
            frame.size.width = self.view.bounds.size.height/imageAspectRatio;
        }

    } else {
        frame.size = CGSizeMake(self.view.bounds.size.width, bound.height);
        if (frame.size.height > self.view.bounds.size.height) {
            frame.size.height = self.view.bounds.size.height;
        }
        if (bound.width < self.view.bounds.size.width) {
            frame.size.height = self.view.bounds.size.width*imageAspectRatio;
        }
    }
    // center the scroll view in the view
    frame.origin = CGPointMake((self.view.bounds.size.width-frame.size.width)/2,(self.view.bounds.size.height-frame.size.height)/2);
    // assign the created bound
    self.scrollView.frame = frame;

}

#pragma mark - UIGestureRecognizer

- (IBAction)tapToDisableBackground:(UITapGestureRecognizer *)gesture {
    self.loadSpinner.color = self.view.backgroundColor;
    [UIView animateWithDuration:0.4 animations:^{
        [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden];
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
        if (self.navigationController.navigationBar.hidden) {
            self.view.backgroundColor = [UIColor blackColor];
        }
        else{
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }];
}

- (BOOL) prefersStatusBarHidden {
    return self.navigationController.navigationBar.hidden;
}

#pragma mark - UISplitViewControllerDelegate
- (void) awakeFromNib {
    self.splitViewController.delegate = self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    NSLog(@"activate");
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
}
@end
