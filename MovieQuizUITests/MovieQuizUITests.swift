//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Irina Deeva on 30/10/23.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()

        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertEqual("2/10", indexLabel.label)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()

        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertEqual("2/10", indexLabel.label)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testAlert() {
        for _ in 1...10 {
            sleep(1)
            app.buttons["Yes"].tap()
        }

        sleep(3)
        let alert = app.alerts["Result"]

        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testDismissAlert() {
        for _ in 1...10 {
            sleep(1)
            app.buttons["Yes"].tap()
        }

        sleep(3)
        let alert = app.alerts["Result"]
        alert.buttons.firstMatch.tap()
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual("1/10", indexLabel.label)
    }
}
