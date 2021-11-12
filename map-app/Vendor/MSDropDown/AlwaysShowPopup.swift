//
//  AlwaysPresentAsPopover
//  MS_FormControls
//
//  Created by Manoj Shrestha on 4/9/19.
//

import UIKit
public class AlwaysPresentAsPopover : NSObject, UIPopoverPresentationControllerDelegate {
    private static let sharedInstance = AlwaysPresentAsPopover()
    
    private override init() {
        super.init()
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    static public func configurePresentation(forController controller : UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        let presentationController = controller.presentationController as! UIPopoverPresentationController        
        presentationController.delegate = AlwaysPresentAsPopover.sharedInstance
        return presentationController
    }
    
}
