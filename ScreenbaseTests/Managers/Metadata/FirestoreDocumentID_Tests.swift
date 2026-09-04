//
//  FirestoreDocumentID_Tests.swift
//  ScreenbaseTests
//

@testable import Screenbase
import Testing

@Suite("FirestoreDocumentID Tests")
struct FirestoreDocumentID_Tests {
    @Test("Photos localIdentifier slashes are sanitized for document ids")
    func photosLocalIdentifierSlashesAreSanitized() {
        let localIdentifier = "0A291206-BA01-429A-8DAB-5B0A36B1726C/L0/001"
        let documentId = FirestoreDocumentID.fromAssetLocalIdentifier(localIdentifier)

        #expect(documentId == "0A291206-BA01-429A-8DAB-5B0A36B1726C__L0__001")
        #expect(!documentId.contains("/"))
    }

    @Test("Discovered screenshot keeps Photos id and uses sanitized Firestore id")
    func discoveredScreenshotKeepsAssetIdAndSanitizesDocumentId() {
        let discovered = DiscoveredScreenshot(
            assetLocalIdentifier: "ED7AC36B-A150-4C38-BB8C-B6D696F4F2ED/L0/001",
            creationDate: nil
        )
        let record = ScreenshotRecord(discovered: discovered)

        #expect(record.assetLocalIdentifier == discovered.assetLocalIdentifier)
        #expect(record.id == "ED7AC36B-A150-4C38-BB8C-B6D696F4F2ED__L0__001")
    }
}
