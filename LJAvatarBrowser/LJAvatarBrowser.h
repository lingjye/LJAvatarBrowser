//
//  LJAvatarBrowser.h
//  ZhuanMCH
//
//  Created by txooo on 16/11/14.
//  Copyright © 2016年 领琾. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LJAvatarBrowser : NSObject
/**
 *	@brief	浏览头像
 *
 *	@param 	avatarImageView 	头像所在的imageView
 */
+(void)showImageView:(UIImageView*)avatarImageView;
+(void)showImageView:(UIImageView*)avatarImageView originUrl:(NSString *)url;
@end
