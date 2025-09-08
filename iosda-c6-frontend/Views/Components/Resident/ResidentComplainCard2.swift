import SwiftUI

struct ResidentComplaintCard2: View {
    let complaint: Complaint2
    
    private var statusColor: Color {
        guard let status = complaint.statusName?.lowercased() else { return .gray }
        
        switch status {
        case "open":
            return .red
        case "under_review":
            return .yellow
        case "waiting_key":
            return .orange
        case "in_progress":
            return .blue
        case "resolved":
            return .green
        case "rejected":
            return .gray
        default:
            return .gray
        }
    }
    
    private var statusDisplayName: String {
        guard let status = complaint.statusName else { return "Unknown" }
        
        switch status.lowercased() {
        case "under review":
            return "Under Review"
        case "in progress":
            return "In Progress"
        case "waiting_key":
            return "Waiting Key"
        default:
            return status.capitalized
        }
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
                
                if let statusName = complaint.statusName {
                    Text(statusDisplayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())
                }
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
