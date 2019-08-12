//
//  FastlaneSnapshot.swift
//  FastlaneSnapshot
//
//  Created by Andreas Lüdemann on 11/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import XCTest

class FastlaneSnapshot: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testGenerateScreenshots() {

        let deckTitle = localizedString(key: "Snapshot.DeckTitle")
        
        let cardTitle1 = localizedString(key: "Snapshot.CardTitle1")
        let cardContent1 = localizedString(key: "Snapshot.CardContent1")
        
        let cardTitle2 = localizedString(key: "Snapshot.CardTitle2")
        let cardContent2 = localizedString(key: "Snapshot.CardContent2")
        
        let cardTitle3 = localizedString(key: "Snapshot.CardTitle3")
        let cardContent3 = localizedString(key: "Snapshot.CardContent3")
        
        let cardTitle4 = localizedString(key: "Snapshot.CardTitle4")
        let cardContent4 = localizedString(key: "Snapshot.CardContent4")
        
        let cardTitle5 = localizedString(key: "Snapshot.CardTitle5")
        let cardContent5 = localizedString(key: "Snapshot.CardContent5")
        
        let app = XCUIApplication()
        
        setTimePerCard(app)
        createDeck(deckTitle, app: app)
        
        app.tables.staticTexts[deckTitle].tap()
        
        createCard(deckTitle, cardTitle: cardTitle1, cardContent: cardContent1, takeScreenshot: true, app: app)
        createCard(deckTitle, cardTitle: cardTitle2, cardContent: cardContent2, takeScreenshot: false, app: app)
        createCard(deckTitle, cardTitle: cardTitle3, cardContent: cardContent3, takeScreenshot: false, app: app)
        createCard(deckTitle, cardTitle: cardTitle4, cardContent: cardContent4, takeScreenshot: false, app: app)
        createCard(deckTitle, cardTitle: cardTitle5, cardContent: cardContent5, takeScreenshot: false, app: app)
        
        snapshot("AllCards")
        
        startPresentation(takeScreenshot: true, isDarkMode: false, app: app)
        
        app.navigationBars[deckTitle].buttons["QCards"].tap()
        
        toggleDarkMode(app)
        
        app.tables.staticTexts[deckTitle].tap()
        
        startPresentation(takeScreenshot: true, isDarkMode: true, app: app)
        
        app.navigationBars[deckTitle].buttons["QCards"].tap()
        
        deleteDeck(deckTitle, app: app)
        toggleDarkMode(app)
    }
    
    // AllDecks
    func setTimePerCard(_ app: XCUIApplication) {
        app.navigationBars["QCards"].buttons["settings"].tap()
        
        app.tables.cells.element(boundBy: 0).tap()
        app.tables.cells.element(boundBy: 1).tap()
        
        app.navigationBars.element(boundBy: 0).buttons["saveButton"].tap()
        app.navigationBars.element(boundBy: 0).buttons["okButton"].tap()
    }
    
    // AllDecks
    func createDeck(_ deckTitle: String, app: XCUIApplication) {
        app.navigationBars["QCards"].buttons["createDeckButton"].tap()
        
        let deckTitleField = app.textFields["deckTitleTextField"]
        deckTitleField.tap()
        deckTitleField.typeText(deckTitle)
        
        app.buttons["addButton"].tap()
    }
    
    // AllCards
    func createCard(_ deckTitle: String, cardTitle: String, cardContent: String, takeScreenshot: Bool, app: XCUIApplication) {
        app.navigationBars[deckTitle].buttons["addButton"].tap()
        
        let cardTitleTextField = app.textFields["cardTitleTextField"]
        cardTitleTextField.tap()
        cardTitleTextField.typeText(cardTitle)
        
        let cardContentTextView = app.textViews["cardContentTextView"]
        cardContentTextView.tap()
        cardContentTextView.typeText(cardContent)
        
        if takeScreenshot {
            snapshot("CreateCard")
        }
        
        app.buttons["saveButton"].tap()
    }
    
    // AllDecks
    func deleteDeck(_ deckTitle: String, app: XCUIApplication) {
        app.tables.staticTexts[deckTitle].swipeLeft()
        app.buttons.element(boundBy: 3).tap()
        app.buttons["yesButton"].tap()
    }
    
    // AllDecks
    func toggleDarkMode(_ app: XCUIApplication) {
        app.navigationBars["QCards"].buttons["settings"].tap()
        
        app.switches.element(boundBy: 2).tap()
        
        app.navigationBars.element(boundBy: 0).buttons["okButton"].tap()
    }
    
    // AllCards
    func startPresentation(takeScreenshot: Bool, isDarkMode: Bool, app: XCUIApplication) {
        app.buttons["play"].tap()
        
        if takeScreenshot {
            var snapshotTitle = "Presentation"
            
            if isDarkMode {
                snapshotTitle += "DarkMode"
            }
            
            snapshot(snapshotTitle)
        }
        
        app.buttons["stop"].tap()
    }
}
