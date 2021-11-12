//
//  MSDropDown.swift
//  MS_FormControls
//
//  Created by Manoj Shrestha on 4/9/19.
//

import UIKit

public protocol MSDropDownDelegate: class {
    func dropdownSelected(tagId:Int, answer: String, value: String, isSelected: Bool)
}

@IBDesignable

public class MSDropDown: UIView, SelectorDelegate {
    
    private var isSelected = false
    public var keyvalueCount : Int = 0
    //Mark:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var icoDDL: UIImageView!
    
    //Mark:- Settings
    
    public var isMultiSelect = false
    public var showDoneButton = false
    public var multiSelectSeparator = " | "
    
    public var keyValues = [KeyValueModel]()
    public weak var delegate: MSDropDownDelegate?
    
    
    /*@IBInspectable
    internal override var borderWidth
    {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    internal override var cornerRadius
    {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }*/
    
    @IBInspectable
    public var placeholder : String = "Select"
    {
        didSet {
            lblTitle.text = placeholder
        }
    }
    
    @IBInspectable
    public var dropdownIcon : UIImage = UIImage(named: "icoDownArrow.png") ?? UIImage()
    {
        didSet {
            icoDDL.image = dropdownIcon
        }
    }
    
    @IBInspectable
    public var answer : String = ""
    {
        didSet {
            var title = placeholder
            if(answer.count > 0)
            {
                title = answer
            }
            
            let answerarray = answer.components(separatedBy: multiSelectSeparator)
            for ans in answerarray
            {
                for keyValue in self.keyValues
                {
                    if(keyValue.value == ans)
                    {
                        keyValue.isSelected = true
                    }
                }
            }
            self.lblTitle.text = title
        }
    }
    

    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        xibSetup()
    }
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    public func btnClicked(_ sender: UIButton) {
        let controller = SelectorTableViewController(keyValue: self.keyValues, isMultiselect: isMultiSelect)
        controller.delegate = self
        let popUpSize  = CGSize(width: Int(Constants.SCREEN_WIDTH) - 60, height: self.keyvalueCount * 44)
        
        controller.preferredContentSize = popUpSize
        controller.showDoneButton = self.showDoneButton
        showPopup(controller, sourceView: sender.superview!)
    }
    
    @IBAction func ddlPressed(_ sender: UIButton) {
        btnClicked(sender)
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        
        let topVC = getTopViewController()
        topVC?.present(controller, animated: true)
    }
    
    private func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    func selectionCompleted(keyValuesAfterSelection: [KeyValueModel]) {
        self.keyValues = keyValuesAfterSelection
        var ans = ""
        var ansValue = ""
        for keyValue in self.keyValues
        {
            if(!isMultiSelect)
            {
                if(keyValue.isSelected)
                {
                    ans = keyValue.value
                    ansValue = keyValue.key
                    break
                }
            }
            else
            {
                if(ans.count == 0 && keyValue.isSelected)
                {
                    ans = keyValue.value
                }
                else if(ans.count > 0 && keyValue.isSelected)
                {
                    ans = "\(ans)\(multiSelectSeparator)\(keyValue.value)"
                }
            }
        }
        self.answer = ans
        if(answer.count > 0)
        {
            isSelected = true
        }
        else
        {
            isSelected = false
        }
        delegate?.dropdownSelected(tagId: self.tag, answer: self.answer, value: ansValue, isSelected: isSelected)
    }
}

private extension MSDropDown {
    
    func xibSetup() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MSDropDown", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:nil, views: bindings))
        designView()
    }
    
    func designView() {
        clipsToBounds = true
        backgroundColor = .white
        layer.cornerRadius = self.cornerRadius
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = self.borderWidth
    }
}
