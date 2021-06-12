//
//  ViewController.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 11.06.21.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!

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
        let introductionLabel = NSTextField.wrappingLabel(title: introductionText, controlSize: .regular)

        // MARK: Plain table for printing
        let tableViewForPrint = NSTableView(frame: .zero)
        let soleColumn = NSTableColumn()
        soleColumn.resizingMask = .autoresizingMask
        tableViewForPrint.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        tableViewForPrint.allowsColumnSelection = false
        tableViewForPrint.allowsColumnResizing = true
        tableViewForPrint.addTableColumn(soleColumn)
        tableViewForPrint.selectionHighlightStyle = .none
        tableViewForPrint.allowsEmptySelection = true
        if #available(macOS 11.0, *) {
            // Avoid Big Sur's default horizontal padding
            tableViewForPrint.style = .plain
        }

        tableViewForPrint.dataSource = self
        tableViewForPrint.delegate = self
        tableViewForPrint.reloadData()

        // MARK: Lay out introduction and table on the page(s)
        let initialFrameForPrinting = NSRect(origin: .zero, size: pageContentSize)
        let stackView = NSStackView(frame: initialFrameForPrinting)
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.spacing = 20.0
        stackView.distribution = .fill
        stackView.autoresizingMask = [.height] // Container may get higher to fit more pages

        stackView.addArrangedSubview(introductionLabel)
        stackView.addArrangedSubview(tableViewForPrint)
        tableViewForPrint.sizeLastColumnToFit() // won't work earlier than when the table is embedded in a view hierarchy

        // MARK: Configure the print operation
        // Print 'naturally', starting in top-left (for LTR languages at least?) instead of centering the content like a picture.
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        printInfo.horizontalPagination = .clip  // Using `.fit` would shrink the content.
        printInfo.verticalPagination = .automatic

        let printOperation = NSPrintOperation(view: stackView)
        printOperation.runModal(for: self.view.window!,
                                delegate: nil,
                                didRun: nil,
                                contextInfo: nil)

        // `runModal` doesn't block the main thread, so this line is reached immediately, and `tableView` is from this point on not visible in the window anymore. The window is effectively blank.
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
        // We're not using the Storyboard's cell but a custom subclass so that we can share the code on screen and on paper.
        return tableView.makeView(withIdentifier: .cell, owner: self) ?? TableCellView()
    }
}

extension NSUserInterfaceItemIdentifier {
    static let cell: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cell")
}

class TableCellView: NSTableCellView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.identifier = .cell

        let textField = NSTextField.label()
        textField.autoresizingMask = [.width, .height]
        self.addSubview(textField)
        self.textField = textField

        textField.bind(NSBindingName.value, to: self, withKeyPath: "objectValue", options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
