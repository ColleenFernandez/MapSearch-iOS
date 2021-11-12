//
//  TestViewController.swift
//  LSDialogViewController
//
//  Created by Daisuke Hasegawa on 2016/05/17.
//  Copyright © 2016年 Libra Studio, Inc. All rights reserved.
//

import UIKit

class SearchDialogUV: BaseVC {
    @IBOutlet var lbl_location_type: UILabel!
    @IBOutlet var lbl_favorite: UILabel!
    @IBOutlet var cus_location_type: MSDropDown!
    @IBOutlet var cus_favorite: MSDropDown!
    var location_value: Int?
    var favorite_value: Int?
    var delegate: MapVC?

    let favorite_options: [KeyValueModel] = [KeyValueModel(key: "0", value: "ディフォルト"),
                                               KeyValueModel(key: "1", value: "お気に入り"),
                                               KeyValueModel(key: "2", value: "嫌い")]
    var location_options: [KeyValueModel]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // adjust height and width of dialog
        // view.bounds.size.height = UIScreen.main.bounds.size.height * 0.7
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.95
        setUpDropDownFilter()
    }

    func setUpDropDownFilter() {
        cus_favorite.keyvalueCount = favorite_options.count
        cus_favorite.delegate = self
        cus_favorite.keyValues = favorite_options
        cus_favorite.isMultiSelect = false
        if let location_options = location_options {
            self.cus_location_type.keyvalueCount = location_options.count
            self.cus_location_type.delegate = self
            self.cus_location_type.keyValues = location_options
            self.cus_location_type.isMultiSelect = false
        }
    }

    
    @IBAction func locationBtnClicked(_ sender: Any) {
        cus_location_type.btnClicked(sender as! UIButton)
    }
    
    @IBAction func favoriteBtnClicked(_ sender: Any) {
        cus_favorite.btnClicked(sender as! UIButton)
    }


    // close dialogView
    @IBAction func searchBtnClicked(_ sender: AnyObject) {
        delegate?.filterMapMarkers(location_type: self.location_value, favorite_type: self.favorite_value)

        self.delegate?.dismissDialog()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeBtnClicked(_ sender: Any) {
        delegate?.dismissDialog()
    }
}

extension SearchDialogUV: MSDropDownDelegate {
    func dropdownSelected(tagId: Int, answer: String, value: String, isSelected: Bool) {
        if tagId == 1{ // location filter
            lbl_location_type.text = answer
            location_value = value.toInt()
        }else{
            lbl_favorite.text = answer
            favorite_value = value.toInt()
        }
    }
}

