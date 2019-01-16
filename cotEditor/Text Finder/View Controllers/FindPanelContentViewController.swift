//
//  FindPanelContentViewController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-06-26.
//
//  ---------------------------------------------------------------------------
//
//  © 2014-2018 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

private let defaultResultViewHeight: CGFloat = 200.0

final class FindPanelContentViewController: NSSplitViewController, TextFinderDelegate {
    
    // MARK: Private Properties
    
    private var isUncollapsing = false
    
    @IBOutlet private var fieldSplitViewItem: NSSplitViewItem?
    @IBOutlet private var resultSplitViewItem: NSSplitViewItem?
    
    
    
    // MARK: -
    // MARK: Split View Controller Methods
    
    /// set delegate
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        TextFinder.shared.delegate = self
    }
    
    
    /// setup UI
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        
        self.setResultShown(false, animate: false)
    }
    
    
    /// collapse result view by dragging divider
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        
        super.splitViewDidResizeSubviews(notification)
        
        guard !self.isUncollapsing else { return }
        
        self.collapseResultViewIfNeeded()
    }
    
    
    /// avoid showing draggable cursor when result view collapsed
    override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        
        let effectiveRect = super.splitView(splitView, effectiveRect: proposedEffectiveRect, forDrawnRect: drawnRect, ofDividerAt: dividerIndex)
        
        if splitView.isSubviewCollapsed(splitView.subviews[dividerIndex + 1]) || dividerIndex == 1 {
            return .zero
        }
        
        return effectiveRect
    }
    
    
    
    // MARK: TextFinder Delegate
    
    /// complemention notification for "Find All"
    func textFinder(_ textFinder: TextFinder, didFinishFindingAll findString: String, results: [TextFindResult], textView: NSTextView) {
        
        // set to result table
        self.fieldViewController?.updateResultCount(results.count, target: textView)
        
        guard !results.isEmpty else { return }
        
        self.resultViewController?.setResults(results, findString: findString, target: textView)
        
        self.setResultShown(true, animate: true)
        self.splitView.window?.windowController?.showWindow(self)
    }
    
    
    /// receive number of found
    func textFinder(_ textFinder: TextFinder, didFind numberOfFound: Int, textView: NSTextView) {
        
        self.fieldViewController?.updateResultCount(numberOfFound, target: textView)
    }
    
    
    /// receive number of replaced
    func textFinder(_ textFinder: TextFinder, didReplace numberOfReplaced: Int, textView: NSTextView) {
        
        self.fieldViewController?.updateReplacedCount(numberOfReplaced, target: textView)
    }
    
    
    
    // MARK: Action Messages
    
    /// close opening find result view
    @IBAction func closeResultView(_ sender: Any?) {
        
        self.setResultShown(false, animate: true)
    }
    
    
    
    // MARK: Private Methods
    
    /// unwrap viewController from split view item
    private var fieldViewController: FindPanelFieldViewController? {
        
        return self.fieldSplitViewItem?.viewController as? FindPanelFieldViewController
    }
    
    
    /// unwrap viewController from split view item
    private var resultViewController: FindPanelResultViewController? {
        
        return self.resultSplitViewItem?.viewController as? FindPanelResultViewController
    }
    
    
    /// toggle result view visibility with/without animation
    private func setResultShown(_ shown: Bool, animate: Bool) {
        
        guard
            let resultViewItem = self.resultSplitViewItem,
            let panel = self.splitView.window
            else { return assertionFailure() }
        
        let resultView = resultViewItem.viewController.view
        let height = resultView.bounds.height
        
        // resize panel frame
        let diff: CGFloat = {
            if shown {
                if resultViewItem.isCollapsed {
                    return defaultResultViewHeight
                } else {
                    return max(defaultResultViewHeight - height, 0)
                }
            } else {
                return -height
            }
        }()
        var panelFrame = panel.frame
        panelFrame.size.height += diff
        panelFrame.origin.y -= diff
        
        // uncollapse if needed
        if shown {
            self.isUncollapsing = true
            resultViewItem.isCollapsed = !shown
            resultView.isHidden = false
        }
        
        panel.setFrame(panelFrame, display: true, animate: animate)
        
        self.isUncollapsing = false
        if !shown {
            self.collapseResultViewIfNeeded()
        }
    }
    
    
    /// collapse result view if closed
    private func collapseResultViewIfNeeded() {
        
        guard
            let resultView = self.resultViewController?.view,
            !resultView.isHidden,
            resultView.visibleRect.isEmpty
            else { return }
        
        self.resultSplitViewItem?.isCollapsed = true
        self.splitView.needsDisplay = true
    }
    
}
