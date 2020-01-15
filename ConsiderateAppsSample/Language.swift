//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import Foundation

struct Language {
    /// ISO-639-1 language code
    let code: String
    /// The name of the language keyed by ISO-636-1 language code
    let name: [String:String]

    static let english = Language(code: "en", name:[
        "en": "English",
        "ms": "Bahasa Inggeris",
        "zh": "英语"
    ])

    static let malay = Language(code: "ms", name: [
        "en": "Malay",
        "ms": "Melayu",
        "zh": "马来语"
    ])

    static let chinese = Language(code: "zh", name: [
        "en": "Chinese",
        "ms": "Cina",
        "zh": "中文",
    ])
}
