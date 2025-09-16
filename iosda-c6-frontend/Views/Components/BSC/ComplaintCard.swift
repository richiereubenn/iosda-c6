import SwiftUI

struct ComplaintCard: View {
    let complaint: Complaint2
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var status: ComplaintStatus {
        ComplaintStatus(raw: complaint.statusName)
    }
    
    private var formattedDate: String {
        guard let date = complaint.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    private var isIpad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isIpad ? 12 : 10) {
            HStack {
                Text("ID: #\(complaint.id)")
                    .font(isIpad ? .subheadline : .callout)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                StatusBadge(status: status)
                
            }
        
            HStack {
                Text(complaint.title)
                    .font(isIpad ? .title2 : .subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .offset(y:-2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Created: \(formattedDate)")
                    .font(isIpad ? .callout : .footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(isIpad ? 16 : 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBackground, lineWidth: 0.5)
        )
    }
}


extension Complaint2 {
    static let sample1 = Complaint2(
        id: "C-001",
        unitId: "U-101",
        userId: "USR-01",
        statusId: "ST-OPEN",
        classificationId: "CL-01",
        title: "AC tidak berfungsi",
        description: "AC tiba-tiba mati dan tidak dingin sama sekali.",
        openTimestamp: Date(),
        closeTimestamp: nil,
        keyHandoverDate: nil,
        deadlineDate: nil,
        latitude: nil,
        longitude: nil,
        handoverMethod: nil,
        workDetail: nil,
        workDuration: nil,
        duedate: nil,
        createdAt: Date(),
        updatedAt: Date(),
        statusName: "Open",
        classificationName: "Fasilitas"
    )
    
    static let sample2 = Complaint2(
        id: "C-002",
        unitId: "U-202",
        userId: "USR-02",
        statusId: "ST-PROGRESS",
        classificationId: "CL-02",
        title: "Lampu koridor mati",
        description: "Lampu koridor lantai 3 mati sejak kemarin.",
        openTimestamp: Date().addingTimeInterval(-86400), // 1 hari lalu
        closeTimestamp: nil,
        keyHandoverDate: nil,
        deadlineDate: nil,
        latitude: nil,
        longitude: nil,
        handoverMethod: nil,
        workDetail: nil,
        workDuration: nil,
        duedate: nil,
        createdAt: Date().addingTimeInterval(-86400),
        updatedAt: Date(),
        statusName: "In Progress",
        classificationName: "Listrik"
    )
}

struct ComplaintCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComplaintCard(complaint: .sample1)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Sample 1 - iPhone")

            ComplaintCard(complaint: .sample2)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDevice("iPad Pro (11-inch) (4th generation)")
                .previewDisplayName("Sample 2 - iPad")
        }
    }
}
