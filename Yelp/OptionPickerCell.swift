//
//  OptionPickerCell.swift
//  Yelp
//
//  Created by Binwei Yang on 7/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

enum OptionSelectionMode {
    case CurrentSelection, LastSelection, NotSelected
}

class OptionPickerCell: UITableViewCell {
    
    @IBOutlet weak var optionValueLabel: UILabel!
    
    @IBOutlet weak var optionSelectionImage: UIImageView!
    
    var selectionMode: OptionSelectionMode? {
        didSet {
            switch selectionMode! {
            case .CurrentSelection:
                optionSelectionImage.image = UIImage(named: "down-arrow")
                break
            case .LastSelection:
                optionSelectionImage.image = UIImage(named: "check-mark")
                break
            case .NotSelected:
                optionSelectionImage.image = UIImage(named: "circle")
                break
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
