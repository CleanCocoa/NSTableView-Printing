//
//  ViewController.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 11.06.21.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    /// Used to restore the table view in the NSWindow after printing (see below for details).
    private var tableViewContainerView: NSView?

    @IBAction func printTableWithDecoration(_ sender: Any?) {
        // MARK: Figure out the printable region
        // Without a proper initial frame, the content apparently won't lay out on the page to fill it. So we take the page info and compute the available content size.
        // Calculation taken from: <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Printing/osxp_pagination/osxp_pagination.html>
        let printInfo = NSPrintInfo.shared
        let paperSize = NSPrintInfo.shared.paperSize // Maße einer ganzen Seite (A4) bis zum Rand, also mehr als man bedrucken kann
        let pageContentSize = NSSize(width: paperSize.width - printInfo.leftMargin - printInfo.rightMargin,
                                     height: paperSize.height - printInfo.topMargin - printInfo.bottomMargin)

        // MARK: Introductory text
        // This is going to be printed on top the page, but not in the header (that would repeat the text on every page).
        let introductionText = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        let introductionLabel = NSTextField.newWrappingLabel(title: introductionText, controlSize: .regular)

        // MARK: Lay out introduction and table on the page(s)
        let initialFrameForPrinting = NSRect(origin: .zero, size: pageContentSize)
        let stackView = NSStackView(frame: initialFrameForPrinting)
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.spacing = 20.0
        stackView.autoresizingMask = [.height] // Container may get higher to fit more pages

        // FIXME: Quick fix: adding `tableView` onto to the temp page layout will remove it from the NSWindow's view hierarchy. We probably want to solve this differently
        // See the delegate callback below where the view hierarchy is restored. This feels ultra hacky.
        // TODO: Try to programmatically create NSTableView from scratch. I couldn't get anything displayed.
        self.tableViewContainerView = self.tableView.enclosingScrollView?.contentView

        stackView.addArrangedSubview(introductionLabel)
        stackView.addArrangedSubview(self.tableView) // After here, the tableView is not part of the NSWindow anymore

        // Print 'naturally', starting in top-left (for LTR languages at least?) instead of centering the content like a picture.
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        printInfo.horizontalPagination = .clip  // Using `.fit` would shrink the content.
        printInfo.verticalPagination = .automatic

        let printOperation = NSPrintOperation(view: stackView)
        printOperation.runModal(for: self.view.window!,
                                delegate: self,
                                didRun: #selector(printOperationDidRun(_:success:contextInfo:)),
                                contextInfo: nil)

        // `runModal` doesn't block the main thread, so this line is reached immediately, and `tableView` is from this point on not visible in the window anymore. The window is effectively blank.
    }

    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        // From here on out, the print window is gone.

        // Restore the NSWindow view hierarchy, adding `tableView` back where it came from.
        tableViewContainerView?.addSubview(self.tableView)
        tableViewContainerView = nil
    }
}

// MARK: - Populate table view on the fly

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sizeLastColumnToFit()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 100
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        // Create some dummy content based on the row number
        let string = (0...40).map { _ in "\(row)" }.joined(separator: " ")
        return string
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // The Storyboard uses Cocoa Bindings from NSTableViewCell.textField.value to NSTableViewCell.objectValue, just to save some code here for the dummy data.
        return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"), owner: self)
    }
}
