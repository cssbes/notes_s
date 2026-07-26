import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SearchViewModel {
    private let searchService: SearchService

    var query = ""
    var results: [Note] = []
    var filter: NoteListFilter = .all
    var isSearching = false
    var errorMessage: String?

    var hasResults: Bool { !results.isEmpty }
    var isEmptyQuery: Bool { query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    init(searchService: SearchService) {
        self.searchService = searchService
    }

    func search() {
        guard !isEmptyQuery else {
            results = []
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            results = try searchService.search(query: query, filter: filter)
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }

        isSearching = false
    }

    func clearSearch() {
        query = ""
        results = []
    }

    func setFilter(_ filter: NoteListFilter) {
        self.filter = filter
        if !isEmptyQuery {
            search()
        }
    }
}
