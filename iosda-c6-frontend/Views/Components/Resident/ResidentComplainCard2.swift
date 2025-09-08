import SwiftUI

struct ResidentComplaintCard2: View {
    let complaint: Complaint2
    
    // ✅ Gunakan enum global ComplaintStatus
    private var status: ComplaintStatus {
        ComplaintStatus(raw: complaint.statusName)
    }
    
    private var formattedDate: String {
        guard let date = complaint.openTimestamp else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ID: #\(complaint.id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                // ✅ StatusBadge sekarang menerima enum global
                StatusBadge(status: status)
            }
            
            Text(complaint.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            HStack {
                Text(formatDate(complaint.openTimestamp ?? Date(), format: "HH:mm dd/MM/yyyy"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text("Created: \(formattedDate)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
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
