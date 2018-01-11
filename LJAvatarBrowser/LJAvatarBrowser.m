//
//  LJAvatarBrowser.m
//  ZhuanMCH
//
//  Created by txooo on 16/11/14.
//  Copyright © 2016年 领琾. All rights reserved.
//

#import "LJAvatarBrowser.h"
#import <ImageIO/ImageIO.h>
#if __has_include(<UIImageView/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif

#define LJ_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define LJ_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

static CGFloat const itemSpace = 20.0;

@interface LJAvatarBrowserImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation LJAvatarBrowserImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds));
}

- (void)lj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completion:(void (^)(void))completion {
    [self.indicatorView startAnimating];
    
    __weak typeof(self) weakImageView = self;
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:SDWebImageRetryFailed
                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                       [weakImageView.indicatorView stopAnimating];
                       if (error) {
                           UILabel *label = [[UILabel alloc] init];
                           label.bounds = CGRectMake(0, 0, 160, 30);
                           label.center = CGPointMake(weakImageView.bounds.size.width * 0.5, weakImageView.bounds.size.height * 0.5);
                           label.text = @"图片加载失败";
                           label.font = [UIFont systemFontOfSize:16];
                           label.textColor = [UIColor whiteColor];
                           label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
                           label.layer.cornerRadius = 5;
                           label.clipsToBounds = YES;
                           label.textAlignment = NSTextAlignmentCenter;
                           [weakImageView addSubview:label];
                       } else {
                           weakImageView.image = image;
                       }
                       if (completion) {
                           completion();
                       }
                   }];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
        
        _indicatorView.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds));
    }
    return _indicatorView;
}

@end

@interface LJAvatarBrowserCell ()<UIScrollViewDelegate>

@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^longPressGestureBlock)(void);
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) LJAvatarBrowserImageView *imageView;

@end

@implementation LJAvatarBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(itemSpace/2.0, 0, LJ_SCREEN_WIDTH, LJ_SCREEN_HEIGHT)];
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.alwaysBounceVertical = NO;
        if (@available(ios 11.0,*)) {
            [_scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        [self addSubview:_scrollView];
        
        _imageView = [[LJAvatarBrowserImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [tap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.8;
        longPress.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)resizeSubviews {
    CGFloat width = LJ_SCREEN_WIDTH;
    CGFloat height = LJ_SCREEN_HEIGHT;
    CGFloat imageHeight = height;
    CGFloat imageWidth = width;
    _imageView.frame = CGRectMake(0, 0, imageWidth, imageWidth);
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > height / width) {
        imageHeight = floor(image.size.height / (image.size.width / width));
        _imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    } else {
        CGFloat imageScale = image.size.height / image.size.width;
        imageHeight = imageScale * width;
        if (imageHeight < 1 || isnan(imageHeight)) imageHeight = height;
        imageHeight = floor(imageHeight);
        _imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        _imageView.center = CGPointMake(width/2, height/2);
        if (imageScale < 0.5) {
            _scrollView.maximumZoomScale = 1.5 * LJ_SCREEN_HEIGHT / imageHeight;
        }else if (imageScale < 1) {
            _scrollView.maximumZoomScale = 2 * LJ_SCREEN_HEIGHT / imageHeight;
        }
    }
    if (imageHeight > height && imageHeight - height <= 1) {
        imageHeight = height;
        _imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    }
    _scrollView.contentSize = CGSizeMake(width, MAX(imageHeight, height));
    
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = imageHeight <= height ? NO : YES;
}

#pragma mark - UITapGestureRecognizer Event
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:_imageView];
        CGFloat newZoomScale = 2;
        CGFloat imageScale = _imageView.image.size.height / _imageView.image.size.width;
        if (imageScale < 1) {
            newZoomScale = LJ_SCREEN_HEIGHT / _imageView.frame.size.height;
        }
        CGFloat xsize = _scrollView.frame.size.width / newZoomScale;
        CGFloat ysize = _scrollView.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2.0, touchPoint.y - ysize/2.0, xsize, ysize) animated:YES];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.longPressGestureBlock) {
            self.longPressGestureBlock();
        }
    }
}

