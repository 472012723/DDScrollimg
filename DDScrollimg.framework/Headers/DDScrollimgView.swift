//
//  CycleScrollView.swift
//  DDProduct
//
//  Created by wdd on 2020/6/30.
//  Copyright © 2020 wdd. All rights reserved.
//
import UIKit
/// 代理方法
 protocol PublicProtocol: NSObjectProtocol {
    
    /// 有多少图片
    func cycleImageCount() -> Int
    
    /// 图片和当前下标
    func cycleImageView(_ imageView: UIImageView, index: Int)
    
    /// 点击图片下标
    func cycleImageViewClick(_ index: Int)
}

/// 轮播图
class DDScrollimgView: UIView, UIScrollViewDelegate {

    /// 图片数组
    private var imageViews = [UIImageView(), UIImageView(), UIImageView()]
    /// 圆点数组
    private var yuanViews:[UIImageView] = []
    
    /// 滚动页面
    private var scrollView: UIScrollView!
    
    /// 图片个数
    private var imageCount: Int = 0
    
    /// 计时器
    private var timer: Timer? = nil
    
    /// 存储下标
    private var index: Int = 0
    
    /// 当前显示下标
    public var currentIndex: Int {
        get {
            return index
        }
        set {
            index = min(newValue, imageCount)
            updateImage()
        }
    }
    
    /// 是否滚动
    public var rollingEnable: Bool = false {
        willSet {
            newValue ? startTimer() : stopTimer()
        }
    }
    
    /// 滚动间隔
    public var duration: TimeInterval = 3.0
    
    /// 圆点 默认颜色白色
    public var dotColor_n = UIColor.white
    /// 圆点 选择颜色灰色
    public var dotColor_s = UIColor.darkGray
    
    /// 代理
    public weak var delegate: PublicProtocol? {
        didSet {
            if let delegate = delegate {
                imageCount = delegate.cycleImageCount()
                scrollView.isScrollEnabled = imageCount > 1
                for _ in 1...imageCount{
                    let item = UIImageView()
                    item.backgroundColor = dotColor_n
                    item.layer.masksToBounds = true;
                    item.layer.cornerRadius = 4;
                    addSubview(item)
                    yuanViews.append(item)
                }
            }
        }
    }
    
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        for item in imageViews {
            scrollView.addSubview(item)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }
    
    /// 设置
    override func layoutSubviews() {
        super.layoutSubviews()
        if (imageViews[0].frame == .zero) {
            
            let width = frame.width, height = frame.height
            scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            scrollView.contentSize = CGSize(width: width * 3, height: height)
            for (i, obj) in imageViews.enumerated() {
                obj.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
            }
            for (i, obj) in yuanViews.enumerated() {
                obj.frame = CGRect(x: CGFloat(i) * 18+10, y: height-20, width: 8, height: 8)
            }
            currentIndex = index
        }
    }
    
    /// 点击
    @objc private func tap(_ gesture: UITapGestureRecognizer) {
        delegate?.cycleImageViewClick(currentIndex)
    }
    
    /// 更新图片
    private func updateImage() {
        if (imageCount < 2) {
            delegate?.cycleImageView(imageViews[1], index: index)
//            delegate?.cycleImageView(yuanViews[1], index: index)
        } else {
            for (i, index) in [getLast(currentIndex), currentIndex, getNext(currentIndex)].enumerated() {
                delegate?.cycleImageView(imageViews[i], index: index)
//                delegate?.cycleImageView(yuanViews[i], index: index)
            }
        }
        for im in yuanViews{
            im.backgroundColor = dotColor_n
        }
        let img = yuanViews[index];
        img.backgroundColor = dotColor_s;
        
        scrollView.contentOffset.x = frame.width
    }
    
    /// 开始计时器
    private func startTimer() {
        if (imageCount < 2) {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(rolling), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode:.common)//.RunLoop.Mode.common
    }
    
    /// 暂停计时器
    private func stopTimer() {
        if (imageCount < 2) {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    /// 计时方法
    @objc private func rolling() {
        scrollView.setContentOffset(CGPoint(x: frame.width * 2, y: 0), animated: true)
    }
    
    /// scrollView开始拖拽
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if rollingEnable {
            stopTimer()
        }
    }
    
    /// scrollView结束拖拽
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if rollingEnable {
            startTimer()
        }
    }
    
    /// scrollView滚动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0 {
            currentIndex = getLast(currentIndex)
        } else if scrollView.contentOffset.x >= 2 * scrollView.frame.width {
            currentIndex = getNext(currentIndex)
        }
        /// 修复automaticallyAdjustsScrollViewInsets问题
        if (scrollView.contentOffset.y != 0) {
            scrollView.contentOffset.y = 0
        }
    }
    
    /// 获取下一页页码
    private func getNext(_ current: Int) -> Int {
        let count = imageCount - 1
        if (count < 1) {
            return 0
        }
        return current + 1 > count ? 0 : current + 1
    }
    
    /// 获取上一页页码
    private func getLast(_ current: Int) -> Int {
        let count = imageCount - 1
        if (count < 1) {
            return 0
        }
        return current - 1 < 0 ? count : current - 1
    }
    
    /// 如果有计时器存在，必须停止计时器才能释放
    override func removeFromSuperview() {
        super.removeFromSuperview()
        stopTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
