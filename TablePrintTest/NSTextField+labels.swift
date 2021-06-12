//
//  NSTextField+labels.swift
//  TablePrintTest
//
//  Created by Christian Tietze on 12.06.21.
//

import AppKit

extension NSTextField {
    func fittingSystemFont() -> NSFont {
        return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: self.controlSize))
    }

    /// Return an `NSTextField` configured exactly like one created by dragging a “Label” into a storyboard.
    class func label(
        title: String = "",
        controlSize: NSControl.ControlSize = .regular) -> NSTextField {

        let label = NSTextField()
        label.isEditable = false
        label.isSelectable = false
        label.textColor = .labelColor
        label.backgroundColor = .controlColor
        label.drawsBackground = false
        label.isBezeled = false
        label.alignment = .natural
        label.controlSize = controlSize
        label.font = label.fittingSystemFont()
        label.lineBreakMode = .byClipping
        label.cell?.isScrollable = true
        label.cell?.wraps = false
        label.stringValue = title
        return label
    }

    /// Return an `NSTextField` configured exactly like one created by dragging a “Wrapping Label” into a storyboard.
    class func wrappingLabel(
        title: String = "",
        controlSize: NSControl.ControlSize = .regular) -> NSTextField {

        let label = label(title: title, controlSize: controlSize)
        label.lineBreakMode = .byWordWrapping
        label.cell?.isScrollable = false
        label.cell?.wraps = true
        return label
    }
}
