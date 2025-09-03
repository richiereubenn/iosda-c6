import SwiftUI

struct ResidentComplaintCardView: View {
    let complaint: Complaint
    
    private var statusColor: Color {
        guard let status = complaint.status else { return .gray }
        
        switch status.name.lowercased() {
        case "open":
            return .red
        case "under_review":
            return .yellow
        case "waiting_key" :
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
        guard let status = complaint.status else { return "Unknown" }
        
        switch status.name.lowercased() {
        case "under_review":
            return "Under Review"
        case "in_progress":
            return "In Progress"
        default:
            return status.name.capitalized
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
                Text("ID: #\(complaint.id ?? 0)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let statusID = complaint.status?.complaintStatusID {
                    StatusBadge(statusID: statusID)
                }
            }
            
            Text(complaint.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack {
                Text("\(complaint.unit?.block ?? "") \(complaint.unit?.unitNumber ?? "")")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Created: \(formattedDate)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    let mockComplaint = Complaint(
        id: 101,
        unitId: 1,
        statusId: 3,
        progressId: nil,
        classificationId: nil,
        title: "Water Leakage in Ceiling",
        description: "There is a water leakage in the living room ceiling. It started after the recent heavy rain.",
        openTimestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
        closeTimestamp: nil,
        keyHandoverDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        deadlineDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
        latitude: nil,
        longitude: nil,
        handoverMethod: .inHouse,
        unit: Unit(
            id: 1,
            name: "Citraland Surabaya - 01/001",
            bscUuid: nil,
            biUuid: nil,
            contractorUuid: nil,
            keyUuid: nil,
            project: "Citraland Surabaya",
            area: "Northwest Park",
            block: "Block NA",
            unitNumber: "01/001",
            handoverDate: nil,
            renovationPermit: false,
            isApproved: true
        ),
        status: Status(id: 3, name: "waiting_key"),
        classification: nil
    )
    
    Group {
        ResidentComplaintCardView(complaint: mockComplaint)
            .padding()
            .background(Color(.systemBackground))
            .preferredColorScheme(.light)
    }
}
