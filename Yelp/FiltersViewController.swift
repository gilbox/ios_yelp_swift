//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Gil Birman on 8/8/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class {
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:Any])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

  let DEAL = 0
  let DISTANCE = 1
  let SORT_BY = 2
  let CATEGORIES = 3

  let sectionTitle = [
    1: "Distance",
    2: "Sort By",
    3: "Category",
  ]
  let optionValues: [Int: [[String:Any]]] = [
    1: [
      [ "title": "0.3 Miles", "value": 0.3 ],
      [ "title": "0.5 Miles", "value": 0.5 ],
      [ "title": "1 Mile", "value": 1],
      [ "title": "2 Miles", "value": 2],
      [ "title": "5 Miles", "value": 5],
    ],
    2: [
      [ "title": "Best Match", "value": YelpSortMode.BestMatched],
      [ "title": "Distance", "value": YelpSortMode.Distance ],
      [ "title": "Highest Rated", "value": YelpSortMode.HighestRated ],
    ],
  ]
  var selectedOptionIndex: [Int:Int] = [ 1: 2, 2: 0 ]
  var tableSectionCollapsed: [Int:Bool] = [ 1: true, 2: true ]
  var categories: [[String:String]]!
  var switchStates = [Int:Bool]()
  var dealState: Bool = false
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
    let indexPath = tableView.indexPathForCell(switchCell)!

    if (indexPath.section == DEAL) {
      dealState = value
    }

    if (indexPath.section == CATEGORIES) {
      switchStates[indexPath.row] = value
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == DEAL {
      return 0
    }
    return 30
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if (section == DEAL) { return nil }

    let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! HeaderView
    view.titleLabel.text = sectionTitle[section]
    return view
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    if (section == DISTANCE || section == SORT_BY) {
      let wasCollapsed = (tableSectionCollapsed[section] ?? false)
      if (!wasCollapsed) {
        selectedOptionIndex[section] = indexPath.row
      }
      tableSectionCollapsed[section] = !wasCollapsed
      tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case DEAL:
      return 1
    case DISTANCE, SORT_BY:
      return (tableSectionCollapsed[section] ?? false) ? 1 : optionValues[section]!.count
    case CATEGORIES:
      return categories.count
    default:
      // should never happen
      return 0
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let section = indexPath.section

    switch section {
    case DEAL:
      let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
      cell.delegate = self
      cell.switchLabel.text = "Offering a Deal"
      cell.onSwitch.on = dealState
      return cell
    case DISTANCE, SORT_BY:
      let sectionIsCollapsed = tableSectionCollapsed[section] ?? false
      let indexOfSelectedOption = selectedOptionIndex[section]!
      if (sectionIsCollapsed) {
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionCollapsedCell") as! OptionCollapsedCell
        let option = optionValues[section]![indexOfSelectedOption]
        cell.option = option
        return cell
      }
      let option = optionValues[section]![indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("OptionCell") as! OptionCell
      cell.option = option
      cell.on = indexOfSelectedOption == indexPath.row
      return cell
    case CATEGORIES:
      let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
      cell.delegate = self
      cell.switchLabel.text = categories[indexPath.row]["name"]
      cell.onSwitch.on = switchStates[indexPath.row] ?? false
      return cell
    default:
      // should never happen
      return UITableViewCell()
    }
  }

  @IBAction func onSearchButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)

    var filters = [String: Any]()
    var selectedCategories = [String]()

    for (row, isSelected) in switchStates {
      if isSelected {
        selectedCategories.append(categories[row]["code"]!)
      }
    }

    if (selectedCategories.count > 0) {
      filters["categories"] = selectedCategories
    }

    filters["deals"] = dealState

    if let distanceIndex = selectedOptionIndex[DISTANCE] {
      let distance = optionValues[DISTANCE]![distanceIndex]["value"]
      filters["distance"] = distance
    }

    if let sortByIndex = selectedOptionIndex[SORT_BY] {
      let sortBy = optionValues[SORT_BY]![sortByIndex]["value"]
      filters["sort"] = sortBy
    }

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
