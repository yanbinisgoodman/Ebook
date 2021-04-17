//
//  JMProtocol.swift
//  JMEpubReader
//
//  Created by JunMing on 2021/2/1.
//

import Foundation

@objc public protocol JMReadProtocol {
    /// 提供一个自定义页面展示自定义内容
    func currentReadVC(_ forward: Bool) -> UIViewController?
}

// MARK: -- 图书数据模型
public class JMEpubWapper<T> {
    let item: T
    init(_ item: T) {
        self.item = item
    }
}


public protocol VMProtocol {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

public protocol ModelType {
    associatedtype Item
    var items: [Item] { get }
    init(items: [Item])
}

protocol ApiProtocol {
    associatedtype ApiType
    static func currApiType(index: Int) -> ApiType
}

public struct JMWapper<T,W> {
    var t: T?
    var w: W?
    init(_ tValue: T?, _ wValue: W?) {
        self.t = tValue
        self.w = wValue
    }
}
