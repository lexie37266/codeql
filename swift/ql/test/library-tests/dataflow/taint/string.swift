
// --- stubs ---

typealias unichar = UInt16

struct Locale {
}

struct FilePath {
  init(_ string: String) {}

  var `extension`: String? { get { "" } set {} }
  var stem: String? { get { "" } }
  var string: String { get { "" } }
  var description: String { get { "" } }
  var debugDescription: String { get { "" } }

  mutating func append(_ other: String) {}
  func appending(_ other: String) -> FilePath { return FilePath("") }

  func withCString<Result>(_ body: (UnsafePointer<CChar>) throws -> Result) rethrows -> Result {
    return 0 as! Result
  }
  func withPlatformString<Result>(_ body: (UnsafePointer<CInterop.PlatformChar>) throws -> Result) rethrows -> Result {
    return 0 as! Result
  }
}

enum CInterop {
  typealias Char = CChar
  typealias PlatformChar = CInterop.Char
}

struct CharacterSet {
  static var whitespaces: CharacterSet { get { return CharacterSet() } }
}

class NSObject {
}

class NSString : NSObject {
  struct CompareOptions : OptionSet {
    init(rawValue: UInt) { self.rawValue = rawValue }

    var rawValue: UInt
  }
}

extension String : CVarArg {
  typealias CompareOptions = NSString.CompareOptions

  public var _cVarArgEncoding: [Int] { get { return [] } }
  static var availableStringEncodings: [String.Encoding] { get { [] } }
  static var defaultCStringEncoding: String.Encoding { get { String.Encoding.utf8 } }

	struct Encoding {
		static let utf8 = Encoding()
	}

	init?(data: Data, encoding: Encoding) { self.init() }

  init(decoding path: FilePath) { self.init() }

  init(format: String, _ arguments: CVarArg...) { self.init() }
  init(format: String, arguments: [CVarArg]) { self.init() }
  init(format: String, locale: Locale?, _ args: CVarArg...) { self.init() }
  init(format: String, locale: Locale?, arguments: [CVarArg]) { self.init() }

  static func localizedStringWithFormat(_ format: String, _ arguments: CVarArg...) -> String { return "" }

  init?<S>(bytes: S, encoding: String.Encoding) where S : Sequence, S.Element == UInt8 { self.init() }

  init(cString nullTerminatedUTF8: UnsafePointer<CChar>) { self.init() }
  init(cString nullTerminatedUTF8: UnsafePointer<UInt8>) { self.init() }
  init?(bytesNoCopy bytes: UnsafeMutableRawPointer, length: Int, encoding: String.Encoding, freeWhenDone flag: Bool) { self.init() }
  init?(utf8String bytes: UnsafePointer<CChar>) { self.init() }
  init(utf16CodeUnits: UnsafePointer<unichar>, count: Int) { self.init() }
  init(utf16CodeUnitsNoCopy: UnsafePointer<unichar>, count: Int, freeWhenDone flag: Bool) { self.init() }

  init(platformString: UnsafePointer<CInterop.PlatformChar>) { self.init() }
  init?(validatingPlatformString platformStrinbg: UnsafePointer<CInterop.PlatformChar>) { self.init() }
  func withPlatformString<Result>(_ body: (UnsafePointer<CInterop.PlatformChar>) throws -> Result) rethrows -> Result { return 0 as! Result }

  init?(validating path: FilePath) { self.init() }
}

extension StringProtocol {
  var capitalized: String { get { "" } }
  var localizedCapitalized: String { get { "" } }
  var localizedLowercase: String { get { "" } }
  var localizedUppercase: String { get { "" } }
  var removingPercentEncoding: String? { get { "" } }
  var decomposedStringWithCanonicalMapping: String { get { "" } }
  var decomposedStringWithCompatibilityMapping: String { get { "" } }
  var precomposedStringWithCanonicalMapping: String { get { "" } }
  var precomposedStringWithCompatibilityMapping: String { get { "" } }

