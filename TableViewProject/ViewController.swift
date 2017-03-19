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
            tableColumn.minWidth = 64
            tableView.addTableColumn(tableColumn)
        }
        
        tableView.reloadData()
    }
    
    private func removeColumns() {
        for tableColumn in tableView.tableColumns {
            tableView.removeTableColumn(tableColumn)
        }
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let column = tableView.column(for: sender)
        
        if row < 0 || column < 0 { return }
        
        data[row][column] = sender.stringValue
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
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        return NSDragOperation.move
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
                moveColumn(at: prev, to: next)
                tableColumn.identifier = "\(next)"
            }
        }
    }
    
    func moveColumn(at prev: Int, to next: Int) {
        for rowIndex in 0..<numRows {
            var row = data[rowIndex]
            row.insert(row.remove(at: prev), at: next)
            data[rowIndex] = row
        }
        renameColumns()
    }
    
    func renameColumns() {
        var index = 0
        for tableColumn in tableView.tableColumns {
            tableColumn.identifier = "\(index)"
            index += 1
        }
    }
}
