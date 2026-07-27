import Foundation

final class SmartTagService {
    static let keywords: [(pattern: String, tag: String)] = [
        ("work|job|office|meeting|deadline|project|client|presentation|report|email", "Work"),
        ("personal|family|home|todo|grocery|kids|mom|dad|wife|husband", "Personal"),
        ("idea|brainstorm|thought|maybe|could|imagine|what if", "Ideas"),
        ("read|book|chapter|author|page|library|novel|reading|literature", "Reading"),
        ("study|courses|lecture|class|homework|exam|assignment|lesson|subject|university", "Study"),
        ("health|fitness|gym|workout|exercise|diet|medicine|doctor|sleep|food", "Health"),
        ("travel|trip|vacation|flight|hotel|visit|destination|tourist", "Travel"),
        ("tech|code|swift|swiftui|programming|app|software|bug|debug|feature", "Tech"),
        ("finance|money|budget|salary|bills|invest|saving|bank|payment", "Finance"),
        ("recipe|cooking|food|meal|ingredient|kitchen|dinner|lunch|breakfast|bake", "Cooking"),
        ("journal|diary|day|today|feeling|grateful|thought|reflection|mood|emotion", "Journal"),
        ("shopping|buy|store|cart|wishlist|order|delivery|amazon|purchase", "Shopping"),
        ("event|party|wedding|birthday|anniversary|celebration|gathering", "Events"),
        ("goal|habit|tracker|daily|weekly|progress|achieve|milestone", "Goals"),
        ("note|important|remember|reminder|urgent|asap|critical", "Important"),
    ]

    static func suggestTags(for content: String, title: String) -> [String] {
        let text = "\(title) \(content)".lowercased()
        return keywords.compactMap { pattern, tag in
            text.range(of: pattern, options: .regularExpression) != nil ? tag : nil
        }
    }
}
