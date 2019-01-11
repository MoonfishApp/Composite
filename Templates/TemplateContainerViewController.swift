//
//  TemplateContainerViewController.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/26/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class TemplateContainerViewController: NSViewController {
    
    weak var templates: ChooseTemplateViewController!
    weak var options: TemplateOptionsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        templates = (childViewControllers.first! as! ChooseTemplateViewController) // Set in storyboard
        options = (storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Options")) as! TemplateOptionsViewController)
        addChildViewController(options)
        
        templates.container = self
        options.container = self
    }
    
    func showOptions() {
        
        // Set options
        for subView in view.subviews {
            subView.removeFromSuperview()
        }
        view.addSubview(options.view)
    }
    
    func showTemplates() {
        for subView in view.subviews {
            subView.removeFromSuperview()
        }
        view.addSubview(templates.view)
    }
}