  func lowercased(with locale: Locale?) -> String { return "" }
  func uppercased(with locale: Locale?) -> String { return "" }
  func capitalized(with locale: Locale?) -> String { return "" }
  func substring(from index: Self.Index) -> String { return "" }
  func trimmingCharacters(in set: CharacterSet) -> String { return "" }
  func appending<T>(_ aString: T) -> String where T : StringProtocol { return "" }
  func padding<T>(toLength newLength: Int, withPad padString: T, startingAt padIndex: Int) -> String where T: StringProtocol { return "" }
  func components(separatedBy separator: CharacterSet) -> [String] { return [] }
  func folding(options: String.CompareOptions = [], locale: Locale?) -> String { return "" }
  func propertyListFromStringsFileFormat() -> [String : String] { return [:] }
  func cString(using encoding: String.Encoding) -> [CChar]? { return nil }
  func enumerateLines(invoking body: @escaping (String, inout Bool) -> Void) {}
}

class Data
{
    init<S>(_ elements: S) {}
}

extension Data : Collection {
  typealias Index = Int

  var startIndex: Data.Index { get { return 0 } }
  var endIndex: Data.Index { get { return 0 } }
  subscript(index: Data.Index) -> UInt8 { get { return 0 } }
  func index(after i: Data.Index) -> Data.Index { return 0 }
}

// --- tests ---

func source() -> Int { return 0; }
func sink(arg: Any) {}

func taintThroughInterpolatedStrings() {
  var x = source()

  sink(arg: "\(x)") // $ tainted=132

  sink(arg: "\(x) \(x)") // $ tainted=132

  sink(arg: "\(x) \(0) \(x)") // $ tainted=132

  let y = 42

  sink(arg: "\(y)") // clean

  sink(arg: "\(x) hello \(y)") // $ tainted=132

  sink(arg: "\(y) world \(x)") // $ tainted=132

  x = 0
  sink(arg: "\(x)") // clean
}

func source2() -> String { return ""; }

func taintThroughStringConcatenation() {
  let clean = "abcdef"
  let tainted = source2()

  sink(arg: clean)
  sink(arg: tainted) // $ tainted=156

  sink(arg: clean + clean)
  sink(arg: clean + tainted) // $ tainted=156
  sink(arg: tainted + clean) // $ tainted=156
  sink(arg: tainted + tainted) // $ tainted=156

  sink(arg: ">" + clean + "<")
  sink(arg: ">" + tainted + "<") // $ tainted=156

  sink(arg: clean.appending(clean))
  sink(arg: clean.appending(tainted)) // $ tainted=156
  sink(arg: tainted.appending(clean)) // $ tainted=156
  sink(arg: tainted.appending(tainted)) // $ tainted=156

  var str = "abc"
  sink(arg: str)
  str += "def"
  sink(arg: str)
  str += source2()
  sink(arg: str) // $ MISSING: tainted=178

  var str2 = "abc"
  sink(arg: str2)
  str2.append("def")
  sink(arg: str2)
  str2.append(source2())
  sink(arg: str2) // $ tainted=185

  var str3 = "abc"
  sink(arg: str3)
  str3.append(contentsOf: "def")
  sink(arg: str3)
  str3.append(contentsOf: source2())
  sink(arg: str3) // $ tainted=192

  var str4 = "abc"
  sink(arg: str4)
  str4.write("def")
  sink(arg: str4)
  str4.write(source2())
  sink(arg: str4) // $ tainted=199

  var str5 = "abc"
  sink(arg: str5)
  str5.insert(contentsOf: "abc", at: str5.startIndex)
  sink(arg: str5)
  str5.insert(contentsOf: source2(), at: str5.startIndex)
  sink(arg: str5) // $ tainted=206
}

