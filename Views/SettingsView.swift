import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showFilePicker = false
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var errorText = ""
    @State private var successText = ""
    @State private var lockEnabled = LockService.shared.isEnabled
    @State private var showInsights = false
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: SettingsViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Theme", selection: $viewModel.theme) {
                        ForEach(AppTheme.allCases) { Text($0.displayName).tag($0) }
                    }
                    .onChange(of: viewModel.theme) { _, _ in viewModel.saveTheme() }

                    Picker("Accent", selection: $viewModel.accentColorHex) {
                        ForEach(accentColors, id: \.hex) { color in
                            HStack {
                                Circle().fill(Color(hex: color.hex) ?? .blue).frame(width: 16, height: 16)
                                Text(color.name)
                            }.tag(color.hex)
                        }
                    }
                    .onChange(of: viewModel.accentColorHex) { _, _ in viewModel.saveAccentColor() }
                } header: { Text("Appearance").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    languagePicker
                    .onChange(of: viewModel.language) { _, _ in viewModel.saveLanguage(); updateLocale() }
                } header: { Text("Language").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    VStack(spacing: 8) {
                        HStack { Text("Font Size"); Spacer(); Text("\(Int(viewModel.fontSize))pt").foregroundStyle(Color.nSecondary).monospacedDigit() }
                        Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                            .onChange(of: viewModel.fontSize) { _, _ in viewModel.saveFontSize() }
                            .tint(Color.nAccent)
                        HStack { Text("A").font(.system(size: 12)).foregroundStyle(Color.nSecondary); Spacer(); Text("A").font(.system(size: 20)).foregroundStyle(Color.nSecondary) }
                    }

                    Picker("Font", selection: $viewModel.fontFamily) {
                        ForEach(AppFontFamily.allCases) { Text($0.displayName).tag($0) }
                    }
                    .onChange(of: viewModel.fontFamily) { _, _ in viewModel.saveFontFamily() }
                } header: { Text("Editor").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    Toggle(isOn: $lockEnabled) {
                        HStack {
                            Image(systemName: LockService.shared.biometryType == .faceID ? "faceid" : "touchid")
                                .foregroundStyle(Color.nAccent)
                            Text("Biometric Lock")
                        }
                    }
                    .onChange(of: lockEnabled) { _, newValue in
                        if newValue {
                            Task { await LockService.shared.authenticate(reason: "Enable lock"); lockEnabled = LockService.shared.isEnabled }
                        } else {
                            LockService.shared.setEnabled(false)
                        }
                    }
                    .disabled(!LockService.shared.isLockAvailable)
                } header: { Text("Security").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    Button { showInsights = true } label: {
                        Label("Insights", systemImage: "chart.bar.fill").foregroundStyle(Color.nAccent)
                    }
                } header: { Text("Statistics").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    Button { viewModel.createBackup() } label: { Label("Create Backup", systemImage: "externaldrive.fill") }
                    Button { showFilePicker = true } label: { Label("Restore", systemImage: "externaldrive.badge.arrow.down") }
                    HStack { Text("Last Backup"); Spacer(); Text(viewModel.formattedLastBackup).foregroundStyle(Color.nSecondary) }
                } header: { Text("Backup").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }

                Section {
                    HStack { Text("Version"); Spacer(); Text(Constants.appVersion).foregroundStyle(Color.nSecondary) }
                    HStack { Text("Build"); Spacer(); Text("2").foregroundStyle(Color.nSecondary) }
                    HStack { Text("iOS"); Spacer(); Text("18+").foregroundStyle(Color.nSecondary) }
                } header: { Text("About").textCase(.uppercase).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary) }
            }
            .listStyle(.insetGrouped)
            .background(Color.nBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $showErrorAlert) { Button("OK") {} } message: { Text(errorText) }
            .alert("Success", isPresented: $showSuccessAlert) { Button("OK") {} } message: { Text(successText) }
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls): if let url = urls.first { viewModel.restoreBackup(from: url) }
                case .failure(let error): errorText = error.localizedDescription; showErrorAlert = true
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in if let msg = newValue { errorText = msg; showErrorAlert = true; viewModel.errorMessage = nil } }
            .onChange(of: viewModel.successMessage) { _, newValue in if let msg = newValue { successText = msg; showSuccessAlert = true; viewModel.successMessage = nil } }
            .sheet(isPresented: $showInsights) {
                InsightsView(insights: InsightsService(noteService: coordinator.container.noteService))
            }
        }
    }

    @ViewBuilder private var languagePicker: some View {
        let cases = AppLanguage.allCases
        Picker("Language", selection: $viewModel.language) {
            ForEach(cases) { lang in
                Text(lang.displayName).tag(lang)
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
        ("Teal", "#5AC8FA"), ("Indigo", "#5856D6"), ("Yellow", "#FFCC00")
    ]
}
