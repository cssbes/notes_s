import SwiftUI

struct InsightsView: View {
    let insights: InsightsService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statRow(icon: "note.text", label: "Total Notes", value: "\(insights.totalNotes)")
                    statRow(icon: "text.word.count", label: "Total Words", value: "\(insights.totalWords)")
                    statRow(icon: "folder", label: "Folders", value: "\(insights.totalFolders)")
                    statRow(icon: "tag", label: "Tags", value: "\(insights.totalTags)")
                    statRow(icon: "checklist", label: "Tasks", value: "\(insights.totalTasks)")
                } header: { Text("Overview").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    statRow(icon: "flame.fill", label: "Day Streak", value: "\(insights.currentStreak)", color: .orange)
                    statRow(icon: "calendar.day.fill", label: "Active Days (Month)", value: "\(insights.activeDaysLastMonth)")
                    statRow(icon: "clock.arrow.circlepath", label: "This Week Notes", value: "\(insights.thisWeekNotes)")
                    statRow(icon: "text.word.count", label: "This Week Words", value: "\(insights.thisWeekWords)")
                } header: { Text("Activity").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    statRow(icon: "number", label: "Avg Words/Note", value: "\(insights.averageWordsPerNote)")
                    if let longest = insights.longestNote {
                        statRow(icon: "ruler.fill", label: "Longest Note", value: longest)
                    }
                    statRow(icon: "pin.fill", label: "Pinned", value: "\(insights.totalPinned)")
                    statRow(icon: "star.fill", label: "Favorites", value: "\(insights.totalFavorites)")
                } header: { Text("Details").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }
            }
            .listStyle(.insetGrouped)
            .background(Color.nBackground)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private func statRow(icon: String, label: String, value: String, color: Color = Color.nAccent) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color).frame(width: 24)
            Text(label).font(.system(size: 14)).foregroundStyle(Color.nText)
            Spacer()
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.nSecondary).monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}
