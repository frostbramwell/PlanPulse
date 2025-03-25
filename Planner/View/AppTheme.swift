import SwiftUI

struct AppTheme: ViewModifier {
    @ObservedObject private var settings = SettingsViewModel.shared
    
    init() {
        for fontName in ["Roboto-Regular", "Roboto-Medium", "Roboto-Bold", "Roboto-Light"] {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf"),
               let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
               let font = CGFont(fontDataProvider) {
                CTFontManagerRegisterGraphicsFont(font, nil)
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Roboto-Regular", size: 16))
            .foregroundColor(.white)
            .background(settings.selectedBackground.color)
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(AppTheme())
    }
}

extension Font {
    static func robotoRegular(size: CGFloat) -> Font {
        .custom("Roboto-Regular", size: size)
    }
    
    static func robotoMedium(size: CGFloat) -> Font {
        .custom("Roboto-Medium", size: size)
    }
    
    static func robotoBold(size: CGFloat) -> Font {
        .custom("Roboto-Bold", size: size)
    }
    
    static func robotoLight(size: CGFloat) -> Font {
        .custom("Roboto-Light", size: size)
    }
} 