func taintThroughSimpleStringOperations() {
  let clean = ""
  let tainted = source2()
  let taintedInt = source()

  sink(arg: String(clean))
  sink(arg: String(tainted)) // $ tainted=212
  sink(arg: String(taintedInt)) // $ tainted=213

  sink(arg: String(format: tainted, 1, 2, 3)) // $ tainted=212
  sink(arg: String(format: tainted, arguments: [])) // $ tainted=212
  sink(arg: String(format: tainted, locale: nil, 1, 2, 3)) // $ tainted=212
  sink(arg: String(format: tainted, locale: nil, arguments: [])) // $ tainted=212
  sink(arg: String.localizedStringWithFormat(tainted, 1, 2, 3)) // $ tainted=212
  sink(arg: String(format: "%s", tainted)) // $ MISSING: tainted=212
  sink(arg: String(format: "%i %i %i", 1, 2, taintedInt)) // $ MISSING: tainted=213

  sink(arg: String(repeating: clean, count: 2))
  sink(arg: String(repeating: tainted, count: 2)) // $ tainted=212

  sink(arg: tainted.dropFirst(10)) // $ tainted=212
  sink(arg: tainted.dropLast(10)) // $ tainted=212
  sink(arg: tainted.substring(from: tainted.startIndex)) // $ tainted=212

  sink(arg: tainted.lowercased()) // $ tainted=212
  sink(arg: tainted.uppercased()) // $ tainted=212
  sink(arg: tainted.lowercased(with: nil)) // $ tainted=212
  sink(arg: tainted.uppercased(with: nil)) // $ tainted=212
  sink(arg: tainted.capitalized(with: nil)) // $ tainted=212
  sink(arg: tainted.reversed()) // $ tainted=212

  sink(arg: tainted.split(separator: ",")) // $ tainted=212
  sink(arg: tainted.split(whereSeparator: { // $ tainted=212
    c in return (c == ",")
  }))
  sink(arg: tainted.trimmingCharacters(in: CharacterSet.whitespaces)) // $ tainted=212
  sink(arg: tainted.padding(toLength: 20, withPad: " ", startingAt: 0)) // $ tainted=212
  sink(arg: tainted.components(separatedBy: CharacterSet.whitespaces)) // $ tainted=212
  sink(arg: tainted.components(separatedBy: CharacterSet.whitespaces)[0]) // $ tainted=212
  sink(arg: tainted.folding(locale: nil)) // $ tainted=212
  sink(arg: tainted.propertyListFromStringsFileFormat()) // $ tainted=212
  sink(arg: tainted.propertyListFromStringsFileFormat()["key"]!) // $ tainted=212

  sink(arg: clean.enumerateLines(invoking: {
    line, stop in
    sink(arg: line)
    sink(arg: stop)
  }))
  sink(arg: tainted.enumerateLines(invoking: {
    line, stop in
    sink(arg: line) // $ MISSING: tainted=212
    sink(arg: stop)
  }))

  sink(arg: [clean, clean].joined())
  sink(arg: [tainted, clean].joined()) // $ MISSING: tainted=212
  sink(arg: [clean, tainted].joined()) // $ MISSING: tainted=212
  sink(arg: [tainted, tainted].joined()) // $ MISSING: tainted=212

  sink(arg: clean.description)
  sink(arg: tainted.description) // $ tainted=212
  sink(arg: clean.debugDescription)
  sink(arg: tainted.debugDescription) // $ tainted=212
  sink(arg: clean.utf8)
  sink(arg: tainted.utf8) // $ tainted=212
  sink(arg: clean.utf16)
  sink(arg: tainted.utf16) // $ tainted=212
  sink(arg: clean.unicodeScalars)
  sink(arg: tainted.unicodeScalars) // $ tainted=212
  sink(arg: clean.utf8CString)
  sink(arg: tainted.utf8CString) // $ tainted=212
  sink(arg: clean.lazy)
  sink(arg: tainted.lazy) // $ tainted=212
  sink(arg: clean.capitalized)
  sink(arg: tainted.capitalized) // $ tainted=212
  sink(arg: clean.localizedCapitalized)
  sink(arg: tainted.localizedCapitalized) // $ tainted=212
  sink(arg: clean.localizedLowercase)
  sink(arg: tainted.localizedLowercase) // $ tainted=212
  sink(arg: clean.localizedUppercase)
  sink(arg: tainted.localizedUppercase) // $ tainted=212
  sink(arg: clean.decomposedStringWithCanonicalMapping)
  sink(arg: tainted.decomposedStringWithCanonicalMapping) // $ tainted=212
  sink(arg: clean.precomposedStringWithCompatibilityMapping)
  sink(arg: tainted.precomposedStringWithCompatibilityMapping) // $ tainted=212
  sink(arg: clean.removingPercentEncoding!)
  sink(arg: tainted.removingPercentEncoding!) // $ tainted=212
}

