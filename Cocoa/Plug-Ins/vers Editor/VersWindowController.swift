//
//  VersWindowController.swift
//  ResKnife
//
//  Created by Nate Weaver on 2020-06-20.
//

import AppKit

extension OperatingSystemVersion {

	init<T: DataProtocol>(versShort: T) {
		self.init()

		if versShort.count == 2 {
			let firstIndex = versShort.indices.first!
			let secondIndex = versShort.index(after: firstIndex)

			majorVersion = (try? Int(binaryCodedDecimal: versShort.prefix(upTo: firstIndex))) ?? 0
			minorVersion = Int((versShort[secondIndex] & 0xF0) >> 4)
			patchVersion = Int(versShort[secondIndex] & 0x0F)
		}
	}

	var versShort: Data {
		var data = Data()
		data[0] = UInt8(String(majorVersion), radix: 16) ?? 0
		data[1] = ((UInt8(String(minorVersion), radix: 16) ?? 0) << 4) | (UInt8(String(patchVersion), radix: 16) ?? 0)
		return data
	}

}

@objc class VersWindowController: NSWindowController, ResKnifePluginProtocol {

	let resource: ResKnifeResourceProtocol

	override var windowNibName: NSNib.Name? { "VersWindowController" }

	enum Release: UInt8 {
		case development = 0x20
		case alpha = 0x40
		case beta = 0x60
		case release = 0x80
	}

	var release: Release = .development
	var nonRelease: UInt8 = 0

	/// See also: Script.h
	enum Region: UInt16 {
		case usa = 00
		case france = 01
		case britain = 02
		case germany = 03
		case italy = 04
		case netherlands = 05
		case flemish = 06 // Belgium/Luxembourg
		case sweden = 07
		case spain = 08
		case denmark = 09
		case portugal = 10
		case frenchCanada = 11
		case norway = 12
		case israel = 13
		case japan = 14
		case australia = 15
		case arabic = 16 // Arabia
		case finland = 17
		case frenchSwiss = 18
		case germanSwiss = 19
		case greece = 20
		case iceland = 21
		case malta = 22
		case cyprus = 23
		case turkey = 24
		case yugoslaviaCroatian = 25 // Yugoslavia
		case indiaHindi = 33 // India
		case pakistanUrdu = 34
		case italianSwiss = 36
		case ancientGreek = 40
		case lithuania = 41
		case poland = 42
		case hungary = 43
		case estonia = 44
		case latvia = 45
		case sami = 46 // Lapland
		case faroeIslands = 47 // Faero Islands
		case iran = 48
		case russia = 49
		case ireland = 50
		case korea = 51
		case china = 52
		case taiwan = 53
		case thailand = 54

		var displayName: String {
			let name = String(describing: self)
			return name
		}
	}

	var region = Region.usa

	var shortVersionString = ""

	var getInfoString = ""

	var versionNumber = OperatingSystemVersion()

	required init!(resource inResource: ResKnifeResourceProtocol!) {
		self.resource = inResource
		super.init(window: nil)
		_ = self.window
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.title = resource.defaultWindowTitle()

		showWindow(nil)
	}

	override func windowTitle(forDocumentDisplayName displayName: String) -> String {
		return resource.defaultWindowTitle()
	}

	func parseVers1Resource(from data: Data) {
		guard data.count >= 8 else { return }
		versionNumber = OperatingSystemVersion(versShort: data[..<2])
		release = Release(rawValue: data[2])!
		nonRelease = data[3]
	}

}
