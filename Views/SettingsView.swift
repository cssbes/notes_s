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
            ScrollView {
                VStack(spacing: 24) {
                    appearanceSection
                    languageSection
                    editorSection
                    backupSection
                    aboutSection
                }
                .padding(20)
            }
            .background(Color.themeBackground)
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
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.themeSubtle)
            .textCase(.uppercase)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Appearance")
            VStack(spacing: 0) {
                settingRow {
                    Picker("Theme", selection: $viewModel.theme) {
                        ForEach(AppTheme.allCases) { Text($0.displayName).tag($0) }
                    }
                    .onChange(of: viewModel.theme) { _, _ in viewModel.saveTheme() }
                }
                Divider().padding(.leading, 16)
                settingRow {
                    Picker("Accent", selection: $viewModel.accentColorHex) {
                        ForEach(accentColors, id: \.hex) { color in
                            HStack {
                                Circle().fill(Color(hex: color.hex) ?? .orange).frame(width: 16, height: 16)
                                Text(color.name)
                            }.tag(color.hex)
                        }
                    }
                    .onChange(of: viewModel.accentColorHex) { _, _ in viewModel.saveAccentColor() }
                }
            }
            .background(Color.themeCard)
            .cornerRadius(12)
        }
    }

    // MARK: - Language

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Language")
            VStack(spacing: 0) {
                settingRow {
                    Picker("Language", selection: $viewModel.language) {
                        ForEach(AppLanguage.allCases) { Text($0.displayName).tag($0) }
                    }
                    .onChange(of: viewModel.language) { _, _ in viewModel.saveLanguage(); updateLocale() }
                }
            }
            .background(Color.themeCard)
            .cornerRadius(12)
        }
    }

    // MARK: - Editor

    private var editorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Editor")
            VStack(spacing: 0) {
                settingRow {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(viewModel.fontSize))pt").font(.subheadline).foregroundStyle(Color.themeSubtle).monospacedDigit()
                    }
                }
                Divider().padding(.leading, 16)
                VStack(spacing: 4) {
                    Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                        .onChange(of: viewModel.fontSize) { _, _ in viewModel.saveFontSize() }
                        .tint(Color.themeAccent)
                    HStack {
                        Text("A").font(.system(size: 12)).foregroundStyle(Color.themeSubtle)
                        Spacer()
                        Text("A").font(.system(size: 20)).foregroundStyle(Color.themeSubtle)
                    }
                }
                .padding(16)
                Divider().padding(.leading, 16)
                settingRow {
                    Picker("Font", selection: $viewModel.fontFamily) {
                        ForEach(AppFontFamily.allCases) { Text($0.displayName).tag($0) }
                    }
                    .onChange(of: viewModel.fontFamily) { _, _ in viewModel.saveFontFamily() }
                }
            }
            .background(Color.themeCard)
            .cornerRadius(12)
        }
    }

    // MARK: - Backup

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Backup")
            VStack(spacing: 0) {
                settingRow {
                    Button { viewModel.createBackup() } label: { Label("Create Backup", systemImage: "externaldrive.fill").foregroundStyle(Color.themeText) }
                }
                Divider().padding(.leading, 16)
                settingRow {
                    Button { showFilePicker = true } label: { Label("Restore", systemImage: "externaldrive.badge.arrow.down").foregroundStyle(Color.themeText) }
                }
                Divider().padding(.leading, 16)
                settingRow {
                    HStack { Text("Last Backup"); Spacer(); Text(viewModel.formattedLastBackup).font(.subheadline).foregroundStyle(Color.themeSubtle) }
                }
            }
            .background(Color.themeCard)
            .cornerRadius(12)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("About")
            VStack(spacing: 0) {
                settingRow { HStack { Text("Version"); Spacer(); Text(Constants.appVersion).foregroundStyle(Color.themeSubtle) } }
                Divider().padding(.leading, 16)
                settingRow { HStack { Text("Build"); Spacer(); Text("2").foregroundStyle(Color.themeSubtle) } }
                Divider().padding(.leading, 16)
                settingRow { HStack { Text("iOS"); Spacer(); Text("18+").foregroundStyle(Color.themeSubtle) } }
            }
            .background(Color.themeCard)
            .cornerRadius(12)
        }
    }

    // MARK: - Helpers

    private func settingRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack { content().padding(16) }
    }

    private func updateLocale() {
        guard let identifier = viewModel.language.localeIdentifier else { return }
        UserDefaults.standard.set([identifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    private let accentColors: [(name: String, hex: String)] = [
        ("Amber", "#C77D4A"), ("Terracotta", "#8B6B5C"), ("Slate", "#5C6B7A"),
        ("Sage", "#6B8B6B"), ("Rust", "#B86C5A"), ("Ochre", "#C99A4A"),
        ("Mist", "#9EA8B8"), ("Cocoa", "#7A6B5C"), ("Dusk", "#8B7A9E")
    ]
}