func taintThroughMutatingStringOperations() {
  var str1 = source2()
  sink(arg: str1) // $ tainted=300
  sink(arg: str1.remove(at: str1.startIndex)) // $ tainted=300
  sink(arg: str1) // $ tainted=300

  var str2 = source2()
  sink(arg: str2) // $ tainted=305
  str2.removeAll()
  sink(arg: str2) // $ SPURIOUS: tainted=305

  var str3 = source2()
  sink(arg: str3) // $ tainted=310
  str3.removeAll(where: { _ in true } )
  sink(arg: str3) // $ SPURIOUS: tainted=310

  var str4 = source2()
  sink(arg: str4) // $ tainted=315
  sink(arg: str4.removeFirst()) // $ tainted=315
  sink(arg: str4) // $ tainted=315
  str4.removeFirst(5)
  sink(arg: str4) // $ tainted=315
  sink(arg: str4.removeLast()) // $ tainted=315
  sink(arg: str4) // $ tainted=315
  str4.removeLast(5)
  sink(arg: str4) // $ tainted=315

  var str5 = source2()
  sink(arg: str5) // $ tainted=326
  str5.removeSubrange(str5.startIndex ... str5.index(str5.startIndex, offsetBy: 5))
  sink(arg: str5) // $ tainted=326

  var str6 = source2()
  sink(arg: str6) // $ tainted=331
  str6.makeContiguousUTF8()
  sink(arg: str6) // $ tainted=331
}

func source3() -> Data { return Data("") }

func taintThroughData() {
  let stringClean = String(data: Data(""), encoding: String.Encoding.utf8)
  let stringTainted = String(data: source3(), encoding: String.Encoding.utf8)

	sink(arg: stringClean!)
	sink(arg: stringTainted!) // $ tainted=341

  sink(arg: String(decoding: Data(""), as: UTF8.self))
  sink(arg: String(decoding: source3(), as: UTF8.self)) // $ tainted=347
}

func taintThroughEncodings() {
  var clean = ""
  var tainted = source2()

  clean.withUTF8({
    buffer in
    sink(arg: buffer)
    sink(arg: buffer.baseAddress!)
  })
  tainted.withUTF8({
    buffer in
    sink(arg: buffer) // $ MISSING: tainted=352
    sink(arg: buffer.baseAddress!) // $ MISSING: tainted=352
  })

  clean.withCString({
    ptr in
    sink(arg: ptr)
  })
  tainted.withCString({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=352
  })
  clean.withCString(encodedAs: UTF8.self, {
    ptr in
    sink(arg: ptr)
  })
  tainted.withCString(encodedAs: UTF8.self, {
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=352
  })

  let arrayString1 = clean.cString(using: String.Encoding.utf8)!
  sink(arg: arrayString1)
  arrayString1.withUnsafeBufferPointer({
    buffer in
    sink(arg: buffer)
    sink(arg: String(cString: buffer.baseAddress!))
  })
  let arrayString2 = tainted.cString(using: String.Encoding.utf8)!
  sink(arg: arrayString2) // $ tainted=352
  arrayString1.withUnsafeBufferPointer({
    buffer in
    sink(arg: buffer) // $ MISSING: tainted=352
    sink(arg: String(cString: buffer.baseAddress!)) // $ MISSING: tainted=352
  })

  clean.withPlatformString({
    ptr in
    sink(arg: ptr)
    sink(arg: String(platformString: ptr))

    let buffer = UnsafeBufferPointer(start: ptr, count: 10)
    let arrayString = Array(buffer)
    sink(arg: buffer)
    sink(arg: arrayString)
    sink(arg: String(platformString: arrayString))
  })
  tainted.withPlatformString({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=352
    sink(arg: String(platformString: ptr)) // $ MISSING: tainted=352

    let buffer = UnsafeBufferPointer(start: ptr, count: 10)
    let arrayString = Array(buffer)
    sink(arg: buffer) // $ MISSING: tainted=352
    sink(arg: arrayString) // $ MISSING: tainted=352
    sink(arg: String(platformString: arrayString)) // $ MISSING: tainted=352
  })

  clean.withContiguousStorageIfAvailable({
    ptr in
    sink(arg: ptr)
    sink(arg: ptr.baseAddress!)
  })
  tainted.withContiguousStorageIfAvailable({
    ptr in
    sink(arg: ptr)
    sink(arg: ptr.baseAddress!) // $ MISSING: tainted=352
  })
}

func source4() -> [UInt8] { return [] }

