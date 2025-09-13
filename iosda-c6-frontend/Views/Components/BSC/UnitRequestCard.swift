import SwiftUI

struct UnitRequestCard: View {
    let unit: Unit2
    let resident: User?
    
    private var statusText: String { unit.bscId != nil ? "Approved" : "Pending" }
    private var statusColor: Color { unit.bscId != nil ? .green : .orange }
    
    private var displayDate: String {
        guard let createdAt = unit.createdAt else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: createdAt)
    }

    
    private var unitCodeName: String { unit.name ?? "-" }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.name!)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("Requester: \(resident?.name ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .cornerRadius(6)
                
                Text(displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
