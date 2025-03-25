import SwiftUI

struct CategoryColorPair: Identifiable {
    let id = UUID()
    let background: Color
    let text: Color
    
    init(background: Color, text: Color) {
        self.background = background
        self.text = text
    }
}

struct CategoryColors {
    static let colorPairs: [CategoryColorPair] = [
        CategoryColorPair(
            background: Color(red: 112/255, green: 70/255, blue: 70/255, opacity: 1),
            text: Color(red: 130/255, green: 83/255, blue: 83/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 112/255, green: 108/255, blue: 70/255, opacity: 1),
            text: Color(red: 130/255, green: 125/255, blue: 83/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 78/255, green: 112/255, blue: 70/255, opacity: 1),
            text: Color(red: 93/255, green: 130/255, blue: 83/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 70/255, green: 112/255, blue: 99/255, opacity: 1),
            text: Color(red: 83/255, green: 130/255, blue: 116/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 70/255, green: 87/255, blue: 112/255, opacity: 1),
            text: Color(red: 83/255, green: 102/255, blue: 130/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 91/255, green: 70/255, blue: 112/255, opacity: 1),
            text: Color(red: 107/255, green: 83/255, blue: 130/255, opacity: 1)
        ),
        CategoryColorPair(
            background: Color(red: 112/255, green: 70/255, blue: 95/255, opacity: 1),
            text: Color(red: 130/255, green: 83/255, blue: 111/255, opacity: 1)
        )
    ]
    
    static func getRandomColorPair() -> CategoryColorPair {
        return colorPairs.randomElement() ?? colorPairs[0]
    }
} 