func taintFromUInt8Array() {
  var cleanUInt8Values: [UInt8] = [0x41, 0x42, 0x43, 0] // "ABC"
  var taintedUInt8Values = source4()

  sink(arg: String(unsafeUninitializedCapacity: 256, initializingUTF8With: {
    (buffer: UnsafeMutableBufferPointer<UInt8>) -> Int in
      sink(arg: buffer)
      let _ = buffer.initialize(from: cleanUInt8Values)
      sink(arg: buffer)
      return 3
    }
  ))
  sink(arg: String(unsafeUninitializedCapacity: 256, initializingUTF8With: { // $ MISSING: tainted=436
    (buffer: UnsafeMutableBufferPointer<UInt8>) -> Int in
      sink(arg: buffer)
      let _ = buffer.initialize(from: taintedUInt8Values)
      sink(arg: buffer) // $ MISSING: tainted=436
      return 256
    }
  ))

  sink(arg: String(bytes: cleanUInt8Values, encoding: String.Encoding.utf8)!)
  sink(arg: String(bytes: taintedUInt8Values, encoding: String.Encoding.utf8)!) // $ tainted=436

  sink(arg: String(cString: cleanUInt8Values))
  sink(arg: String(cString: taintedUInt8Values)) // $ tainted=436

  try! cleanUInt8Values.withUnsafeBufferPointer({
    (buffer: UnsafeBufferPointer<UInt8>) throws in
    sink(arg: buffer)
    sink(arg: buffer.baseAddress!)
    sink(arg: String(cString: buffer.baseAddress!))
  })
  try! taintedUInt8Values.withUnsafeBufferPointer({
    (buffer: UnsafeBufferPointer<UInt8>) throws in
    sink(arg: buffer) // $ MISSING: tainted=436
    sink(arg: buffer.baseAddress!) // $ MISSING: tainted=436
    sink(arg: String(cString: buffer.baseAddress!)) // $ MISSING: tainted=436
  })

  try! cleanUInt8Values.withUnsafeMutableBytes({
    (buffer: UnsafeMutableRawBufferPointer) throws in
    sink(arg: buffer)
    sink(arg: buffer.baseAddress!)
    sink(arg: String(bytesNoCopy: buffer.baseAddress!, length: buffer.count, encoding: String.Encoding.utf8, freeWhenDone: false)!)
  })
  try! taintedUInt8Values.withUnsafeMutableBytes({
    (buffer: UnsafeMutableRawBufferPointer) throws in
    sink(arg: buffer) // $ MISSING: tainted=436
    sink(arg: buffer.baseAddress!) // $ MISSING: tainted=436
    sink(arg: String(bytesNoCopy: buffer.baseAddress!, length: buffer.count, encoding: String.Encoding.utf8, freeWhenDone: false)!) // $ MISSING: tainted=436
  })
}

func source5() -> [CChar] { return [] }

func taintThroughCCharArray() {
  let cleanCCharValues: [CChar] = [0x41, 0x42, 0x43, 0]
  let taintedCCharValues: [CChar] = source5()

  cleanCCharValues.withUnsafeBufferPointer({
    ptr in
    sink(arg: ptr)
    sink(arg: ptr.baseAddress!)
    sink(arg: String(utf8String: ptr.baseAddress!)!)
    sink(arg: String(validatingUTF8: ptr.baseAddress!)!)
    sink(arg: String(cString: ptr.baseAddress!))
  })
  taintedCCharValues.withUnsafeBufferPointer({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=492
    sink(arg: ptr.baseAddress!) // $ MISSING: tainted=492
    sink(arg: String(utf8String: ptr.baseAddress!)!) // $ MISSING: tainted=492
    sink(arg: String(validatingUTF8: ptr.baseAddress!)!) // $ MISSING: tainted=492
    sink(arg: String(cString: ptr.baseAddress!)) // $ MISSING: tainted=492
  })

  sink(arg: String(cString: cleanCCharValues))
  sink(arg: String(cString: taintedCCharValues)) // $ tainted=492
}

func source6() -> [unichar] { return [] }

