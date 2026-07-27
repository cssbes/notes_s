import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showFilePicker = false
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var errorText = ""
    @State private var successText = ""

    init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                languageSection
                editorSection
                backupSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorText)
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {}
            } message: {
                Text(successText)
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.restoreBackup(from: url)
                    }
                case .failure(let error):
                    errorText = error.localizedDescription
                    showErrorAlert = true
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                if let msg = newValue {
                    errorText = msg
                    showErrorAlert = true
                    viewModel.errorMessage = nil
                }
            }
            .onChange(of: viewModel.successMessage) { _, newValue in
                if let msg = newValue {
                    successText = msg
                    showSuccessAlert = true
                    viewModel.successMessage = nil
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $viewModel.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.displayName, systemImage: theme.systemImage).tag(theme)
                }
            }
            .onChange(of: viewModel.theme) { _, _ in
                viewModel.saveTheme()
            }

            Picker("Accent Color", selection: $viewModel.accentColorHex) {
                ForEach(accentColors, id: \.hex) { color in
                    HStack {
                        Circle()
                            .fill(Color(hex: color.hex) ?? .blue)
                            .frame(width: 20, height: 20)
                        Text(color.name)
                    }.tag(color.hex)
                }
            }
            .onChange(of: viewModel.accentColorHex) { _, _ in
                viewModel.saveAccentColor()
            }
        }
    }

    private var languageSection: some View {
        Section("Language") {
            Picker("Language", selection: $viewModel.language) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .onChange(of: viewModel.language) { _, _ in
                viewModel.saveLanguage()
                updateLocale()
            }
        }
    }

    private var editorSection: some View {
        Section("Editor") {
            VStack(alignment: .leading, spacing: 8) {
                Label("Font Size", systemImage: "textformat.size")

                HStack {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundStyle(.secondary)
                    Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                        .onChange(of: viewModel.fontSize) { _, _ in
                            viewModel.saveFontSize()
                        }
                    Image(systemName: "textformat.size.larger")
                        .foregroundStyle(.secondary)
                }

                Text("\(Int(viewModel.fontSize)) pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Picker("Font Family", selection: $viewModel.fontFamily) {
                ForEach(AppFontFamily.allCases) { family in
                    Text(family.displayName).tag(family)
                }
            }
            .onChange(of: viewModel.fontFamily) { _, _ in
                viewModel.saveFontFamily()
            }
        }
    }

    private var backupSection: some View {
        Section("Backup") {
            Button {
                viewModel.createBackup()
            } label: {
                Label("Create Backup", systemImage: "externaldrive.fill")
            }

            Button {
                showFilePicker = true
            } label: {
                Label("Restore from Backup", systemImage: "externaldrive.badge.arrow.down")
            }

            HStack {
                Text("Last Backup")
                Spacer()
                Text(viewModel.formattedLastBackup)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text("1")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Compatibility")
                Spacer()
                Text("iOS 18+")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func updateLocale() {
        guard let identifier = viewModel.language.localeIdentifier else { return }
        UserDefaults.standard.set([identifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    private let accentColors: [(name: String, hex: String)] = [
        ("Blue", "#007AFF"), ("Green", "#34C759"), ("Orange", "#FF9500"),
        ("Red", "#FF3B30"), ("Purple", "#AF52DE"), ("Pink", "#FF2D55"),
        ("Yellow", "#FFCC00"), ("Teal", "#5AC8FA"), ("Indigo", "#5856D6")
    ]
}
