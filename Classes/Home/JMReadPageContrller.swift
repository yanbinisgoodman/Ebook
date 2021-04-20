//
//  JMReadPageContrller.swift
//  JMEpubReader
//
//  Created by JunMing on 2021/2/3.
//

import UIKit
import ZJMKit
import SnapKit

public class JMReadPageContrller: JMBaseController {
    public weak var delegate: JMReadProtocol?
    // 数据源
    private var dataSource = [JMReadController(), JMReadController()]
    let bookModel: JMBookModel
    let topLeft = JMReadItemView()
    let topRight = JMReadItemView()
    let bottom = JMReadItemView()
    
    let set = JMMenuSetView() // 设置
    let light = JMMenuLightView() // 亮度
    let play = JMMeunPlayVIew() // 播放
    
    let topContainer = UIView() // 亮度
    let bottomContainer = UIView() // 亮度
    let chapter = JMChapterView() // 左侧目录
    
    let bookTitle = JMBookTitleView() // 标题
    let battery = JMBatteryView() // 电池
    
    let margin: CGFloat = 10
    let s_width = UIScreen.main.bounds.size.width
    
    // 第N章-N小节-N页，表示当前读到的位置
    public let cPage = JMBookIndex(0, 0)
    let speech: JMSpeechParse
    
    /// 状态
    var currType = JMMenuViewType.ViewType_NONE
    
    public override var prefersStatusBarHidden: Bool {
        return currType == .ViewType_NONE
    }
    
    // 翻页控制器
    private var pageVC: UIPageViewController?
    
