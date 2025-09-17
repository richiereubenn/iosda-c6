import SwiftUI

struct SummaryComplaintCard: View {
    var title: String
    var count: Int
    var category: String
    var backgroundColor: Color
    var icon: String

    // Responsiveness
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            
            // Header
            // Header
            HStack {
                if isCompact {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(title.split(separator: " "), id: \.self) { word in
                            Text(word)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: isCompact ? 32 : 40,
                               height: isCompact ? 32 : 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(backgroundColor)
                        .font(.system(size: isCompact ? 18 : 22,
                                      weight: .semibold))
                }
            }

            
            // Main Number
            Text("\(count)")
                .font(.system(size: isCompact ? 32 : 45,
                              weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7) // biar aman kalau angka panjang
            
            // Sub Info
            Text(category)
                .font(isCompact ? .subheadline : .headline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(isCompact ? 16 : 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [backgroundColor,
                         backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(isCompact ? 14 : 20)
    }
}