- (void)lj_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder {
    [_scrollView setZoomScale:1.0 animated:NO];
    if (!url) {
        return;
    }
    __weak typeof(self) weakCell = self;
    if ([url isKindOfClass:[UIImage class]]){
        UIImage *rImage = (UIImage *)url;
        self.imageView.image = rImage;
        [self resizeSubviews];
    }else if ([url isKindOfClass:[NSString class]]){
        NSString *rString = (NSString *)url;
        if ([rString rangeOfString:@"http"].location!=NSNotFound) {
            [self.imageView lj_setImageWithURL:[NSURL URLWithString:rString] placeholderImage:placeholder completion:^{
                [weakCell resizeSubviews];
            }];
        }else{
            self.imageView.image = [UIImage imageNamed:rString];
            [self resizeSubviews];
        }
        
    }else if ([url isKindOfClass:[NSURL class]]){
        NSURL *rURL = (NSURL *)url;
        [self.imageView lj_setImageWithURL:rURL placeholderImage:placeholder completion:^{
            [weakCell resizeSubviews];
        }];
    }
}

- (void)lj_setHighQualityImageURL:(NSString *)url placeholderImage:(UIImage *)placeholderImage {
    if (!url) {
        return;
    }
    __weak typeof(self) weakCell = self;
    NSURL *rURL = (NSURL *)url;
    [self.imageView lj_setImageWithURL:rURL placeholderImage:placeholderImage ? : self.imageView.image completion:^{
        [weakCell resizeSubviews];
    }];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@interface LJAvatarBrowser()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) CGRect avatarFrame;

@property (nonatomic, weak) id <LJAvatarBrowserDelegate> delegate;

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, assign) CGFloat zoomScale;

@property (nonatomic, assign) BOOL stopPreloading;

@property (nonatomic, assign) CGPoint startCenter;

@end

static UIImageView *avatarContainerView;
static UIWindow *window;

@implementation LJAvatarBrowser

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-itemSpace / 2.0, 0, LJ_SCREEN_WIDTH + itemSpace, LJ_SCREEN_HEIGHT) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[LJAvatarBrowserCell class] forCellWithReuseIdentifier:@"LJAvatarBrowserCellID"];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, LJ_SCREEN_HEIGHT - 50, LJ_SCREEN_WIDTH, 50)];
        _pageControl.hidesForSinglePage = YES;
        [self addSubview:_pageControl];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)singleTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:willDissmissAtIndex:)]) {
        self.containerView = [self.delegate photoBrowser:self willDissmissAtIndex:self.pageControl.currentPage];
    }
    
    if (CGRectIsNull(_avatarFrame) || CGRectIsEmpty(_avatarFrame)) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self resignWindow];
            [self removeFromSuperview];
        }];
        return;
    }
    LJAvatarBrowserCell *cell = (LJAvatarBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    
    avatarContainerView.hidden = NO;
    avatarContainerView.image = cell.imageView.image;
    avatarContainerView.frame = cell.imageView.frame;
    self.collectionView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor clearColor];
        avatarContainerView.frame = _avatarFrame;
    } completion:^(BOOL finished) {
        avatarContainerView = nil;
        [self resignWindow];
        [self removeFromSuperview];
    }];
}

- (void)resignWindow {
    [window resignKeyWindow];
    window = nil;
}

