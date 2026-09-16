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

    private var sections: [(String, [CallRecord])] {
        let calendar = Calendar.current
        let today = records.filter { calendar.isDateInToday($0.startedAt) }
        let yesterday = records.filter { calendar.isDateInYesterday($0.startedAt) }
        let older = records.filter { !calendar.isDateInToday($0.startedAt) && !calendar.isDateInYesterday($0.startedAt) }
        return [("Bugün", today), ("Dün", yesterday), ("Daha Eski", older)].filter { !$0.1.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView("Henüz arama yok", systemImage: "phone.arrow.up.right", description: Text("Başlattığınız aramalar burada görünür."))
                } else {
                    List {
                        ForEach(sections, id: \.0) { section in
                            Section(section.0) {
                                ForEach(section.1) { record in
                                    HStack(spacing: 14) {
                                        Image(systemName: "phone.arrow.up.right.fill").foregroundStyle(.green)
                                            .frame(width: 36, height: 36).background(.green.opacity(0.1), in: Circle())
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(record.contactName).font(.headline)
                                            Text(record.company.isEmpty ? PhoneNumber.formatted(record.phoneNumber) : record.company).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(record.startedAt, format: .dateTime.hour().minute()).font(.caption).foregroundStyle(.secondary)
                                    }.padding(.vertical, 4)
                                }
                            }
                        }
                    }.listStyle(.plain)
                }
            }.navigationTitle("Son Aramalar")
        }
    }
}
