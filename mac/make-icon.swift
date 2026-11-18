// Draws the 1024px app icon to the path given as the first argument.
import Cocoa
let S: CGFloat = 1024
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon1024.png"
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
NSColor.clear.set(); NSRect(x: 0, y: 0, width: S, height: S).fill()
let p = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
NSColor.black.setFill(); p.fill()
NSColor(srgbRed: 0.043, green: 0.353, blue: 0.169, alpha: 1).setStroke(); p.lineWidth = 10; p.stroke()
let green = NSColor(srgbRed: 0, green: 0.89, blue: 0.353, alpha: 1)
let dim = NSColor(srgbRed: 0.043, green: 0.478, blue: 0.208, alpha: 1)
func draw(_ s: String, _ size: CGFloat, _ c: NSColor, _ y: CGFloat) {
    let a: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedSystemFont(ofSize: size, weight: .bold), .foregroundColor: c]
    let t = NSAttributedString(string: s, attributes: a)
    t.draw(at: NSPoint(x: (S - t.size().width) / 2, y: y))
}
draw("$ type", 110, dim, 705)
draw("fj", 400, green, 250)
green.setFill(); NSRect(x: 362, y: 235, width: 300, height: 26).fill()
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
