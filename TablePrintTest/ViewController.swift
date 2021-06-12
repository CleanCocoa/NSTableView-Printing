//
//  ViewController.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 11.06.21.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var tableView: NSTableView!

    private var tableViewContainerView: NSView?

    @IBAction func printTableWithDecoration(_ sender: Any?) {
        // MARK: Druckbereich ermitteln, um die Größe der NSViews auf Papier zu bestimmen
        // Verfügbare Maße zum Drucken zunächst auf den druckbaren Bereich
        // einer Seite beschränken -- wir erlauben später, vertikal zu wachsen.
        let printInfo = NSPrintInfo.shared
        let paperSize = NSPrintInfo.shared.paperSize // Maße einer ganzen Seite (A4) bis zum Rand, also mehr als man bedrucken kann
        let pageContentSize = NSSize(width: paperSize.width - printInfo.leftMargin - printInfo.rightMargin,
                                     height: paperSize.height - printInfo.topMargin - printInfo.bottomMargin)

        // MARK: Einleitungstext vorbereiten
        let introductionLabel = NSTextField(string: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
        introductionLabel.isEditable = false
        introductionLabel.usesSingleLineMode = false
        introductionLabel.lineBreakMode = .byWordWrapping
        introductionLabel.cell?.wraps = true
        introductionLabel.cell?.isScrollable = false
        introductionLabel.textColor = .labelColor
        introductionLabel.drawsBackground = false // Schwarz auf weiß drucken, ohne farbigen Hintergrund (v.a. in dark mode wollen wir den ignorieren)
        introductionLabel.isBezeled = false // Rahmen von Textfeldern nicht zeichnen, nur den Text
        introductionLabel.alignment = .natural


        // MARK: Anordnen der Elemente auf der Seite
        // Einleitungstext und Tabelle werden vertikal auf der Seite angeordnet, in einem 'stack' der die Seite füllt
        let initialFrameForPrinting = NSRect(origin: .zero, size: pageContentSize)
        let stackView = NSStackView(frame: initialFrameForPrinting)
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.spacing = 20.0
        stackView.autoresizingMask = [.height] // Container darf größer werden, wenn z.B. die Tabelle zu lang wird

        // Wir packen die Tabelle auf die Druckseite. Dabei wird sie aber aus dem NSWindow entfernt,
        // weil sie nur in einer NSView Hierarchie gleichzeitig sein kann. Wir speichern den
        // Container der Tabelle in der NSScrollView zwischen, um die Tabelle später wieder dort
        // einfügen zu können. (Siehe ganz unten.)
        self.tableViewContainerView = self.tableView.enclosingScrollView?.contentView

        // Die Komponenten in den Stack einfügen:
        stackView.addArrangedSubview(introductionLabel)
        stackView.addArrangedSubview(self.tableView) // Hiermit wird die Tabelle aus dem Fenster aufs Papier verschoben

        // Forcieren des Layouts
        stackView.layoutSubtreeIfNeeded()

        // MARK: Drucken der View
        // Drucken oben-links auf der Seite beginnen, egal wie klein der Inhalt ist
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false

        printInfo.horizontalPagination = .clip  // .fit schrumpft alles, bis es passt
        printInfo.verticalPagination = .automatic

        let printOperation = NSPrintOperation(view: stackView)
        printOperation.runModal(for: self.view.window!,
                                delegate: self,
                                didRun: #selector(printOperationDidRun(_:success:contextInfo:)),
                                contextInfo: nil)

        // Ab hier ist der Druck-Dialog sichtbar. Die Tabelle verschwindet zwischenzeitlich aus dem Fenster.
        // Das kann man bestimmt umgehen, aber ich weiß noch nicht, wie das am Besten geht.
    }

    @objc func printOperationDidRun(_ printOperation: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        // (Ab hier ist der Dialog wieder weg)

        // Wir fügen die Tabelle wieder ins Fenster ein. Vergisst man das, bleibt das Fenster leer.
        tableViewContainerView?.addSubview(self.tableView)
        tableViewContainerView = nil
    }

    /*
     Wir simulieren hier 1000 Zeilen in der Tabelle, um den Druck über
     mehrere Seiten zu betrachten. Statt wirklich 1000 Objekte anzulegen,
     werden die on-the-fly erstellt.
     */

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sizeLastColumnToFit() // automatisch volle Breite einnehmen
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 100
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        // Die Zeilennummer wiederholen wir ein paar mal, um auch
        // breiten Inhalt zu bekommen, wenn wir die Spalte breit machen
        let string = (0...40).map { _ in "\(row)" }.joined(separator: " ")
        return string
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Im Storyboard ist das NSTableViewCell textField mit "bindings" an den objectValue gekoppelt.
        // So kriegt das Label automatisch den Inhalt zugewiesen.
        return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"), owner: self)
    }
}
