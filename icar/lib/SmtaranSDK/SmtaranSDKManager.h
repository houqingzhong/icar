//
//  SDKManager.h
//  SDKManager
//
//  Created by fwang on 15/4/19.
//  Copyright (c) 2015年 fwang. All rights reserved.
//

#define MS_PublishID        @"6ejpOoZ9ZPPaUNezbg=="
#define MS_tuijian_Banner @"d3Z3pBjg+m1Ezkkt8EVgSvtR"//推荐页横幅广告位
#define MS_setting_Banner @"YWBhsg727HtS2F875mx2XO1H"//设置页横幅广告位
#define MS_class_Banner @"//7/LJBocuXMRsGlePPownPZ"//分类页横幅广告位
#define MS_Poster @"x8bHFKhQSt30fvmdQPfQ+kvp"//开机广告位


#define MS_Audit_Flag   @"IOS_AppStore_V2.0"


@interface SmtaranSDKManager : NSObject

/**
 *  @brief 获得广告管理单例
 */
+ (SmtaranSDKManager *)getInstance;

/**
 *  @brief 设置publisherID
 *  @param publisherID 开发者平台分配给应用的id
 */
- (void)setPublisherID:(NSString *)publisherID;
/**
 *  @brief 设置审核标识，审核标识区分大小写
 *  @param 状态标识字段是为了标识不同渠道不同版本的不同审核状态而设置
 */
- (void)setPublisherID:(NSString *)publisherID auditFlag:(NSString *)flag;
/**
 *  @brief 设置应用分发渠道
 *  @param deployChannel 分发渠道名称
 */
- (void)setPublisherID:(NSString *)publisherID withChannel:(NSString *)channel auditFlag:(NSString *)flag;
/**
 *  @brief 设置是否在应用内打开app store（使用store kit）
 *  @param flag YES在应用内打开，否则在应用外打开
 *  @note  在IOS7下，只支持横屏的应用内打开app store组件，应用会崩溃
 */
- (void)showStoreInApp:(BOOL)flag;

/**
 *  @brief 设置是否在应用内打开GPS
 *  @param flag YES在应用内打开，NO关闭
 *  @note  默认GPS是打开状态,需要在setPublisherID之前调用
 */
- (void)setEnableLocation:(BOOL)flag;
@end
