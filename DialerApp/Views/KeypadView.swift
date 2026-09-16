import SwiftData
import SwiftUI

struct KeypadView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = DialerViewModel()

    private let keys = [
        ("1", ""), ("2", "ABC"), ("3", "DEF"),
        ("4", "GHI"), ("5", "JKL"), ("6", "MNO"),
        ("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ"),
        ("*", ""), ("0", "+"), ("#", "")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 10)
                Text(viewModel.number.isEmpty ? "Numara girin" : viewModel.number)
                    .font(.system(size: viewModel.number.count > 14 ? 27 : 34, weight: .medium, design: .rounded))
                    .foregroundStyle(viewModel.number.isEmpty ? .secondary : .primary)
                    .lineLimit(1).minimumScaleFactor(0.7)
                    .frame(height: 45)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(76), spacing: 22), count: 3), spacing: 16) {
                    ForEach(keys, id: \.0) { key in
                        Button { viewModel.append(key.0) } label: {
                            VStack(spacing: 1) {
                                Text(key.0).font(.system(size: 30, weight: .regular, design: .rounded))
                                Text(key.1).font(.system(size: 9, weight: .bold)).tracking(2)
                            }
                            .foregroundStyle(.primary).frame(width: 72, height: 72)
                            .background(.secondary.opacity(0.12), in: Circle())
                        }
                        .buttonStyle(.plain).accessibilityLabel(key.0)
                    }
                }

                HStack(spacing: 32) {
                    Color.clear.frame(width: 58, height: 58)
                    Button { Task { await viewModel.call(context: context) } } label: {
                        Image(systemName: "phone.fill").font(.title2).foregroundStyle(.white)
                            .frame(width: 68, height: 68).background(.green, in: Circle())
                            .shadow(color: .green.opacity(0.25), radius: 12, y: 5)
                    }
                    .disabled(viewModel.number.isEmpty || viewModel.isCalling)
                    .accessibilityLabel("Ara")
                    Button(action: viewModel.deleteLast) {
                        Image(systemName: "delete.left.fill").font(.title2).frame(width: 58, height: 58)
                    }
                    .disabled(viewModel.number.isEmpty).accessibilityLabel("Son haneyi sil")
                }
                Spacer(minLength: 8)
            }
            .padding(.horizontal)
            .navigationTitle("Tuş Takımı").navigationBarTitleDisplayMode(.inline)
            .alert("Arama başlatılamadı", isPresented: Binding(
                get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } }
            )) { Button("Tamam") { viewModel.errorMessage = nil } } message: { Text(viewModel.errorMessage ?? "") }
        }
    }
}
