//
//  InstallToolchainViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/7/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InstallToolchainViewController: NSViewController {
    
    @IBOutlet weak var platformCollectionView: NSCollectionView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var showOnStartupButton: NSButton!
    
    // Framework detail view
    @IBOutlet weak var detailImageView: NSImageView!
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var detailInfoLabel: NSTextField!
    @IBOutlet weak var detailMoreInfoButton: NSButton!
    @IBOutlet weak var detailDocumentationButton: NSButton!
    
    /// Queue used to fetch versions (which can be extremely slow)
    let fetchVersionQueue: OperationQueue = OperationQueue()
    
    /// Queue used to install and update tools
    let userInitiatedQueue: OperationQueue = OperationQueue()
    
    /// KVO for installQueue.operationCount
    /// If operationCount is greater than zero,
    /// the progress indicator will animate
    private var installCountObserver: NSKeyValueObservation?
    private var TotalInstallCount = 0
    
    private var platforms = [DependencyPlatformViewModel]() {
        didSet {
            platformCollectionView.reloadData()
            platformCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
            frameworkViewModels = platforms.first?.frameworks ?? [DependencyFrameworkViewModel]()
        }
    }
    
    private var frameworkViewModels = [DependencyFrameworkViewModel]() {
        didSet {
            outlineView.reloadData()
            if let first = frameworkViewModels.first {
                showDetailsFor(first)
            }
            self.fetchVersionNumbers()      // Fetch version numbers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.dependencyChange(notification:)),
            name: NSNotification.Name(rawValue: DependencyViewModel.notificationString),
            object: nil)
        
        
        fetchVersionQueue.maxConcurrentOperationCount = 1
        fetchVersionQueue.qualityOfService = .userInteractive
        userInitiatedQueue.maxConcurrentOperationCount = 1
        userInitiatedQueue.qualityOfService = .userInitiated
        
        installCountObserver = userInitiatedQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            DispatchQueue.main.async {
                if queue.operationCount == 0 {
                    self.progressIndicator.stopAnimation(self)
                    self.progressIndicator.isHidden = true
                    self.TotalInstallCount = 0
                } else {
                    if queue.operationCount > self.TotalInstallCount {
                        self.TotalInstallCount = queue.operationCount
                    }
                    self.progressIndicator.doubleValue = (1.0 - (Double(queue.operationCount) / Double(self.TotalInstallCount))) * 100.0
                    self.progressIndicator.startAnimation(self)
                    self.progressIndicator.isHidden = false
                }
            }
        }
        
        showOnStartupButton.state = UserDefaults.standard.bool(forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue) == false ? .on : .off
        
        configurePlatformCollectionView()
        loadPlatforms()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: DependencyViewModel.notificationString), object: nil)
    }
    
    func loadPlatforms() {
        
        do {
            // Load dependencies from disk
            platforms = try DependencyPlatformViewModel.loadPlatforms()
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    func fetchVersionNumbers() {
        
        fetchVersionQueue.cancelAllOperations()
        
        for frameworkViewModel in frameworkViewModels {
            for tool in frameworkViewModel.dependencies {
                
                // Fetch version
                guard tool.version.isEmpty, let operation = tool.versionQueryOperation() else { continue }
                fetchVersionQueue.addOperation(operation)
                
                // Check if newer version is available
                guard let outdatedOperation = tool.outdatedOperation() else { continue }
                fetchVersionQueue.addOperation(outdatedOperation)
            }
        }
    }
    
    @objc private func dependencyChange(notification: NSNotification){
        DispatchQueue.main.async {            
            self.outlineView.reloadData()
        }
    }
    
    private func configurePlatformCollectionView() {
        view.wantsLayer = true
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "PlatformCollectionViewItem"), bundle: nil)
        platformCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("PlatformCollectionViewItem"))
        
        platformCollectionView.reloadData()
    }
    
    private func showDetailsFor(_ item: DependencyFrameworkViewModel) {
        detailLabel.stringValue = item.name.capitalizedFirstChar()
        detailInfoLabel.stringValue = item.description
        detailImageView.image = NSImage(named: NSImage.Name(rawValue: item.name))
        detailMoreInfoButton.alternateTitle = item.projectUrl
        detailMoreInfoButton.isHidden = false
        detailDocumentationButton.alternateTitle = item.documentationUrl
        detailDocumentationButton.isHidden = false
    }
    
    @IBAction func done(_ sender: Any) {
        fetchVersionQueue.cancelAllOperations()
        view.window?.close()
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.showChooseTemplate(self)
    }
    
    
    @IBAction func cellButton(_ sender: Any) {
        // NSButton is a subclass of NSView
        guard let sender = sender as? NSView else { return }
        let row = outlineView.row(for: sender)
        if let item = outlineView.item(atRow: row) as? DependencyFrameworkViewModel {
            showDetailsFor(item)
        }
        
        var models = [DependencyViewModel]()
        
        if let framework = outlineView.item(atRow: row) as? DependencyFrameworkViewModel {
            for dependency in framework.dependencies {
                models.append(dependency)
            }
        } else if let dependency = outlineView.item(atRow: row) as? DependencyViewModel {
            models.append(dependency)
        }
        
        for model in models {
            if model.state == .notInstalled, let operations = model.install() {
                _ = operations.map { self.userInitiatedQueue.addOperation($0) }
            } else if model.state == .outdated, let operations = model.update() {
                _ = operations.map { self.userInitiatedQueue.addOperation($0) }
            }
        }
    }
    
    @IBAction func showOnStartup(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        UserDefaults.standard.set(sender.state == .off, forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue)            
    }
    
    @IBAction func platformMoreInfoButtonClicked(_ sender: Any) {
        
        guard let sender = sender as? NSView,
            let itemView = sender.nextResponder?.nextResponder as? PlatformCollectionViewItem,
            let indexPath = platformCollectionView.indexPath(for: itemView)
            else { return }

        // Select cell
        platformCollectionView.deselectAll(self)
        platformCollectionView.reloadData()
        platformCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
        frameworkViewModels = platforms[indexPath.item].frameworks
        
        // Open url
        let platform = platforms[indexPath.item]
        guard let url = URL(string: platform.projectUrl) else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func detailMoreInfo(_ sender: Any) {
        guard let url = URL(string: (sender as! NSButton).alternateTitle) else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func detailDocumentation(_ sender: Any) {
        guard let url = URL(string: (sender as! NSButton).alternateTitle) else { return }
        NSWorkspace.shared.open(url)
    }
}

extension InstallToolchainViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        func setButton(_ cellButton: NSButton, state: DependencyState, name: String) {
            
            switch state {
                
            case .notInstalled:
                
                cellButton.isHidden = false
                cellButton.isEnabled = true
                cellButton.title = "Install \(name)"
                
            case .outdated, .unknown:
                
                cellButton.isHidden = false
                cellButton.isEnabled = true
                cellButton.title = "Update \(name)"
                
            case .uptodate:
                
                cellButton.isHidden = true
                
            case .installing:
                
                cellButton.isHidden = false
                cellButton.isEnabled = false
                cellButton.title = "Installing..."
                
            case .comingSoon:
                
                cellButton.isHidden = true
                cellButton.isEnabled = true
            }
        }
        
        guard let identifier = tableColumn?.identifier.rawValue else { return nil }
        
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        
        if let item = item as? DependencyFrameworkViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.imageView?.image = nil
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn":
                
                view.textField?.stringValue = item.version
                view.textField?.textColor = NSColor.black
                
            case "PathColumn":
                
                view.textField?.stringValue = ""
                
            case "ActionColumn":
                
                // Fetch the button view
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let cellButton: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                setButton(cellButton, state: item.state, name: item.name)
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
            
        } else if let item = item as? DependencyViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn":
                
                view.textField?.stringValue = item.version
                view.textField?.textColor = NSColor.gray
                
            case "PathColumn":
                
                view.textField?.stringValue = item.path 
                view.textField?.textColor = NSColor.gray
                
            case "ActionColumn":
                
                // Fetch the view with two buttons
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let cellButton: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                setButton(cellButton, state: item.state, name: item.name)
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
        }
                
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        // Show framework details
        if let item = item as? DependencyFrameworkViewModel {
            showDetailsFor(item)
        } else if let item = item as? DependencyViewModel {
            for framework in frameworkViewModels {
                for dependency in framework.dependencies {
                    if dependency === item {
                        showDetailsFor(framework)
                        return false
                    }
                }
            }
        }
        
        return false
    }
}

extension InstallToolchainViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // If item is nil, return number of frameworks
        guard let item = item as? DependencyFrameworkViewModel else { return frameworkViewModels.count }
        
        // If item is a framework, return number of dependencies in framework
        return item.dependencies.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        // Only frameworks are expandable
        guard let item = item as? DependencyFrameworkViewModel else { return false }
        
        // Return true if framework has dependencies
        return !item.dependencies.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            // If item is nil, this is the root
            return frameworkViewModels[index]
            
        } else if let framework = item as? DependencyFrameworkViewModel {
            
            // Return number of dependencies of the framework
            return framework.dependencies[index]
            
        } else {

            assertionFailure()
            return 0
        }
    }
}

extension InstallToolchainViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        guard let index = indexPaths.first?.item else { return }
        frameworkViewModels = platforms[index].frameworks
    }
}

extension InstallToolchainViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return platforms.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("PlatformCollectionViewItem"), for: indexPath) as? PlatformCollectionViewItem else {
            return NSCollectionViewItem()
        }
        
        let platform = platforms[indexPath.item]
        cell.platformLabel.stringValue = platform.platform.description
        cell.logoImageView.image = NSImage(named: NSImage.Name(rawValue: platform.platform.description))
        return cell
    }
}
