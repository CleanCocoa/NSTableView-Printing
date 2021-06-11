//
//  ViewController.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 11.06.21.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    /*
     Wir simulieren hier 1000 Zeilen in der Tabelle, um den Druck über
     mehrere Seiten zu betrachten. Statt wirklich 1000 Objekte anzulegen,
     werden die on-the-fly erstellt.
     */

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1000
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return row
    }


    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"), owner: nil) as? NSTableCellView else { return nil }
        let value = self.tableView(tableView, objectValueFor: tableColumn, row: row) ?? 0
        cellView.textField?.stringValue = "\(value)"
        return cellView
    }
}

