//
//  SelectorTableViewController
//  MS_FormControls
//
//  Created by Manoj Shrestha on 4/9/19.
//
import UIKit

protocol SelectorDelegate {
    func selectionCompleted(keyValuesAfterSelection: [KeyValueModel])
}

public class SelectorTableViewController : UITableViewController {
    
    var isMultiselect = false
    var showDoneButton = false
    var delegate: SelectorDelegate?
    var keyValues = [KeyValueModel]()
    private var sortedKey = [Int]()
    private var isiPhone = false
    
    
    //MARK:- Life
    public init(keyValue :[KeyValueModel], isMultiselect: Bool) {
        self.isMultiselect = isMultiselect
        self.keyValues = keyValue
        super.init(style: .plain)
        self.tableView.rowHeight = UITableView.automaticDimension
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            isiPhone = true
            break
        default:
            isiPhone = false
        }
        
        //self.tableView.height = self.tableView.rowHeight * self.keyValues.count
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        delegate?.selectionCompleted(keyValuesAfterSelection: self.keyValues)
    }


    //MARK:- TableView DelegateMethods
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if(isMultiselect && showDoneButton)
        {
            let btnDone = UIButton()
            btnDone.setTitle("Done", for: .normal)
            btnDone.backgroundColor = UIColor.init(named: "color_Primary")
            btnDone.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            btnDone.translatesAutoresizingMaskIntoConstraints = false
            btnDone.layer.cornerRadius = 5.0
            
            vw.addConstraint(NSLayoutConstraint(item: btnDone, attribute: .trailing, relatedBy: .equal, toItem: vw, attribute: .trailing, multiplier: 1, constant: -10))
            vw.addConstraint(NSLayoutConstraint(item: btnDone, attribute: .centerY, relatedBy: .equal, toItem: vw, attribute: .centerY, multiplier: 1, constant: 0))
            vw.addConstraint(NSLayoutConstraint(item: btnDone, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 30))
            vw.addConstraint(NSLayoutConstraint(item: btnDone, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 100))
            vw.addSubview(btnDone)
            return vw
        }
        return nil
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keyValues.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let keyValuePair = self.keyValues[indexPath.row]
        cell.textLabel?.text = keyValuePair.value
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if(keyValuePair.isSelected)
        {
            
            let image = UIImage.init(named: "tick")
            let accessory  = UIImageView(frame:CGRect(x:0, y:0, width:25, height:25))
            accessory.image = image

            // set the color here
            accessory.tintColor = UIColor.init(named: "color_Primary")
            cell.accessoryView = accessory
            
            
//            cell.accessoryType = .disclosureIndicator
//            //let image = UIImageView(image: UIImage.init(named: "tick"))
//            //cell.accessoryView = image
//            cell.backgroundView?.backgroundColor = UIColor.gray
//            cell.tintColor = UIColor.init(named: "color_Primary")
        }
        else
        {
            cell.accessoryType = .none
            cell.backgroundView?.backgroundColor = UIColor.white
        }
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryView != .none{
                cell.accessoryView = .none
                self.keyValues[indexPath.row].isSelected = false
            }
            else{
                //cell.accessoryType = .checkmark
                 let image = UIImage.init(named: "tick")
                 let accessory  = UIImageView(frame:CGRect(x:0, y:0, width:25, height:25))
                accessory.image = image

                // set the color here
                accessory.tintColor = UIColor.init(named: "color_Primary")
                cell.accessoryView = accessory
                
                if(!self.isMultiselect)
                {
                    self.dismiss(animated: true)
                    unSelectAll()
                }
                self.keyValues[indexPath.row].isSelected = true
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(isMultiselect && showDoneButton)
        {
            return 50
        }
        return 0 
    }
    
    override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK:- Private Helper
    private func unSelectAll()
    {
        for opt in keyValues
        {
            opt.isSelected = false
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Dismiss")
        self.dismiss(animated: true)
    }
    
}