- (void)panGesture:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self];
    CGPoint point = [pan translationInView:self];
    LJAvatarBrowserCell *cell = (LJAvatarBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0]];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _startPoint = location;
            self.tag = 0;
            _zoomScale = cell.scrollView.zoomScale;
            _startCenter = cell.imageView.center;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (location.y - _startPoint.y < 0 && self.tag == 0) {
                return;
            }
            double percent = 1 - fabs(point.y) / self.frame.size.height;// 移动距离 / 整个屏幕
            double scalePercent = MAX(percent, 0.3);
            if (location.y - _startPoint.y < 0) {
                scalePercent = 1.0 * _zoomScale;
            }else {
                scalePercent = _zoomScale * scalePercent;
            }
            CGAffineTransform scale = CGAffineTransformMakeScale(scalePercent, scalePercent);
            cell.imageView.transform = scale;
            cell.imageView.center = CGPointMake(self.startCenter.x + point.x, self.startCenter.y + point.y);
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:scalePercent / _zoomScale];
            self.tag = 1;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGFloat height = cell.imageView.frame.size.height;
            if (point.y > height && cell.scrollView.zoomScale <= 1.0) {
                [self dismissFromCell:cell];
            }else {
                [self cancelPanFromCell:cell];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)dismissFromCell:(LJAvatarBrowserCell *)cell {
    [self singleTap];
}

- (void)cancelPanFromCell:(LJAvatarBrowserCell *)cell {
    __weak typeof(self) weakBrowser = self;
    CGAffineTransform scale = CGAffineTransformMakeScale(_zoomScale , _zoomScale);
    [UIView animateWithDuration:0.25 animations:^{
        cell.imageView.transform = scale;
        weakBrowser.backgroundColor = [UIColor blackColor];
        cell.imageView.center = weakBrowser.startCenter;
    }completion:^(BOOL finished) {
    }];
}

- (void)setPreviewPhotos:(NSMutableArray *)previewPhotos {
    _previewPhotos = previewPhotos;
    _pageControl.numberOfPages = self.previewPhotos.count;
    [self.collectionView reloadData];
}

- (void)setPreviewIndex:(NSInteger)previewIndex {
    _previewIndex = previewIndex;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(self.previewIndex) inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
    _avatarFrame = [containerView convertRect:containerView.bounds toView:[UIApplication sharedApplication].keyWindow];
}

- (CGRect)animationFrame {
    CGFloat width = LJ_SCREEN_WIDTH;
    CGFloat height = LJ_SCREEN_HEIGHT;
    CGFloat imageHeight = height;
    CGFloat imageWidth = width;
    CGRect frame = CGRectMake(0, 0, imageWidth, imageWidth);
    
    UIImage *image = avatarContainerView.image;
    if (image.size.height / image.size.width > height / width) {
        imageHeight = floor(image.size.height / (image.size.width / width));
        frame = CGRectMake(0, 0, imageWidth, imageHeight);
    } else {
        imageHeight = image.size.height / image.size.width * width;
        if (imageHeight < 1 || isnan(imageHeight)) imageHeight = height;
        imageHeight = floor(imageHeight);
        frame = CGRectMake(0, 0, imageWidth, imageHeight);
    }
    if (imageHeight > height && imageHeight - height <= 1) {
        imageHeight = height;
        frame = CGRectMake(0, 0, imageWidth, imageHeight);
    }
    return frame;
}

- (void)showAnimation {
    if (!_containerView) {
        self.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
        return;
    }

    avatarContainerView = [[UIImageView alloc] initWithFrame:_avatarFrame];
    
    if ([_containerView isKindOfClass:[UIImageView class]]) {
        avatarContainerView.image = [(UIImageView *)_containerView image];
        avatarContainerView.contentMode = _containerView.contentMode;
        avatarContainerView.clipsToBounds = _containerView.clipsToBounds;
        avatarContainerView.layer.cornerRadius = _containerView.layer.cornerRadius;
    }else {
        for (UIImageView *subView in _containerView.subviews) {
            if ([subView isKindOfClass:[UIImageView class]] && subView.image) {
                avatarContainerView.image = subView.image;
                avatarContainerView.contentMode = subView.contentMode;
                avatarContainerView.clipsToBounds = subView.clipsToBounds;
                avatarContainerView.layer.cornerRadius = subView.layer.cornerRadius;
            }
        }
    }
    if (self.placeholderImage && !avatarContainerView.image) {
        avatarContainerView.image = self.placeholderImage;
    }
    if (!avatarContainerView.image) {
        self.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
        return;
    }
    [self addSubview:avatarContainerView];
    
    CGRect frame = [self animationFrame];
    CGFloat cornerRadius = avatarContainerView.layer.cornerRadius;
    self.collectionView.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        avatarContainerView.frame = frame;
        if (frame.size.height < LJ_SCREEN_HEIGHT) {
            avatarContainerView.center = self.center;
        }
        if (cornerRadius > 0) {
            avatarContainerView.layer.cornerRadius = 0;
        }
    } completion:^(BOOL finished) {
        self.collectionView.hidden = NO;
        avatarContainerView.hidden = YES;
        if (cornerRadius > 0) {
            avatarContainerView.layer.cornerRadius = cornerRadius;
        }
        if (self.previewPhotos.count > 1) {
            self.avatarFrame = CGRectZero;
        }
    }];
}

