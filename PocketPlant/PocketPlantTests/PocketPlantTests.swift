//
//  PocketPlantTests.swift
//  PocketPlantTests
//
//  Created by 邱瀚平 on 2021/11/26.
//

import XCTest
@testable import PocketPlant

class PocketPlantTests: XCTestCase {
    
    var sut: Date!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Date()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testDateCompareIsCorrect() {
        
        let isSame = sut.hasSame(.day, as: Date())
        
        XCTAssertEqual(isSame, true, "Date compare is wrong.")
    }
    
    func testDateDistanceIsCorrect() {
        
        let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: sut)!
        
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: noon)!
        
        let distance = sut.distance(from: yesterdayDate, only: .day)
        
        XCTAssertEqual(distance, 1, "Date compare is wrong.")
    }
}
