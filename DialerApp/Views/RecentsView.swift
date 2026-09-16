import SwiftData
import SwiftUI

struct RecentsView: View {
    @Query private var records: [CallRecord]

    init() {
        let projectID = AppScope.projectID
        _records = Query(
            filter: #Predicate<CallRecord> {
                $0.projectID == projectID && $0.isActive && $0.deletedAt == nil
            },
            sort: [SortDescriptor(\CallRecord.startedAt, order: .reverse)]
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView("Henüz arama yok", systemImage: "phone.arrow.up.right", description: Text("Başlattığınız aramalar burada görünür."))
                } else {
                    List(records) { record in
                        HStack(spacing: 14) {
                            Image(systemName: "phone.arrow.up.right.fill").foregroundStyle(.green)
                                .frame(width: 36, height: 36).background(.green.opacity(0.1), in: Circle())
                            VStack(alignment: .leading, spacing: 3) {
                                Text(record.contactName).font(.headline)
                                Text(record.phoneNumber).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(record.startedAt, format: .relative(presentation: .named))
                                .font(.caption).foregroundStyle(.secondary)
                        }.padding(.vertical, 4)
                    }.listStyle(.plain)
                }
            }.navigationTitle("Son Aramalar")
        }
    }
}
