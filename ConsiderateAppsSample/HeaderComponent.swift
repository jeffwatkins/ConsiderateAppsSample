//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

public protocol HeaderComponent: Component {

    var title: UILabel {get}
    var subtitle: UILabel {get}
    var button: UIButton {get}

    init(preferredOrientation: Orientation, frame: CGRect)

}
