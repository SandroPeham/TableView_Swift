//
//  ViewController.swift
//  TableViewProject
//
//  Created by Sandro Peham on 17/03/2017.
//  Copyright © 2017 Sandro Peham. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let cellID = "cellID"

    @IBOutlet weak var tableView: NSTableView!
    
    var data: [[String]] = []
    
    var numRows: Int {
        return data.count
    }
    
    var numColumns: Int {
        if numRows == 0 { return 0 }
        return data[0].count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        data = [["a","b","d"],["asf","sdf","safd"],["adsf","lj","hs"]]
        //setLargeData()
        updateTableColumns()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func makeTableCellViewBuffer() {
        var buffer = [Any]()
        for _ in 1...100 {
            buffer.append(tableView.make(withIdentifier: cellID, owner: nil)!)
        }
    }
    
    private func setLargeData() {
        data = []
        
        var row = ["a","b","c","d","e","f","g","h","i"]
        for _ in 1...30 { row.append("null") }
        for _ in 1...1000 {
            data.append(row)
        }
    }
    
    private func updateTableColumns() {
        removeColumns()
        
        for i in 0..<numColumns {
            let tableColumn = NSTableColumn(identifier: "\(i)")
            tableColumn.headerCell.stringValue = tableColumn.identifier
            tableView.addTableColumn(tableColumn)
        }
        
        tableView.reloadData()
    }
    
    private func removeColumns() {
        for tableColumn in tableView.tableColumns {
            tableView.removeTableColumn(tableColumn)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        
        if let key = event.characters {
            switch key {
            case "\u{7F}": removeSelectedRows()
            default: super.keyDown(with: event)
            }
        }
    }
    
    func removeSelectedRows() {
        
        let selectedRows = tableView.selectedRowIndexes
        
        for index in selectedRows.reversed() {
            remove(row: index)
        }
        tableView.removeRows(at: selectedRows, withAnimation: .slideDown)
    }
    
    func remove(row: Int, localizedString: String = "Delete Row") {
        
        let elementRow = data.remove(at: row)
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.add(elementRow: elementRow, atRow: row, localizedString: localizedString)
            target.tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideDown)
        })
        undoManager?.setActionName(NSLocalizedString(localizedString, comment: localizedString + " Undo"))
    }
    
    func remove(column: Int, localizedString: String = "Delete Column") {
        var elementColumn: [String] = []
        
        for i in 0..<numRows {
            elementColumn.append(data[i].remove(at: column))
        }
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.add(elementColumn: elementColumn, atColumn: column, localizedString: localizedString)
        })
        undoManager?.setActionName(NSLocalizedString(localizedString, comment: localizedString + " Undo"))
        
        updateTableColumns()
        tableView.reloadData()
    }
    
    func add(elementRow: [String], atRow row: Int, localizedString: String = "Add Row") {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.remove(row: row, localizedString: localizedString)
            target.tableView.removeRows(at: IndexSet(integer: row), withAnimation: .slideUp)
        })
        undoManager?.setActionName(NSLocalizedString(localizedString, comment: localizedString + " Undo"))
        
        data.insert(elementRow, at: row)
    }
    
    func add(elementColumn: [String], atColumn column: Int, localizedString: String = "Add Column") {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.remove(column: column, localizedString: localizedString)
        })
        undoManager?.setActionName(NSLocalizedString(localizedString, comment: localizedString + " Undo"))
        
        for i in 0..<numRows {
            data[i].insert(elementColumn[i], at: column)
        }
        
        updateTableColumns()
        tableView.reloadData()
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let column = tableView.column(for: sender)
        
        if row < 0 || column < 0 { return }
        
        set(sender.stringValue, forRow: row, column: column)
    }
    
    private func emptyRow() -> [String] {
        return Array<String>(repeating: "", count: numColumns)
    }
    
    private func emptyColumn() -> [String] {
        return Array<String>(repeating: "", count: numRows)
    }
    
    @IBAction func addRowBefore(_ sender: NSMenuItem) {
        let row = tableView.clickedRow
        add(elementRow: emptyRow(), atRow: row, localizedString: "Add Row")
        tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideUp)
    }
    
    @IBAction func addRowAfter(_ sender: NSMenuItem) {
        let row = tableView.clickedRow + 1
        add(elementRow: emptyRow(), atRow: row, localizedString: "Add Row")
        tableView.insertRows(at: IndexSet(integer: row), withAnimation: .slideDown)
    }
    
    @IBAction func deleteRow(_ sender: NSMenuItem) {
        let row = tableView.clickedRow
        remove(row: row, localizedString: "Delete Row")
        tableView.removeRows(at: IndexSet(integer: row), withAnimation: .slideUp)
    }
    
    @IBAction func addColumnBefore(_ sender: NSMenuItem) {
        let column = tableView.clickedColumn
        add(elementColumn: emptyColumn(), atColumn: column, localizedString: "Add Column")
    }
    
    @IBAction func addColumnAfter(_ sender: NSMenuItem) {
        let column = tableView.clickedColumn + 1
        add(elementColumn: emptyColumn(), atColumn: column, localizedString: "Add Column")
    }
    
    @IBAction func deleteColumn(_ sender: NSMenuItem) {
        let column = tableView.clickedColumn
        remove(column: column, localizedString: "Delte Column")
        updateTableColumns()
        tableView.reloadData()
    }
    
    func set(_ value: String, forRow row: Int, column: Int) {
        let currentValue = data[row][column]
        
        if currentValue == value { return }
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.set(currentValue, forRow: row, column: column)
        })
        undoManager?.setActionName(NSLocalizedString("Cell typing", comment: "Cell undo"))
        
        data[row][column] = value
        
        tableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integer: column))
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return numRows
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: cellID, owner: nil) as! NSTableCellView
        
        guard let col = columnIndex(for: tableColumn) else { return nil }
        
        view.textField?.stringValue = data[row][col]
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = .white
    }
    
    private func columnIndex(for tableColumn: NSTableColumn?) -> Int? {
        if let tableColumn = tableColumn {
            return tableView.tableColumns.index(of: tableColumn)
        }
        return nil
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, didDrag tableColumn: NSTableColumn) {
        if let prev = Int(tableColumn.identifier) {
            if let next = tableView.tableColumns.index(of: tableColumn)?.littleEndian {
                if prev == next { return }
                moveColumn(at: prev, to: next)
                tableColumn.identifier = "\(next)"
            }
        }
    }
    
    func moveColumn(at prev: Int, to next: Int) {
        
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.tableView.moveColumn(next, toColumn: prev)
            target.moveColumn(at: next, to: prev)
            target.renameColumns()
        })
        undoManager?.setActionName(NSLocalizedString("Move Column", comment: "Move Column Undo"))
        
        for rowIndex in 0..<numRows {
            var row = data[rowIndex]
            row.insert(row.remove(at: prev), at: next)
            data[rowIndex] = row
        }
        renameColumns()
        
        tableView.reloadData()
    }
    
    func renameColumns() {
        var index = 0
        for tableColumn in tableView.tableColumns {
            tableColumn.identifier = "\(index)"
            tableColumn.headerCell.stringValue = "\(index)"
            index += 1
        }
    }
}
