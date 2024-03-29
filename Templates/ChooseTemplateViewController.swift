//
//  ChooseTemplateViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/12/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

// TODO: Can we simplify this by using representedObject?
class ChooseTemplateViewController: NSViewController {

    @IBOutlet weak var platformPopup: NSPopUpButton!
    @IBOutlet weak var frameworkPopup: NSPopUpButton!
    @IBOutlet weak var languagePopup: NSPopUpButton!
    @IBOutlet weak var categoryTableView: NSTableView!
    @IBOutlet weak var templateCollectionView: NSCollectionView!

    weak var container: TemplateContainerViewController!
    
    private var platforms: [DependencyPlatformViewModel]!
    
    fileprivate var categories = [TemplateCategory]() {
        didSet {
            categoryTableView.reloadData()
            templateCollectionView.reloadData()
            categoryTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            guard let _ = categories.first?.templates?.first else {
                return
            }
            templateCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
        }
    }
    fileprivate var projectInit: ProjectInit? = nil
    
    /// Index for "All categories"
    fileprivate let allRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTemplateView()
        
        // Select last used platform if present in user defaults
        loadPlatforms()
        if let lastUsedPlatformName = UserDefaults.standard[.lastUsedPlatform], let item = platformPopup.item(withTitle: lastUsedPlatformName) {
            platformPopup.select(item)
        }
        
        // Select last used framework if present in user defaults
        setFrameworkPopup()
        if let lastUsedFrameworkName = UserDefaults.standard[.lastUsedFramework], let item = frameworkPopup.item(withTitle: lastUsedFrameworkName) {
            frameworkPopup.select(item)
        }
        
