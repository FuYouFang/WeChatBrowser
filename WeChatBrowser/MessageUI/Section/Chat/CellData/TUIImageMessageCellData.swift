//
//  TUIImageMessageCellData.swift
//  WeChatBrowser
//
//  Created by fuyoufang on 2020/4/13.
//  Copyright © 2020 fuyoufang. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

/**
 *  图像类别枚举
 */
enum TUIImageType {
    case thumb //缩略图
    case large //大图
    case origin //原图
}

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIImageItem
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  TUIIamgeItem
 *  TUI 图像项目，包含图像的各种信息。
 */
class TUIImageItem {
    
    /**
     *  图片 ID，内部标识，可用于外部缓存key
     */
    var uuid: String?
    
    /**
     *  图像 url
     */
    var url: String?
    
    /**
     *  图像大小（在UI上的显示大小）
     */
    var size: CGSize?
    
    /**
     *  图像类别
     *  TImage_Type_Thumb：缩略图
     *  TImage_Type_Large：大图
     *  TImage_Type_Origin：原图
     */
    var type: TUIImageType = .thumb
    var path: String?
}
/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIImageMessageCellData
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 【模块名称】TUIImageMessageCellData
 * 【功能说明】用于实现聊天窗口中的图片气泡，包括图片消息发送进度的展示也在其中。
 *  同时，该模块已经支持“缩略图”、“大图”和“原图”三种不同的类型，并已经处理好了在合适的情况下展示相应图片类型的业务逻辑：
 *  1. 缩略图 - 默认在聊天窗口中看到的是缩略图，体积较小省流量
 *  2. 大图 - 如果用户点开之后，看到的是分辨率更好的大图
 *  3. 原图 - 如果发送方选择发送原图，那么接收者会看到“原图”按钮，点击下载到原尺寸的图片
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
class TUIImageMessageCellData: TUIMessageCellData {
    /**
     *  图像缩略图
     */
    var thumbImage = BehaviorRelay<NSImage?>(value: nil)

    /**
     *  图像原图
     */
    var originImage = BehaviorRelay<NSImage?>(value: nil)

    /**
     *  图像大图
     */
    var largeImage = BehaviorRelay<NSImage?>(value: nil)
    
    /**
     *  图像长度（大小）
     */
    var length: Int = 0
    
    /**
     *  图像项目集
     *
     *  @note items中通常存放三个imageItem，分别为 thumb（缩略图）、origin（原图）、large（大图），方便根据根据需求灵活获取图像
     *
     */
    var items = [TUIImageItem]()
    
    /**
     *  缩略图加载进度
     */
    var thumbProgress = BehaviorRelay<UInt>(value: 0)

    /**
     *  原图加载进度
     */
    var originProgress = BehaviorRelay<UInt>(value: 0)

    /**
     *  大图加载进度
     */
    var largeProgress = BehaviorRelay<UInt>(value: 0)

    private var isDownloading: Bool = false
    
    /**
     *  获取图像路径
     *  同时传入 isExist 指针，能够同时改变 isExist 标识。成功获取图像 path 后，isExist 赋值为 YES，否则赋值为 NO。
     *
     *  @param type 图像类型
     *  @param isExist 是否在本地存在
     *
     *  @return 返回路径的字符串形式。
     */
    func getImagePath(type: TUIImageType) -> String? {
        
        //查看本地是否存在
        guard let tImageItem = getTImageItem(type: type),
            let path = tImageItem.path else {
            return nil
        }
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if !isDir.boolValue {
                return path
            }
        }
        
        return nil
    }
    
    
    /**
     *  获取图像
     *  本函数整合调用了 IM SDK，通过 SDK 提供的接口在线获取图像。
     *  1、下载前会判断图像是否在本地，若不在本地，则在本地直接获取图像。
     *  2、当图像不在本地时，通过 IM SDK 中 TIMImage 提供的 getImage 接口在线获取。
     *  3-1、下载进度百分比则通过接口回调的 progress（代码块）参数进行更新。
     *  3-2、代码块具有 curSize 和 totalSize 两个参数，由回调函数维护 curSize，然后通过 curSize * 100 / totalSize 计算出当前进度百分比。
     *  4-1、图像消息中存放的格式为 TIMElem，图片列表需通过 TIMElem.imageList 获取，在 imalgelist 中，包含了原图、大图与缩略图，可通过 imageType 进一步获取。
     *  4-2、通过 SDK 接口获取的图像为二进制文件，需先进行解码，转换为 CGIamge 进行解码操作后包装为 UIImage 才可使用。
     *  5、下载成功后，会生成图像 path 并存储下来。
     */
    func downloadImage(type: TUIImageType) {
        guard let path = getImagePath(type: type) else {
            return
        }
        guard let data = FileManager.default.contents(atPath: path) else {
            return
        }
        
        guard let image = NSImage(data: data) else {
            return
        }
        
        switch type {
        case .large:
            largeImage.accept(image)
        case .origin:
            originImage.accept(image)
        case .thumb:
            thumbImage.accept(image)
        }
    }
    
    func getTImageItem(type: TUIImageType) -> TUIImageItem? {
        for item in self.items {
            if item.type == type {
                return item
            }
        }
        return nil
    }
    func getIMImage(type: TUIImageType) -> TIMImage? {
        guard let imMsg = self.innerMessage else {
            return nil
        }
        for elem in imMsg.elems {
            if let imImageElem = elem as? TIMImageElem {
                guard let imageList = imImageElem.imageList else {
                    continue
                }
                for imImage in imageList {
                    if type == .thumb && imImage.type == .THUMB {
                        return imImage
                    } else if type == .origin && imImage.type == .ORIGIN {
                        return imImage
                    } else if type == .large && imImage.type == .LARGE {
                        return imImage
                    }
                    break
                }
            }
        }
        return nil
    }
    
    override func contentSize() -> CGSize {
        return CGSize(width: 100, height: 100)
//        var size = CGSize.zero
//        var isDir: ObjCBool = false
//        if let path = self.path {
//            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
//                if !(isDir.boolValue) {
////                    size = NSImage
//                }
//            }
//        }
        
        
        //        CGSize size = CGSizeZero;
        //        BOOL isDir = NO;
        //        if(![self.path isEqualToString:@""] &&
        //           [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDir]){
        //            if(!isDir){
        //                size = [UIImage imageWithContentsOfFile:self.path].size;
        //            }
        //        }
        //
        //        if (CGSizeEqualToSize(size, CGSizeZero)) {
        //            for (TUIImageItem *item in self.items) {
        //                if(item.type == TImage_Type_Thumb){
        //                    size = item.size;
        //                }
        //            }
        //        }
        //        if (CGSizeEqualToSize(size, CGSizeZero)) {
        //            for (TUIImageItem *item in self.items) {
        //                if(item.type == TImage_Type_Large){
        //                    size = item.size;
        //                }
        //            }
        //        }
        //        if (CGSizeEqualToSize(size, CGSizeZero)) {
        //            for (TUIImageItem *item in self.items) {
        //                if(item.type == TImage_Type_Origin){
        //                    size = item.size;
        //                }
        //            }
        //        }
        //
        //        if(CGSizeEqualToSize(size, CGSizeZero)){
        //            return size;
        //        }
        //        if(size.height > size.width){
        //            size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
        //            size.height = TImageMessageCell_Image_Height_Max;
        //        } else {
        //            size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
        //            size.width = TImageMessageCell_Image_Width_Max;
        //        }
        //        return size;
    }
}
