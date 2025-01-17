//
//  JMReadItemView.swift
//  JMEpubReader
//
//  Created by JunMing on 2021/3/29.
//

import UIKit
import ZJMKit

final class JMReadItemView: JMBaseView {
    public var margin: CGFloat = 5
    public var models = [JMReadMenuItem]()
    final public func updateViews(_ items: [JMReadMenuItem]) {
        self.models = items
        for (index, model) in items.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = index + 200
            addSubview(btn)
            configItem(btn, model)
            
            btn.jmAddAction { [weak self](sender) in
                if let items = self?.models {
                    for item in items {
                        if item === model {
                            model.isSelect.toggle()
                        }else {
                            item.isSelect = false
                        }
                    }
                }
                self?.jmRouterEvent(eventName: model.event, info: model)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = CGFloat(self.subviews.count)
        if margin <= 0 && models.count > 0 { // margin 设置小于0认为宽高44
            let margin = (self.jmWidth - CGFloat(models.count * 30)) / CGFloat(models.count)
            let width = (self.jmWidth - (count+1) * margin) / count
            for (index, view) in self.subviews.enumerated() {
                view.frame = CGRect.Rect(margin + (margin + width) * CGFloat(index), jmHeight/2-15, 30, 30)
            }
        }else{
            let width = (self.bounds.size.width - (count+1) * margin) / count
            for (index, view) in self.subviews.enumerated() {
                view.frame = CGRect.Rect( margin + (margin + width) * CGFloat(index), 0, width, self.jmHeight)
            }
        }
    }
    
    func configItem(_ btn: UIButton, _ model: JMReadMenuItem) {
        switch model.type {
        case .BkgColor:
            if let colorStr = model.bkgColor {
                btn.layer.cornerRadius = 15
                btn.backgroundColor = UIColor(rgba: colorStr)
                model.didSelectAction = { select in
                    btn.layer.borderWidth = select ? 1 : 0
                    btn.layer.borderColor = UIColor.menuTintColor.cgColor
                }
            }
            
        case .MainBottom:
            btn.setTitle(model.title, for: .normal)
            btn.setTitleColor(UIColor.jmRGB(31, 31, 31), for: .normal)
            btn.titleLabel?.font = UIFont.jmRegular(10)
            btn.setImage(model.image?.image?.origin, for: .normal)
            
        case .TopLeft, .TopRight:
            btn.setImage(model.image?.image?.origin, for: .normal)
            
        case .PageFont, .PageFlip, .PlayRate, .PlayStyle:
            btn.setTitleColor(UIColor.menuTextColor, for: .normal)
            btn.setTitle(model.title, for: .normal)
            model.didSelectAction = { select in
                btn.setTitleColor(select ? UIColor.menuSelColor : UIColor.menuTextColor, for: .normal)
                btn.titleLabel?.font = select ? UIFont.jmMedium(20) : UIFont.jmRegular(17)
            }
        case .PageLight:
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 0.5
            btn.layer.borderColor = UIColor.menuTextColor.cgColor
            btn.setTitleColor(UIColor.menuTextColor, for: .normal)
            btn.setTitle(model.title, for: .normal)
            model.didSelectAction = { select in
                btn.setTitleColor(select ? UIColor.menuSelColor : UIColor.menuTextColor, for: .normal)
                btn.titleLabel?.font = select ? UIFont.jmMedium(20) : UIFont.jmRegular(17)
            }
        case .PlayOrPause:
            btn.setImage(model.image?.image?.origin, for: .normal)
            if model.identify == .PlayOrPause {
                model.didSelectAction = { select in
                    let imageStr = select ? "epub_pause" : "epub_play_p"
                    btn.setImage(imageStr.image?.origin, for: .normal)
                }
            }
        case .CharterTag:
            btn.setTitle(model.title, for: .normal)
            btn.setTitleColor(model.isSelect ? UIColor.menuSelColor : UIColor.menuTextColor, for: .normal)
            btn.titleLabel?.font = model.isSelect ? UIFont.jmMedium(20) : UIFont.jmRegular(17)
            model.didSelectAction = { select in
                btn.setTitleColor(select ? UIColor.menuSelColor : UIColor.menuTextColor, for: .normal)
                btn.titleLabel?.font = select ? UIFont.jmMedium(20) : UIFont.jmRegular(17)
            }
        case .nonetype:
            print("")
        }
    }
    
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { fatalError("⚠️⚠️⚠️ Error") }
}
