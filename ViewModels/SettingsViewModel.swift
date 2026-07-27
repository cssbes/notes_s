import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let noteService: NoteService
    private let backupService: BackupService

    var isDarkMode = false
    var fontSize: Double = 16.0
    var lastBackupDate: Date?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    var showRestorePicker = false

    var formattedLastBackup: String {
        guard let date = lastBackupDate else { return "Never" }
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .short; return f.string(from: date)
    }

    init(noteService: NoteService, backupService: BackupService) {
        self.noteService = noteService
        self.backupService = backupService
        loadSettings()
    }

    func loadSettings() {
        isLoading = true

        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try noteService.context.fetch(descriptor)

            if let settings = settings.first {
                isDarkMode = settings.isDarkMode
                fontSize = settings.fontSize
            } else {
                let defaults = AppSettings()
                noteService.context.insert(defaults)
                try noteService.context.save()
            }

            lastBackupDate = backupService.getBackupCreationDate()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func saveThemePreference() {
        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try noteService.context.fetch(descriptor)
            let appSettings = settings.first ?? AppSettings()
            appSettings.isDarkMode = isDarkMode
            try noteService.context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveFontSize() {
        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try noteService.context.fetch(descriptor)
            let appSettings = settings.first ?? AppSettings()
            appSettings.fontSize = fontSize
            try noteService.context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createBackup() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            try backupService.createBackup()
            lastBackupDate = Date()
            successMessage = "Backup created successfully."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restoreBackup(from url: URL) {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            try backupService.restoreBackup(from: url)
            successMessage = "Backup restored successfully."
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
