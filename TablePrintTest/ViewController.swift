//
//  ViewController.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 11.06.21.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var tableView: NSTableView!

    @IBAction func printTableWithDecoration(_ sender: Any?) {
        // MARK: Druckbereich ermitteln, um die Größe der NSViews auf Papier zu bestimmen
        // Verfügbare Maße zum Drucken zunächst auf den druckbaren Bereich
        // einer Seite beschränken -- wir erlauben später, vertikal zu wachsen.
        let printInfo = NSPrintInfo.shared
        let paperSize = NSPrintInfo.shared.paperSize // Maße einer ganzen Seite (A4) bis zum Rand, also mehr als man bedrucken kann
        let pageContentSize = NSSize(width: paperSize.width - printInfo.leftMargin - printInfo.rightMargin,
                                     height: paperSize.height - printInfo.topMargin - printInfo.bottomMargin)

        // MARK: Anordnen der Elemente auf der Seite
        // Einleitungstext und Tabelle werden vertikal auf der Seite angeordnet, in einem 'stack' der die Seite füllt
        let initialFrameForPrinting = NSRect(origin: .zero, size: pageContentSize)
        let stackView = NSStackView(frame: initialFrameForPrinting)
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.autoresizingMask = [.height] // Container darf größer werden, wenn z.B. die Tabelle zu lang wird

        // Die Komponenten in den Stack einfügen:
        stackView.addArrangedSubview(self.tableView)

        // Forcieren des Layouts
        stackView.layoutSubtreeIfNeeded()

        // MARK: Drucken der View
        // Drucken oben-links auf der Seite beginnen, egal wie klein der Inhalt ist
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false

        printInfo.horizontalPagination = .clip  // .fit schrumpft alles, bis es passt
        printInfo.verticalPagination = .automatic

        let printOperation = NSPrintOperation(view: stackView)
        printOperation.runModal(for: self.view.window!, delegate: nil, didRun: nil, contextInfo: nil)

        // Am Ende dieser Funktion werden alle lokalen Variablen freigegeben und die `stackView` und `printOperation` automatisch gelöscht.
    }

    /*
     Wir simulieren hier 1000 Zeilen in der Tabelle, um den Druck über
     mehrere Seiten zu betrachten. Statt wirklich 1000 Objekte anzulegen,
     werden die on-the-fly erstellt.
     */

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 200
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return row
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"), owner: nil) as? NSTableCellView else { return nil }
        let value = self.tableView(tableView, objectValueFor: tableColumn, row: row) ?? 0
        // Die Zeilennummer wiederholen wir ein paar mal, um auch
        // breiten Inhalt zu bekommen, wenn wir die Spalte breit machen
        let string = (0...40).map { _ in "\(value)" }.joined(separator: " ")
        cellView.textField?.stringValue = string
        return cellView
    }
}