        setTemplates()
    }
    
    override func viewWillDisappear() {
        let selectedPlatform = platforms[platformPopup.indexOfSelectedItem]
        let selectedFramework = selectedPlatform.frameworks[frameworkPopup.indexOfSelectedItem]
        UserDefaults.standard[.lastUsedPlatform] = selectedPlatform.name
        UserDefaults.standard[.lastUsedFramework] = selectedFramework.name
    }
    
    
    /// Loads platforms from disk and populates platform and framework popup buttons
    private func loadPlatforms() {
        
        // Load dependencies from disk
        do {
            self.platforms = try DependencyPlatformViewModel.loadPlatforms()
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
        platformPopup.removeAllItems()
        
        for platform in platforms {
            self.platformPopup.addItem(withTitle: platform.name)
            // Enable all platforms for now
//            let installedFrameworks = platform.frameworks.filter{ $0.state != .notInstalled }
//            self.platformPopup.item(withTitle: platform.name)?.isEnabled = installedFrameworks.count > 0
        }
    }
    
    /// Populates framework popup button
    private func setFrameworkPopup() {
        
        frameworkPopup.removeAllItems()
        guard platformPopup.indexOfSelectedItem != -1 else { return }   // -1 means no item selected

        let selectedPlatform = platforms[platformPopup.indexOfSelectedItem]
        guard selectedPlatform.frameworks.count > 0 else { return }

        for framework in selectedPlatform.frameworks {
            frameworkPopup.addItem(withTitle: framework.name)
//            frameworkPopup.item(withTitle: framework.name)?.isEnabled = framework.state != .notInstalled
        }
    }
    
    /// Popupalates templates view
    private func setTemplates() {
        
        let framework = platforms[platformPopup.indexOfSelectedItem].frameworks[frameworkPopup.indexOfSelectedItem]
        
        // Load templates. categories didSet triggers reload of collectionViews
        do {
            categories = try loadTemplates(framework: framework.name)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
    }
    
    /// Loads templates from disk
    private func loadTemplates(framework: String) throws -> [TemplateCategory] {
        guard let url = Bundle.main.url(forResource: "Templates-\(framework)", withExtension: "plist") else {
            throw(CompositeError.fileNotFound(framework))
        }
        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let category = try decoder.decode([TemplateCategory].self, from: data)
        return category
    }
    
    
    @IBAction func ChooseClicked(_ sender: Any) {
        
        // TODO: check if platform and framework are installed. If not, present
        // option to install
//        for framework in selectedPlatform.frameworks {
//            //            frameworkPopup.item(withTitle: framework.name)?.isEnabled = framework.state != .notInstalled
//
//            for dependency in framework.dependencies {
//                guard let operation = dependency.fileLocationOperation() else { continue }
//                fileQueue.addOperation(operation)
//            }
//        }
        
        guard let selection = templateCollectionView.selectionIndexPaths.first else { return }
        
        let template = item(at: selection)
//        guard let detailType = template.detailViewType, detailType.isEmpty == false else {
            // No detail type
            showSavePanel(template: template)
            return
//        }
//        container.showOptions()
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.view.window!.close()
    }
    
    @IBAction func viewMoreInfoClicked(_ sender: Any) {
        guard let sender = sender as? NSView,
            let itemView = sender.nextResponder?.nextResponder as? TemplateCollectionViewItem,
            let indexPath = templateCollectionView.indexPath(for: itemView)
            else { return }

        let template = item(at: indexPath)
        guard let url = URL(string: template.moreInfoUrl) else { return }
        NSWorkspace.shared.open(url)
        // Nice to have: select cell so user have confirmation which "more info" button they clicked
//        templateCollectionView.deselectAll(self)
//        templateCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
    }
    
    
    @IBAction func platformClicked(_ sender: Any) {
        setFrameworkPopup()
        setTemplates()
    }
    
    
    @IBAction func frameworkClicked(_ sender: Any) {
        // Load templates of this framework
        setTemplates()
    }
    
    
    @IBAction func languageClicked(_ sender: Any) {
        setTemplates()        
    }

    
    /// Set up PreparingViewController
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        guard let projectInit = projectInit else { return }
        
        if let destination = segue.destinationController as? NSWindowController, let projectInitWindow = destination.contentViewController as? ProjectInitViewController {
            projectInitWindow.projectInit = projectInit 
        } else {
            assertionFailure()
        }
        self.view.window!.close()
    }
    
    
    private func showSavePanel(template: Template? = nil) {
        
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: view.window!) { (result) in
            
            guard result == .OK, let directory = savePanel.url else { return }
            
            // Do not allow overwriting existing files or directories
            guard ProjectInit.canCreateProject(at: directory) == true else {
                let alert = NSAlert()
                alert.messageText = "Cannot overwrite existing file or directory."
                alert.informativeText = "Choose another projectname."
                alert.runModal()
                return
            }
            
            do {
                let projectInit = try self.createProjectInit(directory: directory, template: template)
                self.projectInit = projectInit
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
            
            let id = NSStoryboardSegue.Identifier("ProjectInitSegue")
            self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    private func createProjectInit(directory: URL, template: Template? = nil) throws -> ProjectInit {
        
        // Fetch selected view models
        let platform = platforms[platformPopup.indexOfSelectedItem]
        let framework = platform.frameworks[frameworkPopup.indexOfSelectedItem]
        
        let projectInit = try ProjectInit(directory: directory, template: template, framework: framework, platform: platform)
        return projectInit
    }
}


extension ChooseTemplateViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate func item(at indexPath: IndexPath) -> Template {
        if categoryTableView.selectedRow == allRowIndex {
            return categories[indexPath.section].templates![indexPath.item]
        } else {
            return categories[categoryTableView.selectedRow - 1].templates![indexPath.item]
        }
    }
    
    
    fileprivate func configureTemplateView() {
        view.wantsLayer = true
        let nib = NSNib(nibNamed: NSNib.Name("TemplateCollectionViewItem"), bundle: nil)
        templateCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"))
    }
    
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
        if categoryTableView.selectedRow == allRowIndex {
            return categories.count // All
        } else {
            return 1 // Show only selected category
        }
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if categoryTableView.selectedRow == allRowIndex {
//            print("number of items in section \(section): \(categories[section].templates?.count ?? 0)")
            return categories[section].templates?.count ?? 0
        }
        return categories[categoryTableView.selectedRow - 1].templates?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        guard let cell = templateCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"), for: indexPath) as? TemplateCollectionViewItem else {
            assertionFailure()
            return NSCollectionViewItem()
        }

        let template = item(at: indexPath)
        
        cell.imageView?.image = template.image
        cell.textField?.stringValue = template.name
        cell.erc.stringValue = template.standard
        cell.descriptionTextField.stringValue = template.description ?? ""
        cell.moreInfoButton.isHidden = template.moreInfoUrl.isEmpty
        return cell
    }
}

extension ChooseTemplateViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        print("number of rows: \(categories.count + 1)")
        return categories.count + 1 // all categories plus "All"
    }
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row == allRowIndex { return "    All" }
        return "    " + categories[row - 1].category
    }
}

extension ChooseTemplateViewController: NSTableViewDelegate {
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        templateCollectionView.reloadData()
        templateCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
    }
}