func taintThroughUnicharArray() {
  let cleanUnicharValues: [unichar] = [0x41, 0x42, 0x43, 0]
  let taintedUnicharValues: [unichar] = source6()

  cleanUnicharValues.withUnsafeBufferPointer({
    ptr in
    sink(arg: ptr)
    sink(arg: ptr.baseAddress!)
    sink(arg: String(utf16CodeUnits: ptr.baseAddress!, count: ptr.count))
    sink(arg: String(utf16CodeUnitsNoCopy: ptr.baseAddress!, count: ptr.count, freeWhenDone: false))
  })
  taintedUnicharValues.withUnsafeBufferPointer({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=519
    sink(arg: ptr.baseAddress!) // $ MISSING: tainted=519
    sink(arg: String(utf16CodeUnits: ptr.baseAddress!, count: ptr.count)) // $ MISSING: tainted=519
    sink(arg: String(utf16CodeUnitsNoCopy: ptr.baseAddress!, count: ptr.count, freeWhenDone: false)) // $ MISSING: tainted=519
  })
}

func source7() -> Substring { return Substring() }

func taintThroughSubstring() {
  let tainted = source2()

  sink(arg: source7()) // $ tainted=542

  let sub1 = tainted[tainted.startIndex ..< tainted.endIndex]
  sink(arg: sub1) // $ tainted=540
  sink(arg: String(sub1)) // $ tainted=540

  let sub2 = tainted.prefix(10)
  sink(arg: sub2) // $ tainted=540
  sink(arg: String(sub2)) // $ tainted=540

  let sub3 = tainted.prefix(through: tainted.endIndex)
  sink(arg: sub3) // $ tainted=540
  sink(arg: String(sub3)) // $ tainted=540

  let sub4 = tainted.prefix(upTo: tainted.endIndex)
  sink(arg: sub4) // $ tainted=540
  sink(arg: String(sub4)) // $ tainted=540

  let sub5 = tainted.suffix(10)
  sink(arg: sub5) // $ tainted=540
  sink(arg: String(sub5)) // $ tainted=540

  let sub6 = tainted.suffix(from: tainted.startIndex)
  sink(arg: sub6) // $ tainted=540
  sink(arg: String(sub6)) // $ tainted=540
}

func taintedThroughFilePath() {
  let clean = FilePath("")
  let tainted = FilePath(source2())

  sink(arg: clean)
  sink(arg: tainted) // $ MISSING: tainted=571

  sink(arg: tainted.extension!) // $ MISSING: tainted=571
  sink(arg: tainted.stem!) // $ MISSING: tainted=571
  sink(arg: tainted.string) // $ MISSING: tainted=571
  sink(arg: tainted.description) // $ MISSING: tainted=571
  sink(arg: tainted.debugDescription) // $ MISSING: tainted=571

  sink(arg: String(decoding: tainted)) // $ MISSING: tainted=571
  sink(arg: String(validating: tainted)!) // $ MISSING: tainted=571

  let _ = clean.withCString({
    ptr in
    sink(arg: ptr)
  })
  let _ = tainted.withCString({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=571
  })

  let _ = clean.withPlatformString({
    ptr in
    sink(arg: ptr)
    sink(arg: String(platformString: ptr))
    sink(arg: String(validatingPlatformString: ptr)!)
  })
  let _ = tainted.withPlatformString({
    ptr in
    sink(arg: ptr) // $ MISSING: tainted=571
    sink(arg: String(platformString: ptr)) // $ MISSING: tainted=571
    sink(arg: String(validatingPlatformString: ptr)!) // $ MISSING: tainted=571
  })

  var fp1 = FilePath("")
  sink(arg: fp1)
  fp1.append(source2())
  sink(arg: fp1) // $ MISSING: tainted=609
  fp1.append("")
  sink(arg: fp1) // $ MISSING: tainted=609

  sink(arg: clean.appending(""))
  sink(arg: clean.appending(source2())) // $ MISSING: tainted=615
  sink(arg: tainted.appending("")) // $ MISSING: tainted=571
  sink(arg: tainted.appending(source2())) // $ MISSING: tainted=571,617
}

func taintedThroughConversion() {
  sink(arg: String(0))
  sink(arg: String(source())) // $ tainted=622
  sink(arg: Int(0).description)
  sink(arg: source().description) // $ MISSING: tainted=624
  sink(arg: String(describing: 0))
  sink(arg: String(describing: source())) // $ tainted=626

  sink(arg: Int("123")!)
  sink(arg: Int(source2())!) // $ MISSING: tainted=629
}

func untaintedFields() {
  let tainted = source2()

  sink(arg: String.availableStringEncodings)
  sink(arg: String.defaultCStringEncoding)
  sink(arg: tainted.isContiguousUTF8)
}
