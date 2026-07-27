import SwiftUI

struct TasksView: View {
    @State private var viewModel: TaskViewModel
    @State private var showNewTask = false
    @State private var showSortPicker = false
    @State private var selectedTask: TaskItem?

    init(viewModel: TaskViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.tasks.isEmpty {
                    emptyState
                } else {
                    sectionList
                }
            }
            .background(Color.nBackground)
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button { showSortPicker = true } label: {
                            Image(systemName: "arrow.up.arrow.down").foregroundStyle(Color.nAccent)
                        }
                        Button { showNewTask = true } label: {
                            Image(systemName: "plus").foregroundStyle(Color.nAccent)
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewTask) {
                NavigationStack { TaskEditorView(viewModel: viewModel) }
            }
            .sheet(item: $selectedTask) { task in
                NavigationStack { TaskEditorView(viewModel: viewModel, task: task) }
            }
            .confirmationDialog("Sort By", isPresented: $showSortPicker) {
                ForEach(TaskSortOption.allCases, id: \.rawValue) { option in
                    Button(option.displayName) { viewModel.sortOption = option; viewModel.loadTasks() }
                }
            }
            .onAppear { Task { await NotificationService.shared.requestAuthorization() }; viewModel.loadTasks() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checklist").font(.system(size: 40)).foregroundStyle(Color.nSecondary)
            Text("No Tasks").font(.headline)
            Text("Tap + to add your first task").font(.subheadline).foregroundStyle(Color.nSecondary)
            Spacer()
        }
    }

    private var sectionList: some View {
        List {
            if !viewModel.overdueTasks.isEmpty {
                Section {
                    ForEach(viewModel.overdueTasks) { taskRow($0) }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.red).font(.caption)
                        Text("Overdue").foregroundStyle(.red)
                    }
                }
            }
            if !viewModel.todayTasks.isEmpty {
                Section {
                    ForEach(viewModel.todayTasks) { taskRow($0) }
                } header: {
                    HStack {
                        Image(systemName: "circle.fill").foregroundStyle(Color.nAccent).font(.system(size: 6))
                        Text("Today")
                    }
                }
            }
            if !viewModel.upcomingTasks.isEmpty {
                Section {
                    ForEach(viewModel.upcomingTasks) { taskRow($0) }
                } header: {
                    HStack {
                        Image(systemName: "calendar").foregroundStyle(Color.nSecondary).font(.caption)
                        Text("Upcoming")
                    }
                }
            }
            if !viewModel.noDateTasks.isEmpty {
                Section {
                    ForEach(viewModel.noDateTasks) { taskRow($0) }
                } header: { Text("No Date") }
            }
            if !viewModel.completedTasks.isEmpty {
                Section {
                    ForEach(viewModel.completedTasks) { taskRow($0) }
                } header: { Text("Completed") }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func taskRow(_ task: TaskItem) -> some View {
        Button { selectedTask = task } label: {
            HStack(spacing: 12) {
                Button { viewModel.toggleComplete(task) } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .green : Color.nSecondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(task.isCompleted ? Color.nSecondary : Color.nText)
                        .strikethrough(task.isCompleted)
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.system(size: 10))
                            Text(task.formattedDueDate).font(.system(size: 11))
                            if let days = task.daysRemaining {
                                Text("(\(days)d left)").font(.system(size: 10))
                            }
                        }
                        .foregroundStyle(task.isOverdue ? .red : Color.nSecondary)
                    }
                    if !task.notes.isEmpty {
                        Text(task.notes).font(.system(size: 12)).foregroundStyle(Color.nTertiary).lineLimit(1)
                    }
                }

                Spacer()

                priorityBadge(task.priority)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { viewModel.deleteTask(task) } label: { Label("Delete", systemImage: "trash") }
            Button { viewModel.toggleComplete(task) } label: { Label(task.isCompleted ? "Redo" : "Done", systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark") }.tint(.green)
        }
    }

    private func priorityBadge(_ priority: TaskPriority) -> some View {
        let color: Color = switch priority {
        case .high: .red
        case .medium: .orange
        case .low: Color.nSecondary
        }
        return Text(priority.displayName)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.12))
            .cornerRadius(4)
    }
}