    // 调用初始化
    public init (_ bookModel: JMBookModel) {
        self.bookModel = bookModel
        let speechModel = JMSpeechModel()
        self.speech = JMSpeechParse(speechModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.jmHexColor(JMBookConfig.share.bkgColor)
        setupPageVC()
        setupviews()
        loadDats()
        setupFristPageView()
        registerMenuEvent()
        registerSubMenuEvent()
    }
    
    private func setupFristPageView() {
        if let page = bookModel.currPage(),
           let pageView = unusePageView() {
            pageView.loadPage(page)
            pageVC?.setViewControllers([pageView], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    private func nextPageView(_ isNext: Bool) -> JMReadController? {
        if let page = isNext ? bookModel.nextPage() : bookModel.prevPage() {
            let pageView = unusePageView()
            pageView?.loadPage(page)
            return pageView
        }else {
            print("😀😀😀After 字符长度为空")
            return nil
        }
    }
    
    // 查找未使用的View
    private func unusePageView() -> JMReadController? {
        for pageView in dataSource {
            if !(pageVC?.viewControllers?.contains(pageView) ?? false) {
                return pageView
            }
        }
        return nil
    }

    private func setupPageVC() {
        var style: UIPageViewController.TransitionStyle = .scroll
        var orientation: UIPageViewController.NavigationOrientation = .horizontal
        if JMBookConfig.share.flipType == .HoriCurl {
            style = .pageCurl
            orientation = .horizontal
        }else if JMBookConfig.share.flipType == .VertCurl {
            style = .pageCurl
            orientation = .vertical
        }else if JMBookConfig.share.flipType == .HoriScroll {
            style = .scroll
            orientation = .horizontal
        }else if JMBookConfig.share.flipType == .VertScroll {
            style = .scroll
            orientation = .vertical
        }
        
        let pageVC = UIPageViewController(transitionStyle: style, navigationOrientation: orientation, options: nil)
        pageVC.dataSource = self
        pageVC.delegate = self
        view.insertSubview(pageVC.view, at: 0)
        addChildViewController(pageVC)
        self.pageVC = pageVC
    }
    
    deinit {
        battery.fireTimer()
    }
}

// TODO: -- PageView Delegate --
extension JMReadPageContrller: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // 往回翻页时触发
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = delegate?.currentReadVC(false) {
            return vc
        }else {
            print("😀😀😀Before")
            return nextPageView(false)
        }
    }
    
    // 往后翻页时触发
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = delegate?.currentReadVC(true) {
            return vc
        }else {
            print("😀😀😀After")
            return nextPageView(true)
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            print("😀😀😀completed")
            battery.progress.text = bookModel.readRate()
            bookTitle.title.text = bookModel.currTitle()
        }else {
            hideWithType()
//            print("😀😀😀completed none")
//            if let page = previousViewControllers.first as? JMReadController {
//                bookModel.indexPath.chapter = page.currPage.chapter
//                bookModel.indexPath.section = page.currPage.section
//                bookModel.indexPath.page = page.currPage.page
//            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        print("😀😀😀will")
    }
}

// TODO: -- Register Event --
extension JMReadPageContrller {
    func registerMenuEvent() {
        jmRegisterEvent(eventName: kEventNameMenuActionTapAction, block: { [weak self](_) in
            if self?.currType == .ViewType_NONE {
                self?.showWithType(type: .ViewType_TOP_BOTTOM)
            }else {
                self?.hideWithType()
            }
            self?.setNeedsStatusBarAppearanceUpdate()
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionTapLeft, block: { [weak self](_) in
            if self?.currType == .ViewType_NONE {
                print("点击左侧1/4翻页")
            }else {
                self?.hideWithType()
            }
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionTapRight, block: { [weak self](_) in
            if self?.currType == .ViewType_NONE {
                print("点击右侧1/4翻页")
            }else {
                self?.hideWithType()
            }
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionBack, block: { [weak self](_) in
            self?.battery.fireTimer()
            self?.navigationController?.popViewController(animated: true)
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionShare, block: { (_) in
            
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionShareWifi, block: { (_) in
            
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionMore, block: { [weak self](_) in
            if let page = self?.bookModel.currPage(), page.attribute.length > 10 {
                self?.speech.readImmediately(page.attribute, clear: false)
            }
            
        }, next: false)
                
        jmRegisterEvent(eventName: kEventNameMenuActionDayOrNight, block: { [weak self](model) in
            if let item = model as? JMReadMenuItem {
                self?.view.backgroundColor = item.isSelect ? UIColor.jmRGB(60, 60, 60) : UIColor.white
            }
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionListenBook, block: { [weak self](_) in
            self?.hideWithType()
            self?.showWithType(type: .ViewType_PLAY)
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionBrightness, block: { [weak self](_) in
            self?.hideWithType()
            self?.showWithType(type: .ViewType_LIGHT)
        }, next: false)
        
        jmRegisterEvent(eventName: kEventNameMenuActionSettingMore, block: { [weak self](_) in
            self?.hideWithType()
            self?.showWithType(type: .ViewType_SET)
        }, next: false)
        
        // 滑动滑杆转跳
        jmRegisterEvent(eventName: kEventNameMenuFontSizeSlider, block: { [weak self](value) in
            if let charpter = value as? JMBookCharpter {
                self?.hideWithType()
                self?.bookModel.indexPath.chapter = charpter.location.chapter
                self?.bookModel.indexPath.page = 0
                if let page = self?.bookModel.currPage(),
                   let pageView = self?.unusePageView() {
                    pageView.loadPage(page)
                    self?.pageVC?.setViewControllers([pageView], direction: .forward, animated: true, completion: nil)
                }
            }
        }, next: false)
        
        // 显示左侧目录
        jmRegisterEvent(eventName: kEventNameMenuActionBookCatalog, block: { [weak self](_) in
            if let tocItems = self?.bookModel.contents {
                self?.hideWithType()
                self?.showChapter(items: tocItems.filter { ($0.charpTitle?.count ?? 0) > 0 })
            }
        }, next: false)

        // 点击左侧目录转跳
        jmRegisterEvent(eventName: kEventNameDidSelectChapter, block: { [weak self](value) in
            if let charpter = value as? JMBookCharpter {
                self?.hideWithType()
                self?.bookModel.indexPath.chapter = charpter.location.chapter
                self?.bookModel.indexPath.page = 0
                if let page = self?.bookModel.currPage(),
                   let pageView = self?.unusePageView() {
                    pageView.loadPage(page)
                    self?.pageVC?.setViewControllers([pageView], direction: .forward, animated: true, completion: nil)
                }
            }
        }, next: false)
    }
    
    func registerSubMenuEvent() {
        // 修改背景颜色
        jmRegisterEvent(eventName: kEventNameMenuPageBkgColor, block: { [weak self](item) in
            if let color = (item as? JMReadMenuItem)?.bkgColor {
                JMBookConfig.share.bkgColor = color
                if let controllers = self?.dataSource {
                    for vc in controllers {
                        vc.view.backgroundColor = UIColor.jmHexColor(color)
                    }
                }
            }
            
        }, next: false)
        
        // 设置翻页
        jmRegisterEvent(eventName: kEventNameMenuPageFlipType, block: { [weak self](item) in
            if let typeStr = (item as? JMReadMenuItem)?.identify.rawValue {
                JMBookConfig.share.flipType = JMFlipType.typeFrom(typeStr)
                if let page = self?.bookModel.currPage(), let pageView = self?.unusePageView() {
                    self?.pageVC?.view.removeFromSuperview()
                    self?.pageVC?.removeFromParentViewController()
                    self?.setupPageVC()
                    pageView.loadPage(page)
                    self?.pageVC?.setViewControllers([pageView], direction: .reverse, animated: true, completion: nil)
                }
            }
            
        }, next: false)
    }
}