+ (LJAvatarBrowser *)showImageView:(UIImageView *)avatarImageView {
    if (!avatarImageView.image) {
        return nil;
    }
    return [[self class] showPreviewPhotos:[@[avatarImageView.image] mutableCopy] delegate:nil containerView:avatarImageView previewIndex:0 placeholderImage:nil];
}

+ (LJAvatarBrowser *)showImageView:(UIImageView *)avatarImageView originUrl:(NSString *)url {
    if (!avatarImageView.image) {
        return nil;
    }
    return [[self class] showPreviewPhotos:[@[url] mutableCopy] delegate:nil containerView:avatarImageView previewIndex:0 placeholderImage:avatarImageView.image];
}

+ (LJAvatarBrowser *)showPreviewPhotos:(NSMutableArray *)previewPhotos delegate:(id)delegate containerView:(UIView *)containerView previewIndex:(NSInteger)previewIndex placeholderImage:(UIImage *)placeholder {
    LJAvatarBrowser *browser = [[LJAvatarBrowser alloc] initWithFrame:[UIScreen mainScreen].bounds];
    browser.previewPhotos = previewPhotos;
    browser.previewIndex = previewIndex;
    browser.placeholderImage = placeholder;
    browser.containerView = containerView;
    browser.delegate = delegate;
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert;
    [window makeKeyAndVisible];
    [window addSubview:browser];
    [browser showAnimation];
    return browser;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = LJ_SCREEN_WIDTH + 20;
    int page = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_previewPhotos) {
        return _previewPhotos.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LJAvatarBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LJAvatarBrowserCellID" forIndexPath:indexPath];
    __weak typeof(self) weakBrowser = self;
    cell.singleTapGestureBlock = ^{
        [weakBrowser singleTap];
    };
    cell.longPressGestureBlock = ^{
        if (weakBrowser.longPressBlock) {
            weakBrowser.longPressBlock(indexPath.row);
        }
        if (weakBrowser.delegate && [weakBrowser.delegate respondsToSelector:@selector(photoBrowser:longPressAtIndex:)]) {
            [weakBrowser.delegate photoBrowser:self longPressAtIndex:indexPath.row];
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *placeHolderImage = self.placeholderImage;
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        UIImage *image = [self.delegate photoBrowser:self placeholderImageForIndex:indexPath.row];
        if (image) {
            placeHolderImage = image;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:originImageURLForIndex:)]) {
        NSString *highQualityImageURL = [self.delegate photoBrowser:self originImageURLForIndex:indexPath.row];
        if (highQualityImageURL) {
            LJAvatarBrowserCell *ljCell = (LJAvatarBrowserCell *)cell;
            [ljCell lj_setHighQualityImageURL:highQualityImageURL placeholderImage:placeHolderImage];
        }
    }else {
        if (self.previewPhotos.count > indexPath.row) {
            LJAvatarBrowserCell *ljCell = (LJAvatarBrowserCell *)cell;
            [ljCell lj_setImageWithURL:self.previewPhotos[indexPath.row] placeholderImage:_placeholderImage];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(LJ_SCREEN_WIDTH + itemSpace, LJ_SCREEN_HEIGHT);
}

@end
