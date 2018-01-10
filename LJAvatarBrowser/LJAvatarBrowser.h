//
//  LJAvatarBrowser.h
//  ZhuanMCH
//
//  Created by txooo on 16/11/14.
//  Copyright © 2016年 领琾. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJAvatarBrowser;

@protocol LJAvatarBrowserDelegate<NSObject>

@optional

/**
 返回一个高清的url

 @param browser LJAvatarBrowser
 @param index 滚动下标
 @return urlString
 */
- (NSString *)photoBrowser:(LJAvatarBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

/**
 将要消失,用于得到最终需要变换的坐标

 @param index 当前显示的下标
 @return 最终要显示的源imageview
 */
- (UIImageView *)photoBrowserWillDissmissAtIndex:(NSInteger)index;

/**
 长按事件
 */
- (void)photoBrowserLongPressAtIndex:(NSInteger)index;

@end

@interface LJAvatarBrowser : UIView

/**
 需要预览的照片数组
 */
@property (nonatomic, retain) NSMutableArray *previewPhotos;

/**
 预览位置
 */
@property (nonatomic, assign) NSInteger previewIndex;

/**
 占位图
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 正在预览的父View
 */
@property (nonatomic, strong) UIView *containerView;

/**
 长按事件
 */
@property (nonatomic, copy) void (^longPressBlock)(NSInteger);
/**
 *	@brief	浏览头像
 *
 *	@param 	avatarImageView 	头像所在的imageView
 */
+ (LJAvatarBrowser *)showImageView:(UIImageView*)avatarImageView;
+ (LJAvatarBrowser *)showImageView:(UIImageView*)avatarImageView originUrl:(NSString *)url;

/**
 查看多placeholder @param previewPhotos 预览数组
 @param containerView 传入的控件的父View
 @param delegate 预览页
 @param previewIndex 预览位置
 @param placeholder 占位图
 */
+ (LJAvatarBrowser *)showPreviewPhotos:(NSMutableArray *)previewPhotos
                              delegate:(id)delegate
                         containerView:(UIView *)containerView
                          previewIndex:(NSInteger)previewIndex
                      placeholderImage:(UIImage *)placeholder;

@end

@interface LJAvatarBrowserImageView : UIImageView

- (void)lj_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completion:(void(^)(void))completion;

@end

@interface LJAvatarBrowserCell : UICollectionViewCell

- (void)lj_setImageWithURL:(id)url placeholderImage:(UIImage *)placeholder;
- (void)lj_setHighQualityImageURL:(NSString *)url;

@end
