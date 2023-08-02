//
//  ImageCacheTests.swift
//  RecipesAppTests
//
//  Created by Hyusein Hyusein on 24.10.21.
//

import XCTest
@testable import RecipesApp

class ImageCacheTests: XCTestCase {
    var imageCache: ImageCache!
    var mockClient: MockHTTPClient!
    var cache: NSCache<NSURL, UIImage>!
    
    let testURL = URL(string: "https://www.seriouseats.com/thmb/JW66xWgB-owXZUSlIiP1n9BoM50=/960x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__2019__05__20190520-cheesecake-vicky-wasik-34-16488b3671ae47b5b29eb7124dbaf938.jpg)")!
    let testImage = UIImage(named: "placeholder")!
    
    override func setUpWithError() throws {
        mockClient = MockHTTPClient()
        cache = NSCache<NSURL, UIImage>()
    }
    
    override func tearDownWithError() throws {
        mockClient = nil
        cache = nil
        imageCache = nil
    }
    
    func testLoadImageSuccess() throws {
        imageCache = ImageCache(client: mockClient, cache: cache)
        let exp = expectation(description: "loadImage completion")
        imageCache.load(url: testURL as NSURL, completion: {
            result in
            exp.fulfill()
            if let result = result {
                XCTAssertEqual(result, self.testImage)
            }
            else {
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testLoadImageFailure() throws {
        mockClient.isDownloadImageSuccess = false
        imageCache = ImageCache(client: mockClient)
        let exp = expectation(description: "loadImage completion")
        imageCache.load(url: testURL as NSURL, completion: {
            result in
            exp.fulfill()
            if let _ = result {
                XCTFail()
            }
            else {
                XCTAssertEqual(1, 1)
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
    
    func testImageIsCached() throws {
        imageCache = ImageCache(client: mockClient, cache: cache)
        let exp = expectation(description: "loadImage completion")
        imageCache.load(url: testURL as NSURL, completion: {
            result in
            exp.fulfill()
            if let _ = result {
                XCTAssertEqual(self.cache.object(forKey: self.testURL as NSURL)?.pngData(), self.testImage.pngData())
            }
            else {
                XCTFail()
            }
        })
        wait(for: [exp], timeout: 0.01)
    }
}
