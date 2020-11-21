//
//  StateCollectionView.swift
//  swiftArch
//
//  Created by czq on 2018/6/25.
//  Copyright © 2018年 czq. All rights reserved.
//

import UIKit
import MJRefresh
public class StateCollectionView: UICollectionView {

    public var loadView: (UIView & LoadViewProtocol)?
    public var emptyView: UIView?
    public var errorView: UIView?

    lazy var bundle = Bundle(for: self.classForCoder)

    private var refreshHeader: MJRefreshHeader?
    private var loadMoreFooter: MJRefreshFooter?


    public typealias refreshCallback = () -> Void
    public typealias loadMoreCallback = () -> Void

    private var refreshCallback: refreshCallback?
    private var loadMoreCallback: loadMoreCallback?

    public func setLoadView(view: UIView&LoadViewProtocol) {
        loadView = view;
    }
    public func setEmptyiew(view: UIView) {
        emptyView = view;
    }

    public func setErroriew(view: UIView) {
        errorView = view;
    }

    public func setRefreshHeader(refreshHeader: MJRefreshHeader) {
        self.refreshHeader = refreshHeader
    }

    public func setLoadMoreFooter(loadMoreFooter: MJRefreshFooter) {
        self.loadMoreFooter = loadMoreFooter
    }

    public func setRefreshCallback(refreshCallback: @escaping refreshCallback) {
        self.refreshCallback = refreshCallback
    }
    public func setLoadMoreCallback(loadMoreCallback: @escaping loadMoreCallback) {
        self.loadMoreCallback = loadMoreCallback
    }


    public func setUpState() {

        if loadView == nil {
            let dLoadView: DefaultTableLoadView = DefaultTableLoadView()
            loadView = dLoadView
        }
        if emptyView == nil {
            let dEmptyView: DefaultTableEmptyView = DefaultTableEmptyView()
            emptyView = dEmptyView
        }
        if errorView == nil {
            let dErrorView: DefaultTableErrorView = DefaultTableErrorView()
            errorView = dErrorView
        }

        self.addSubview(loadView!)
        self.addSubview(emptyView!)
        self.addSubview(errorView!)
        loadView?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(self)
        })
        emptyView?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(self)
        })
        errorView?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(self)
        })
        if refreshHeader == nil {
            useDefaultHeaderStyle()
        }
        if loadMoreFooter == nil {
            useDefaultFooterStyle()
        }
        self.mj_header = refreshHeader
        self.mj_footer = loadMoreFooter
        self.mj_footer?.isHidden = true
        self.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(self.onRefresh))
        self.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(self.onLoadMore))
        emptyView?.addTapGesture(handler: { [weak self] (tap) in
            self?.beginRefresh()
            self?.showLoading()
        })
        errorView?.addTapGesture(handler: { [weak self] (tap) in
            self?.beginRefresh()
            self?.showLoading()
        })
        self.showContent()
    }
    @objc func onRefresh() {

        loadMoreFooter?.isHidden = true
        self.refreshCallback?()
    }

    @objc func onLoadMore() {

        self.loadMoreCallback?()
    }

    private func hideAllCover() {

        loadView?.isHidden = true
        emptyView?.isHidden = true
        errorView?.isHidden = true
        loadView?.stopAnimate()
    }

    public func showContent() {

        self.endRefresh()
        self.endLoadMore()
        self.hideAllCover()

    }

    public func showLoading() {
        self.hideAllCover()
        loadView?.isHidden = false
        loadView?.startAnimate()
        self.bringCoverToFront()
    }
    public func showEmpty() {

        self.showContent()
        emptyView?.isHidden = false
        self.bringCoverToFront()
    }

    public func showError() {

        self.showContent()
        errorView?.isHidden = false
        self.bringCoverToFront()
    }

    public func beginRefresh() {
        if (!(refreshHeader?.isRefreshing ?? true)){
            refreshHeader?.beginRefreshing()
        }
    }
    
    public func endRefresh() {
        if (refreshHeader?.isRefreshing ?? false) {
            refreshHeader?.endRefreshing()
        }
    }
    
    public func beginLoadMore() {
        if (!(loadMoreFooter?.isRefreshing ?? true)){
            loadMoreFooter?.beginRefreshing()
            
        }
    }
    
    public func endLoadMore() {
        if (loadMoreFooter?.isRefreshing ?? false) {
            loadMoreFooter?.endRefreshing()
        }
    }

    public func setLoadMoreEnable(b: Bool) {
        self.mj_footer?.isHidden = !b;
    }
    public func setRefreshEnable(b: Bool) {
        self.mj_header?.isHidden = !b;
    }

    private func useDefaultHeaderStyle() {
        refreshHeader = MJRefreshNormalHeader()
    }
    private func useDefaultFooterStyle() {
        loadMoreFooter = MJRefreshAutoNormalFooter()
    }

    public func bringCoverToFront() {
        self.bringSubviewToFront(emptyView!)
        self.bringSubviewToFront(errorView!)
        self.bringSubviewToFront(loadView!)
    }


}
