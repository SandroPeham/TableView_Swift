//
//  SearchBarView.swift
//  TableViewProject
//
//  Created by Sandro Peham on 21/03/2017.
//  Copyright © 2017 Sandro Peham. All rights reserved.
//

import Cocoa

class SearchBarView: NSView {
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet var delegate: AnyObject?
    
    var lastSearchText: String = ""
    private var searchResults: [SearchResult] = []
    private var currentResult: Int = 0
    
    override func awakeFromNib() {
        searchField.delegate = self
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func done(_ sender: NSButton) {
        delegate?.done()
    }
    
    func resetResult() {
        searchResults = []
        currentResult = 0
    }
    
    public func addResult(result: SearchResult) {
        searchResults.append(result)
    }
    
    public func nextResult() -> SearchResult? {
        if searchResults.isEmpty { return nil }
        
        let result = searchResults[currentResult]
        currentResult = (currentResult + 1) % searchResults.count
        return result
    }
    
    public func previousResult() -> SearchResult? {
        if searchResults.isEmpty { return nil }
        let previousResult = currentResult - 1 >= 0 ? currentResult - 1 : searchResults.count - 1
        return searchResults[previousResult]
    }
}

struct SearchResult {
    var row: Int
    var column: Int
}

extension SearchBarView: NSSearchFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if searchField.stringValue != lastSearchText {
            resetResult()
            delegate?.search(text: searchField.stringValue)
        }
        
        lastSearchText = searchField.stringValue
        delegate?.showNextResult()
    }
}

@objc protocol SearchBarViewDelegate {
    func done()
    func search(text: String)
    func showNextResult()
}
