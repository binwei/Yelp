//
//  SwitchCell.swift
//  Yelp
//
//  Created by Binwei Yang on 7/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categorySwitch: UISwitch!
    
    var delegate : SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        categorySwitch.addTarget(self, action: #selector(onSwitchValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    
    func onSwitchValueChanged(uiSwitch: UISwitch) {
        delegate?.switchCell?(self, didChangeValue: uiSwitch.on)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
