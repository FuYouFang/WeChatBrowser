//
//  TUIMessageCellLayout.swift
//  WeChatBrowser
//
//  Created by fuyoufang on 2020/4/9.
//  Copyright © 2020 fuyoufang. All rights reserved.
//

import Foundation

/**
 *  本文件声明了5个类，分别为
 *  1、TUIMessageCellLayout
 *  2、TIncomingCellLayout
 *  3、TOutgoingCellLayout
 *  4、TIncomingVoiceCellLayout
 *  5、TOutgoingVoiceCellLayout
 *  其中，类2、3继承自类1。类4继承自类2。类5继承自类3。
 *  本文件通过此种继承关系，达到分层细化消息单元布局的效果。
 *  您可以通过本布局，修改全体消息的头像大小与位置，调整消息/昵称的字体和颜色以及气泡内边距等布局特征。
 *  您可以通过修改本类的子类，达到修改某一特定消息布局的效果。
 *  当您想对自定义消息添加布局时，也可声明一个继承自本布局的子类，并对子类进行修改，以针对自定义消息进行特殊 UI 布局。
 */

/**
 * 【模块名称】TUIMessageCellLayout
 * 【功能说明】消息单元布局
 *  用于实现个类消息单元（文本、语音、视频、图像、表情等）的 UI 布局。
 *  布局可以使得 UI 风格统一，且易于管理与修改。
 *  当您想对 TUIKit 中的界面布局作出调整时，您可以对此布局中的对应属性进行修改。
 */


class TUIMessageCellLayout {
    /**
     * 消息边距
     */
    var messageInsets: NSEdgeInsets = .zero
    /**
     * 气泡内部内容边距
     */
    var bubbleInsets: NSEdgeInsets = .zero
    /**
     * 头像边距
     */
    var avatarInsets: NSEdgeInsets = .zero
    /**
     * 头像大小
     */
    var avatarSize: CGSize = .zero
    
    
    init() {
        self.avatarSize = CGSize(width: 40, height: 40)
    }
    
    /**
     *  接收消息布局
     */
    static var incommingMessageLayout = TUIMessageCellLayout()
    
    /**
     *  发送消息布局
     */
    static var outgoingMessageLayout = TUIMessageCellLayout()
    
    /**
     *  获取系统消息布局
     */
    static var systemMessageLayout = TUISystemMessageCellLayout()
    
    
    /**
     *  文本消息（接收）布局
     */
    static var incommingTextMessageLayout = TUIIncommingTextCellLayout()
    
    /**
     *  文本消息（发送）布局
     */
    static var outgoingTextMessageLayout = TUIOutgoingTextCellLayout()
}


/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIMessageCell 的细化布局
//
/////////////////////////////////////////////////////////////////////////////////
/**
 * 【模块名称】TIncomingCellLayout
 * 【功能说明】接收单元布局
 *  用于接收消息时，消息单元的默认布局。
 */
class TIncommingCellLayout: TUIMessageCellLayout {
    
    override init() {
        super.init()
        self.avatarInsets = NSEdgeInsets(top: 3, left: 8, bottom: 1, right: 0)
        
        self.messageInsets = NSEdgeInsets(top: 3, left: 8, bottom: 1, right: 0)
    }
}

/**
 * 【模块名称】TOutgoingCellLayout
 * 【功能说明】发送单元布局
 *  用于发送消息时，消息单元的默认布局。
 */
class TOutgoingCellLayout: TUIMessageCellLayout {
    override init() {
        super.init()
        self.avatarInsets = NSEdgeInsets(top: 3, left: 0, bottom: 1, right: 8)
        
        self.messageInsets = NSEdgeInsets(top: 3, left: 0, bottom: 1, right: 8)
    }
}


/**
 * 【模块名称】TIncomingVoiceCellLayout
 * 【功能说明】语音接收单元布局
 *  用于接收语音消息时，消息单元的默认布局。
 */
class TIncommingVoiceCellLayout : TIncommingCellLayout {
    
    override init() {
        super.init()
        self.bubbleInsets = NSEdgeInsets(top: 14, left: 20, bottom: 20, right: 22)
    }
}

/**
 * 【模块名称】TOutgoingVoiceCellLayout
 * 【功能说明】语音发送单元布局
 *  用于发送语音消息时，消息单元的默认布局。
 */
class TOutgoingVoiceCellLayout: TOutgoingCellLayout {
    
    override init() {
        super.init()
        self.bubbleInsets = NSEdgeInsets(top: 14, left: 22, bottom: 20, right: 20)
    }
}

