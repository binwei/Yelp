//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Binwei Yang on 7/23/16.
//  Copyright © 2016 Binwei Yang. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject] )
}

struct FilterSetting {
    var switchStates = [Int:Bool]()
    var dealsOnly: Bool?
    var showAllCategories = false
    let numInitialCategories = 9
}

struct PickerSetting {
    var isPickerActive = false
    var pickedRow = 0
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var filterSetting = FilterSetting()
    
    // idea from https://github.com/floriankrueger/iOS-Examples--UITableView-Combo-Box
    var sortPickerSetting = PickerSetting()
    var distancePickerSetting = PickerSetting()
    let sectionTitles: [String?] = [nil, "Distance", "Sort By", "Category"]
    
    var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var filters = [String:AnyObject]()
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in filterSetting.switchStates {
            if (isSelected) {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if (selectedCategories.count > 0) {
            filters["categories"] = selectedCategories
        }
        
        if (filterSetting.dealsOnly != nil) {
            filters["dealsOnly"] = filterSetting.dealsOnly
        }
        
        filters["sortBy"] = sortModes[sortPickerSetting.pickedRow].1.rawValue
        
        filters["distanceInMile"] = distanceModes[distancePickerSetting.pickedRow].1
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return distancePickerSetting.isPickerActive ? distanceModes.count : 1
        case 2:
            return sortPickerSetting.isPickerActive ? sortModes.count : 1
        case 3:
            return filterSetting.showAllCategories ? categories.count : filterSetting.numInitialCategories
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            cell.categoryLabel.text = "Offering a Deal"
            cell.categorySwitch.on = filterSetting.dealsOnly ?? false
            cell.delegate = self
            
            return cell
            
        case 1:
            return getOptionPickerCell(tableView, indexPath: indexPath, pickerSetting: distancePickerSetting, options: distanceModes)
            
        case 2:
            return getOptionPickerCell(tableView, indexPath: indexPath, pickerSetting: sortPickerSetting, options: sortModes)
            
        default:
            if (filterSetting.showAllCategories || indexPath.row < filterSetting.numInitialCategories - 1) {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                
                cell.categoryLabel.text = categories[indexPath.row]["name"]
                cell.categorySwitch.on = filterSetting.switchStates[indexPath.row] ?? false
                cell.delegate = self
                
                return cell
            } else {
                return tableView.dequeueReusableCellWithIdentifier("SeeAllCell", forIndexPath: indexPath)
            }
        }
    }
    
    func getOptionPickerCell<T>(tableView: UITableView, indexPath: NSIndexPath, pickerSetting: PickerSetting, options: [(String, T)]) -> OptionPickerCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionPickerCell", forIndexPath: indexPath) as! OptionPickerCell
        
