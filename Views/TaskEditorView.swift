import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var reminderDate: Date
    @State private var hasReminder: Bool
    @State private var priority: TaskPriority
    @State private var showDeleteConfirm = false

    let viewModel: TaskViewModel
    let existingTask: TaskItem?

    init(viewModel: TaskViewModel, task: TaskItem? = nil) {
        self.viewModel = viewModel
        self.existingTask = task
        self._title = State(initialValue: task?.title ?? "")
        self._notes = State(initialValue: task?.notes ?? "")
        self._dueDate = State(initialValue: task?.dueDate ?? Date().addingTimeInterval(86400))
        self._hasDueDate = State(initialValue: task?.dueDate != nil)
        self._reminderDate = State(initialValue: task?.reminderDate ?? Date().addingTimeInterval(3600))
        self._hasReminder = State(initialValue: task?.reminderDate != nil)
        self._priority = State(initialValue: task?.priority ?? .medium)
    }

    var body: some View {
        Form {
            Section {
                TextField("Task title", text: $title)
                TextField("Notes (optional)", text: $notes, axis: .vertical).lineLimit(3)
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.rawValue) { p in
                        Text(p.displayName).tag(p)
                    }
                }
            } header: { Text("Details").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

            Section {
                Toggle("Set Due Date", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    if let days = daysRemaining {
                        HStack {
                            Text("Days Left")
                            Spacer()
                            Text("\(days) days").foregroundStyle(days < 0 ? .red : Color.nSecondary)
                        }
                    }
                }
            } header: { Text("Due Date").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

            Section {
                Toggle("Set Reminder", isOn: $hasReminder)
                if hasReminder {
                    DatePicker("Remind At", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                }
            } header: { Text("Reminder").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

            if existingTask != nil {
                Section {
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        HStack { Spacer(); Text("Delete Task"); Spacer() }
                    }
                }
            }
        }
        .background(Color.nBackground)
        .navigationTitle(existingTask != nil ? "Edit Task" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty) }
        }
        .alert("Delete Task?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { viewModel.deleteTask(existingTask!); dismiss() }
        } message: { Text("This cannot be undone.") }
    }

    private var daysRemaining: Int? {
        guard hasDueDate else { return nil }
        return Calendar.current.numberOfDaysBetween(Date(), and: dueDate)
    }

    private func save() {
        let finalDueDate = hasDueDate ? dueDate : nil
        let finalReminder = hasReminder ? reminderDate : nil
        if let task = existingTask {
            viewModel.updateTask(task, title: title.trimmingCharacters(in: .whitespaces), notes: notes, dueDate: finalDueDate, reminderDate: finalReminder, priority: priority)
        } else {
            viewModel.createTask(title: title.trimmingCharacters(in: .whitespaces), notes: notes, dueDate: finalDueDate, reminderDate: finalReminder, priority: priority)
        }
        dismiss()
    }
}
