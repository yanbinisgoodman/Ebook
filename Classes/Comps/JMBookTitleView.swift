//
//  JMBookTitleView.swift
//  JMEpubReader
//
//  Created by JunMing on 2021/4/17.
//

import UIKit
import ZJMKit

final class JMBookTitleView: JMBaseView {
    var title = UILabel()
    private let back = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
        addSubview(back)
        back.setImage("ebook_back".image?.origin, for: .normal)
        back.jmAddAction { [weak self](_) in
            self?.jmRouterEvent(eventName: kEventNameMenuActionBack, info: nil)
        }
        back.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.equalTo(self).offset(14)
            make.centerY.equalTo(snp.centerY)
        }
        
        title.text = "第十章 爱在海角天涯"
        title.jmConfigLabel(font: UIFont.jmAvenir(13), color: UIColor.jmRGBValue(0x999999))
        title.snp.makeConstraints { (make) in
            make.left.equalTo(back.snp.right).offset(5)
            make.height.equalTo(12)
            make.centerY.equalTo(snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