        if (pickerSetting.isPickerActive) {
            cell.optionValueLabel.text = options[indexPath.row].0
            if (indexPath.row == pickerSetting.pickedRow) {
                cell.selectionMode = .LastSelection
            }
            else {
                cell.selectionMode = .NotSelected
            }
        }
        else {
            cell.optionValueLabel.text = options[pickerSetting.pickedRow].0
            cell.selectionMode = .CurrentSelection
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            togglePickerSetting(&distancePickerSetting, indexPath)
        case 2:
            togglePickerSetting(&sortPickerSetting, indexPath)
        case 3:
            if (!filterSetting.showAllCategories && indexPath.row == filterSetting.numInitialCategories - 1) {
                filterSetting.showAllCategories = true
                tableView.reloadData()
            }
        default:
            break
        }
    }
    
    func togglePickerSetting(inout pickerSetting: PickerSetting, _ indexPath: NSIndexPath) {
        if (pickerSetting.isPickerActive) {
            pickerSetting.pickedRow = indexPath.row
        }
        pickerSetting.isPickerActive = !pickerSetting.isPickerActive
        
        tableView.reloadData()
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switch indexPath.section {
        case 0:
            filterSetting.dealsOnly = value
        case 3:
            filterSetting.switchStates[indexPath.row] = value
        default:
            break
        }
    }
    
    private let sortModes = [("Best Match", YelpSortMode.BestMatched),
                             ("Distance", YelpSortMode.Distance),
                             ("Highest Rated", YelpSortMode.HighestRated)]
    
    private let distanceModes: [(String, Double?)] = [("Auto", nil), ("0.3 miles", 0.3), ("1 mile", 1),
                                                      ("5 miles", 5), ("20 miles", 20)]
    
    private let categories = [["name" : "Afghan", "code": "afghani"],
                              ["name" : "African", "code": "african"],
                              ["name" : "American, New", "code": "newamerican"],
                              ["name" : "American, Traditional", "code": "tradamerican"],
                              ["name" : "Arabian", "code": "arabian"],
                              ["name" : "Argentine", "code": "argentine"],
                              ["name" : "Armenian", "code": "armenian"],
                              ["name" : "Asian Fusion", "code": "asianfusion"],
                              ["name" : "Asturian", "code": "asturian"],
                              ["name" : "Australian", "code": "australian"],
                              ["name" : "Austrian", "code": "austrian"],
                              ["name" : "Baguettes", "code": "baguettes"],
                              ["name" : "Bangladeshi", "code": "bangladeshi"],
                              ["name" : "Barbeque", "code": "bbq"],
                              ["name" : "Basque", "code": "basque"],
                              ["name" : "Bavarian", "code": "bavarian"],
                              ["name" : "Beer Garden", "code": "beergarden"],
                              ["name" : "Beer Hall", "code": "beerhall"],
                              ["name" : "Beisl", "code": "beisl"],
                              ["name" : "Belgian", "code": "belgian"],
                              ["name" : "Bistros", "code": "bistros"],
                              ["name" : "Black Sea", "code": "blacksea"],
                              ["name" : "Brasseries", "code": "brasseries"],
                              ["name" : "Brazilian", "code": "brazilian"],
                              ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                              ["name" : "British", "code": "british"],
                              ["name" : "Buffets", "code": "buffets"],
                              ["name" : "Bulgarian", "code": "bulgarian"],
                              ["name" : "Burgers", "code": "burgers"],
                              ["name" : "Burmese", "code": "burmese"],
                              ["name" : "Cafes", "code": "cafes"],
                              ["name" : "Cafeteria", "code": "cafeteria"],
                              ["name" : "Cajun/Creole", "code": "cajun"],
                              ["name" : "Cambodian", "code": "cambodian"],
                              ["name" : "Canadian", "code": "New)"],
                              ["name" : "Canteen", "code": "canteen"],
                              ["name" : "Caribbean", "code": "caribbean"],
                              ["name" : "Catalan", "code": "catalan"],
                              ["name" : "Chech", "code": "chech"],
                              ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                              ["name" : "Chicken Shop", "code": "chickenshop"],
                              ["name" : "Chicken Wings", "code": "chicken_wings"],
                              ["name" : "Chilean", "code": "chilean"],
                              ["name" : "Chinese", "code": "chinese"],
                              ["name" : "Comfort Food", "code": "comfortfood"],
                              ["name" : "Corsican", "code": "corsican"],
                              ["name" : "Creperies", "code": "creperies"],
                              ["name" : "Cuban", "code": "cuban"],
                              ["name" : "Curry Sausage", "code": "currysausage"],
                              ["name" : "Cypriot", "code": "cypriot"],
                              ["name" : "Czech", "code": "czech"],
                              ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                              ["name" : "Danish", "code": "danish"],
                              ["name" : "Delis", "code": "delis"],
                              ["name" : "Diners", "code": "diners"],
                              ["name" : "Dumplings", "code": "dumplings"],
                              ["name" : "Eastern European", "code": "eastern_european"],
                              ["name" : "Ethiopian", "code": "ethiopian"],
                              ["name" : "Fast Food", "code": "hotdogs"],
                              ["name" : "Filipino", "code": "filipino"],
                              ["name" : "Fish & Chips", "code": "fishnchips"],
                              ["name" : "Fondue", "code": "fondue"],
                              ["name" : "Food Court", "code": "food_court"],
                              ["name" : "Food Stands", "code": "foodstands"],
                              ["name" : "French", "code": "french"],
                              ["name" : "French Southwest", "code": "sud_ouest"],
                              ["name" : "Galician", "code": "galician"],
                              ["name" : "Gastropubs", "code": "gastropubs"],
                              ["name" : "Georgian", "code": "georgian"],
                              ["name" : "German", "code": "german"],
                              ["name" : "Giblets", "code": "giblets"],
                              ["name" : "Gluten-Free", "code": "gluten_free"],
                              ["name" : "Greek", "code": "greek"],
                              ["name" : "Halal", "code": "halal"],
                              ["name" : "Hawaiian", "code": "hawaiian"],
                              ["name" : "Heuriger", "code": "heuriger"],
                              ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                              ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                              ["name" : "Hot Dogs", "code": "hotdog"],
                              ["name" : "Hot Pot", "code": "hotpot"],
                              ["name" : "Hungarian", "code": "hungarian"],
                              ["name" : "Iberian", "code": "iberian"],
                              ["name" : "Indian", "code": "indpak"],
                              ["name" : "Indonesian", "code": "indonesian"],
                              ["name" : "International", "code": "international"],
                              ["name" : "Irish", "code": "irish"],
                              ["name" : "Island Pub", "code": "island_pub"],
                              ["name" : "Israeli", "code": "israeli"],
                              ["name" : "Italian", "code": "italian"],
                              ["name" : "Japanese", "code": "japanese"],
                              ["name" : "Jewish", "code": "jewish"],
                              ["name" : "Kebab", "code": "kebab"],
                              ["name" : "Korean", "code": "korean"],
                              ["name" : "Kosher", "code": "kosher"],
                              ["name" : "Kurdish", "code": "kurdish"],
                              ["name" : "Laos", "code": "laos"],
                              ["name" : "Laotian", "code": "laotian"],
                              ["name" : "Latin American", "code": "latin"],
                              ["name" : "Live/Raw Food", "code": "raw_food"],
                              ["name" : "Lyonnais", "code": "lyonnais"],
                              ["name" : "Malaysian", "code": "malaysian"],
                              ["name" : "Meatballs", "code": "meatballs"],
                              ["name" : "Mediterranean", "code": "mediterranean"],
                              ["name" : "Mexican", "code": "mexican"],
                              ["name" : "Middle Eastern", "code": "mideastern"],
                              ["name" : "Milk Bars", "code": "milkbars"],
                              ["name" : "Modern Australian", "code": "modern_australian"],
                              ["name" : "Modern European", "code": "modern_european"],
                              ["name" : "Mongolian", "code": "mongolian"],
                              ["name" : "Moroccan", "code": "moroccan"],
                              ["name" : "New Zealand", "code": "newzealand"],
                              ["name" : "Night Food", "code": "nightfood"],
                              ["name" : "Norcinerie", "code": "norcinerie"],
                              ["name" : "Open Sandwiches", "code": "opensandwiches"],
                              ["name" : "Oriental", "code": "oriental"],
                              ["name" : "Pakistani", "code": "pakistani"],
                              ["name" : "Parent Cafes", "code": "eltern_cafes"],
                              ["name" : "Parma", "code": "parma"],
                              ["name" : "Persian/Iranian", "code": "persian"],
                              ["name" : "Peruvian", "code": "peruvian"],
                              ["name" : "Pita", "code": "pita"],
                              ["name" : "Pizza", "code": "pizza"],
                              ["name" : "Polish", "code": "polish"],
                              ["name" : "Portuguese", "code": "portuguese"],
                              ["name" : "Potatoes", "code": "potatoes"],
                              ["name" : "Poutineries", "code": "poutineries"],
                              ["name" : "Pub Food", "code": "pubfood"],
                              ["name" : "Rice", "code": "riceshop"],
                              ["name" : "Romanian", "code": "romanian"],
                              ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                              ["name" : "Rumanian", "code": "rumanian"],
                              ["name" : "Russian", "code": "russian"],
                              ["name" : "Salad", "code": "salad"],
                              ["name" : "Sandwiches", "code": "sandwiches"],
                              ["name" : "Scandinavian", "code": "scandinavian"],
                              ["name" : "Scottish", "code": "scottish"],
                              ["name" : "Seafood", "code": "seafood"],
                              ["name" : "Serbo Croatian", "code": "serbocroatian"],
                              ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                              ["name" : "Singaporean", "code": "singaporean"],
                              ["name" : "Slovakian", "code": "slovakian"],
                              ["name" : "Soul Food", "code": "soulfood"],
                              ["name" : "Soup", "code": "soup"],
                              ["name" : "Southern", "code": "southern"],
                              ["name" : "Spanish", "code": "spanish"],
                              ["name" : "Steakhouses", "code": "steak"],
                              ["name" : "Sushi Bars", "code": "sushi"],
                              ["name" : "Swabian", "code": "swabian"],
                              ["name" : "Swedish", "code": "swedish"],
                              ["name" : "Swiss Food", "code": "swissfood"],
                              ["name" : "Tabernas", "code": "tabernas"],
                              ["name" : "Taiwanese", "code": "taiwanese"],
                              ["name" : "Tapas Bars", "code": "tapas"],
                              ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                              ["name" : "Tex-Mex", "code": "tex-mex"],
                              ["name" : "Thai", "code": "thai"],
                              ["name" : "Traditional Norwegian", "code": "norwegian"],
                              ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                              ["name" : "Trattorie", "code": "trattorie"],
                              ["name" : "Turkish", "code": "turkish"],
                              ["name" : "Ukrainian", "code": "ukrainian"],
                              ["name" : "Uzbek", "code": "uzbek"],
                              ["name" : "Vegan", "code": "vegan"],
                              ["name" : "Vegetarian", "code": "vegetarian"],
                              ["name" : "Venison", "code": "venison"],
                              ["name" : "Vietnamese", "code": "vietnamese"],
                              ["name" : "Wok", "code": "wok"],
                              ["name" : "Wraps", "code": "wraps"],
                              ["name" : "Yugoslav", "code": "yugoslav"]]
}
