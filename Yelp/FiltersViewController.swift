//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Gil Birman on 8/8/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class {
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filters)
}

enum FilterSection: Int {
  case Deal = 0
  case Distance = 1
  case SortBy = 2
  case Categories = 3
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

  let MAX_CONTRACTED_CATEGORIES = 3

  let sectionTitle: [FilterSection: String] = [
    .Distance: "Distance",
    .SortBy: "Sort By",
    .Categories: "Category",
  ]
  let optionValues: [FilterSection: [[String:Any]]] = [
    .Distance: [
      [ "title": "0.3 Miles", "value": 0.3 ],
      [ "title": "0.5 Miles", "value": 0.5 ],
      [ "title": "1 Mile", "value": 1],
      [ "title": "2 Miles", "value": 2],
      [ "title": "5 Miles", "value": 5],
    ],
    .SortBy: [
      [ "title": "Best Match", "value": YelpSortMode.BestMatched],
      [ "title": "Distance", "value": YelpSortMode.Distance ],
      [ "title": "Highest Rated", "value": YelpSortMode.HighestRated ],
    ],
  ]
  var selectedOptionIndex: [FilterSection:Int] = [
    .Distance: 2,
    .SortBy: 0,
  ]
  var tableSectionCollapsed: [FilterSection:Bool] = [
    .Distance: true,
    .SortBy: true,
  ]
  var categories: [[String:String]]!
  var switchStates = [Int:Bool]()
  var dealState: Bool = false
  var categoriesAreExpanded: Bool = false
  weak var delegate: FiltersViewControllerDelegate?

  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    categories = yelpCategories()

    tableView.dataSource = self
    tableView.delegate = self

    let nib = UINib(nibName: "HeaderView", bundle: nil)
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "HeaderView")


    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
    guard let indexPath = tableView.indexPathForCell(switchCell) else { return }
    guard let filterSection = FilterSection(rawValue: indexPath.section) else { return }

    if (filterSection == .Deal) {
      dealState = value
    }

    if (filterSection == .Categories) {
      switchStates[indexPath.row] = value
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard let filterSection = FilterSection(rawValue: section) where filterSection != .Deal else {
      return 0
    }

    return 30
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let filterSection = FilterSection(rawValue: section) where filterSection != .Deal else {
      return nil
    }

    let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! HeaderView
    view.titleLabel.text = sectionTitle[filterSection]
    return view
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let filterSection = FilterSection(rawValue: indexPath.section) else {
      // should never happen
      return
    }

    if (filterSection == .Distance || filterSection == .SortBy) {
      let wasCollapsed = (tableSectionCollapsed[filterSection] ?? false)
      if (!wasCollapsed) {
        selectedOptionIndex[filterSection] = indexPath.row
      }
      tableSectionCollapsed[filterSection] = !wasCollapsed
      tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    if (filterSection == .Categories && !categoriesAreExpanded && indexPath.row == MAX_CONTRACTED_CATEGORIES) {
      categoriesAreExpanded = true
      tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let filterSection = FilterSection(rawValue: section) else {
      // should never happen
      return 0
    }

    switch filterSection {
    case .Deal:
      return 1
    case .Distance, .SortBy:
      return (tableSectionCollapsed[filterSection] ?? false) ? 1 : optionValues[filterSection]!.count
    case .Categories:
      // TODO: assert somewhere that MAX_CONTRACTED_CATEGORIES > categories.count ?
      return categoriesAreExpanded ? categories.count : MAX_CONTRACTED_CATEGORIES + 1
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let filterSection = FilterSection(rawValue: indexPath.section) else {
      // should never happen
      return UITableViewCell()
    }

    switch filterSection {
    case .Deal:
      let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
      cell.delegate = self
      cell.switchLabel.text = "Offering a Deal"
      cell.onSwitch.on = dealState
      cell.selectionStyle = .None
      return cell
    case .Distance, .SortBy:
      let sectionIsCollapsed = tableSectionCollapsed[filterSection] ?? false
      let indexOfSelectedOption = selectedOptionIndex[filterSection]!
      if (sectionIsCollapsed) {
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionCollapsedCell") as! OptionCollapsedCell
        let option = optionValues[filterSection]![indexOfSelectedOption]
        cell.option = option
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.025)
        cell.selectedBackgroundView = backgroundView
        return cell
      }
      let option = optionValues[filterSection]![indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("OptionCell") as! OptionCell
      cell.option = option
      cell.on = indexOfSelectedOption == indexPath.row
      let backgroundView = UIView()
      backgroundView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.9)
      cell.selectedBackgroundView = backgroundView
      return cell
    case .Categories:
      if !categoriesAreExpanded && indexPath.row == MAX_CONTRACTED_CATEGORIES {
        return tableView.dequeueReusableCellWithIdentifier("SeeAllCell")!
      }
      let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
      cell.delegate = self
      cell.switchLabel.text = categories[indexPath.row]["name"]
      cell.onSwitch.on = switchStates[indexPath.row] ?? false
      cell.selectionStyle = .None
      return cell
    }
  }

  @IBAction func onSearchButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)

    var sort: YelpSortMode?
    var distance: Float?
    var selectedCategories = [String]()

    for (row, isSelected) in switchStates {
      if isSelected {
        selectedCategories.append(categories[row]["code"]!)
      }
    }

    if let distanceIndex = selectedOptionIndex[.Distance] {
      distance = optionValues[.Distance]![distanceIndex]["value"] as? Float
    }

    if let sortByIndex = selectedOptionIndex[.SortBy] {
      sort = optionValues[.SortBy]![sortByIndex]["value"] as? YelpSortMode
    }

    let filters = Filters(sort: sort, categories: selectedCategories, deals: dealState, distance: distance)
    delegate?.filtersViewController(self, didUpdateFilters: filters)
  }

  @IBAction func onCancelButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

  func yelpCategories() -> [[String:String]] {
    return [["name" : "Afghan", "code": "afghani"],
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

}
