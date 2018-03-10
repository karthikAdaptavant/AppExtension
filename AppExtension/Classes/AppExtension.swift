//
//  AppExtension.swift
//  AppExtension
//
//  Created by Karthik on 3/10/18.
//

import UIKit
import Foundation

// MARK: > String
public extension String {
    
    public var decodeEmoji: String {
        if let data = self.data(using: String.Encoding.utf8), let decodedStr = NSString(data: data, encoding: String.Encoding.nonLossyASCII.rawValue) {
            return decodedStr as String
        }
        return self
    }
    
    public var encodeEmoji: String {
        
        if let chars = self.cString(using: .nonLossyASCII), let encodeStr = NSString(cString: chars, encoding: String.Encoding.utf8.rawValue) {
            return encodeStr as String
        }
        return self
    }
    
    public var count: Int {
        return self.count
    }
    
    public var trim: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    public var trimNewLine: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func isBlank() -> Bool {
        return trim.isEmpty
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    public func beginsWith(str: String) -> Bool {
        if let range = self.range(of: str) {
            return range.lowerBound == self.startIndex
        }
        return false
    }
    
    public var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    public var isValidEmail: Bool {
        
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest: NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    public func rangeFromNSRange(from nsRange: NSRange) -> Range<String.Index>? {
        
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) else {
                return nil
        }
        
        return from ..< to
    }
    
    // To check url is of type image 
    public func isImage() -> Bool {
        // Add here your image formats.
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        
        if let ext = self.getExtension() {
            return imageFormats.contains(ext)
        }
        
        return false
    }
    
    public func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        
        if ext.isEmpty {
            return nil
        }
        
        return ext
    }
    
    public func isURL() -> Bool {
        return URL(string: self) != nil
    }
}


// MARK: > Optional
public extension Optional {
    @discardableResult
    public func hasData(_ handler: (Wrapped) -> Void) -> Optional {
        switch self {
        case .some(let wrapped):
            handler(wrapped)
            return self
        case .none:
            return self
        }
    }
    @discardableResult
    public func ifNone(_ handler: () -> Void) -> Optional {
        switch self {
        case .some:
            return self
        case .none: handler();
        return self
        }
    }
}

// MARK: > UIAlertController
public extension UIAlertController {
    
    public static func actionSheetWithItems<A: Equatable>(items: [(title: String, value: A)], currentSelection: A? = nil, completion: @escaping (A) -> Void) -> UIAlertController {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (var title, value) in items {
            
            if let selection = currentSelection, value == selection {
                title = title + " ✔︎"
            }
            
            controller.addAction(
                UIAlertAction(title : title, style: .default) {_ in
                    completion(value) // Passing Action
                }
            )
        }
        
        return controller
    }
    
    public func addCancelAction(handler : @escaping (UIAlertAction) -> Void = {_ in }) {
        self.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler : handler))
    }
}

// MARK: NavigationBar
public extension UINavigationBar {
    
    public func setTitle(text: String) {
        self.topItem?.title = text
    }
    
    public func setFont(font: UIFont) {
        self.titleTextAttributes = [NSAttributedStringKey.font: font]
    }
    
    public func configureTitle(font: UIFont, color: UIColor) {
        self.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: font]
    }
    
    
    @IBInspectable public var hairLine: UIColor {
        get {
            return self.hairLine
        }
        set {
            let bottomBorderRect = CGRect.zero
            let bottomBorderView = UIView(frame: bottomBorderRect)
            bottomBorderView.backgroundColor = newValue
            addSubview(bottomBorderView)
            
            bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1))
        }
    }
}

// MARK: > URL
public extension URL {
    
    public func getKeyVals() -> [String: String]? {
        
        var results = [String: String]()
        
        let keyValues = self.query?.components(separatedBy: "&")
        
        if let kvs = keyValues, !kvs.count.isEmpty {
            
            for pair in kvs {
                
                let kv = pair.components(separatedBy: "=")
                
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
    
    public func getKeyValues() -> [String: Any]? {
        
        let urlComponents = self.absoluteString.components(separatedBy: "?")
        
        guard urlComponents.count >= 1, !urlComponents[1].isEmpty else {
            return nil
        }
        
        let querys = urlComponents[1]
        
        let kv = querys.components(separatedBy: "=")
        
        var results = [String: Any]()
        
        if kv.count > 1 {
            results.updateValue(kv[1], forKey: kv[0])
        }
        
        return results
    }
}

// MARK: > UITabBarController
public extension UITabBarController {
    
    public func showTabBar() {
        self.toggleTabBar(true)
    }
    
    public func hideTabBar() {
        self.toggleTabBar(false)
    }
    
    public func toggleTabBar(_ show: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if show {
                self.tabBar.transform = CGAffineTransform.identity
            } else {
                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
            }
        })
    }
}

public extension Dictionary {
    
    public var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

public extension Bundle {
    public var displayName: String {
        return object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
}

// MARK: > UITextField
public extension UITextField {
    
    public func heightToAnimateOnEdit(_ onView: UIView, keyboardHeight: CGFloat) -> CGFloat {
        
        let frame = self.convert(CGPoint.zero, to: onView)
        
        return frame.y + self.frame.size.height + keyboardHeight - onView.frame.size.height + 10
    }
    
    @IBInspectable public var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
    
    public func addLeftPadding(frame: CGRect) {
        
        self.leftView = UIView(frame:frame)
        self.leftViewMode = UITextFieldViewMode.always
    }
    
    public func addLeftPadding(width: CGFloat = 10) {
        
        self.leftView = UIView(frame:CGRect(x: 0, y: 0, width: width, height: self.frame.size.height))
        self.leftViewMode = UITextFieldViewMode.always
    }
}

// MARK: UITableView
public extension UITableView {
    
    public func beginRefreshing() {
        // Make sure that a refresh control to be shown was actually set on the view
        // controller and the it is not already animating. Otherwise there's nothing
        // to refresh.
        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else {
            return
        }
        
        // Start the refresh animation
        refreshControl.beginRefreshing()
        
        // Make the refresh control send action to all targets as if a user executed
        // a pull to refresh manually
        refreshControl.sendActions(for: .valueChanged)
        
        // Apply some offset so that the refresh control can actually be seen
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
    
    public func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    
    // MARK: load more refresh controll
    public func showFooterLoader() {
        self.toggleFooterLoader(show: true)
    }
    
    public func hideFooterLoader() {
        self.toggleFooterLoader(show: false)
    }
    
    public func toggleFooterLoader(show: Bool) {
        
        if show {
            
            self.tableFooterView  = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 35))            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.color = UIColor.gray
            
            activityIndicator.center =  CGPoint(x: self.tableFooterView!.frame.size.width / 2.0, y: self.tableFooterView!.frame.size.height / 2.0)
            activityIndicator.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin, .flexibleHeight, .flexibleWidth]
            activityIndicator.startAnimating()
            
            self.tableFooterView!.addSubview(activityIndicator)
            
        } else {
            
            if let footer = self.tableFooterView {
                footer.removeFromSuperview()
            }
        }
    }
    
    public func clearEmptyCell() {
        self.backgroundView = nil
        self.tableFooterView = UIView.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }
    
    public func isValidIndexpath(indexPath: IndexPath) -> Bool {
        
        //Always should be lesser. because section and row calculating from 0th index.
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}

// MARK: > UICollectionView
public extension UICollectionView {
    
    public func scrollToLastIndexPath(position: UICollectionViewScrollPosition, animated: Bool) {
        
        self.layoutIfNeeded()
        
        for sectionIndex in (0..<self.numberOfSections).reversed() {
            
            if self.numberOfItems(inSection: sectionIndex) > 0 {
                self.scrollToItem(at: IndexPath.init(item: self.numberOfItems(inSection: sectionIndex)-1, section: sectionIndex), at: position, animated: animated)
                break
            }
        }
    }
}

public extension Date {
    
    public static func getDateString(fromMilliseconds millisecs: NSNumber, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: Date(timeIntervalSince1970: Double(exactly: millisecs)! / 1000.0))
        
    }
    
    public static func daySuffix(fromDate date: Date? = nil, fromDay day: Int? = nil) -> String {
        let dayOfMonth: Int
        if let dayNum = day {
            dayOfMonth = dayNum
        } else {
            let calendar = Calendar.current
            dayOfMonth = calendar.component(.day, from: date!)
        }
        
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    public static func getMessageTimeString(fromMilliSeconds millisecs: NSNumber) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM. dd, hh:mm a"
        let date = Date(timeIntervalSince1970: Double(exactly: millisecs)! / 1000.0)
        var ds = df.string(from: date)
        ds.insert(contentsOf: daySuffix(fromDate: date), at: ds.index(ds.startIndex, offsetBy: 7))
        return ds
    }
    
    public static func getMessageDetailTimeString(fromMilliseconds millisecs: NSNumber) -> String {
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy h:mm a"
        let date = Date(timeIntervalSince1970: Double(exactly: millisecs)! / 1000.0)
        let ds = df.string(from: date)
        return ds
    }
    
    static func datePhraseRelativeToToday(from date: Date) -> String {
        
        guard let todayEnd = dateEndOfToday() else {
            return ""
        }
        
        let calendar = Calendar.current
        
        let units = Set([Calendar.Component.year,
                         Calendar.Component.month,
                         Calendar.Component.weekOfMonth,
                         Calendar.Component.day])
        
        let difference = calendar.dateComponents(units, from: date, to: todayEnd)
        
        guard let year = difference.year,
            let month = difference.month,
            let week = difference.weekOfMonth,
            let day = difference.day else {
                return ""
        }
        
        var timeAgo: (scale: Int, unit: String) = (0, "")
        
        if year > 0 {
            timeAgo = (year, "Year")
        } else if month > 0 {
            timeAgo = (month, "Month")
        } else if week > 0 {
            timeAgo = (week, "Week")
        } else if day > 1 {
            timeAgo = (day, "Day")
        } else if day == 1 {
            return "Yesterday"
        } else if day < 0 ||  week < 0 ||  month < 0 || year < 0 {
            return "it is in future"
        } else {
            return "Today"
        }
        
        return String(format: "%d %@%@ Ago", timeAgo.scale, timeAgo.unit, (timeAgo.scale > 1) ? "s" : "")
    }
    
    public static func dateEndOfToday() -> Date? {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        var components = DateComponents()
        components.day = 1
        let todayEnd = calendar.date(byAdding: components, to: todayStart)
        return todayEnd
    }
    
    public static func getMinutes(fromMilliseconds millisecs: NSNumber) -> Int {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: (Double(exactly: millisecs)! / 1000)))
        
        return (dateComponents.hour! * 60) + dateComponents.minute!
    }
    
    public static func getTimeDifference(startTime: Int64, endTime: Int64) -> String {
        
        let diff = Int((endTime - startTime).toSeconds)
        
        if diff < 60 {
            return " \(diff.isEmpty ? 1 : diff) Sec"
        } else {
            return "\(Int(diff / 60)) Min"
        }
    }
    
    public init(milliseconds: Int) {
        self.init(timeIntervalSince1970: Double(milliseconds) / 1000)
    }
    
    public init(milliseconds: Int64) {
        self.init(timeIntervalSince1970: Double(milliseconds) / 1000)
    }
    
    public var currentTime: Int {
        return Int(Date().timeIntervalSince1970)
    }
    
    public var mills: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    public func toString(withFormat format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public var zeroSeconds: Date {
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calender.date(from: dateComponents) ?? self
    }
}

public extension Int64 {
    public var toSeconds: Double {
        return Double(self) / 1000
    }
}


public extension UIDevice {
    
    public var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

// MARK: > Array
public extension Array where Element: Equatable {
    
    mutating public func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    mutating public func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.remove(object: object)
        }
    }
}

public extension Array where Element: Operation {
    
    public func onFinish(block: @escaping () -> Void) {
        let doneOperation = BlockOperation(block: block)
        self.forEach { [unowned doneOperation] in doneOperation.addDependency($0) }
        OperationQueue().addOperation(doneOperation)
    }
}

public extension Array {
    
    public var firstIndex: Int {
        return self.startIndex
    }
    
    public var lastIndex: Int {
        return self.endIndex - 1
    }
    
    public var firstRow: Int {
        return self.startIndex
    }
    
    public var lastRow: Int {
        return self.endIndex
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    mutating public func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
    
    public var hasData: Bool {
        return !self.isEmpty
    }
    
    public func get(fromRange range: NSRange) -> [Element] {
        
        if range.location > self.count {
            return []
        }
        
        if range.location+range.length > self.count {
            return []
        }
        
        return Array(self[range.location..<range.location+range.length])
    }
}

// MARK: > Dictionary
public extension Dictionary {
    
    public var hasData: Bool {
        return !self.isEmpty
    }
    
    mutating public func add(key: Key, value: Value?) {
        if let value = value {
            self[key] = value
        }
    }
    
    mutating public func addAll(other: Dictionary) {
        for (key, value) in other {
            self[key] = value
        }
    }
    
    mutating public func addAll(fromDict: Dictionary?) {
        if let dict = fromDict {
            addAll(other: dict)
        }
    }
    
    mutating public func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
}

// MARK: > UITextView
public extension UITextView {
    
    public func scrollToBottom(animated: Bool) {
        
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        
        var rect = self.caretRect(for: selectedTextRange.end)
        
        rect.size.height += self.textContainerInset.bottom
        
        if animated {
            self.scrollRectToVisible(rect, animated: animated)
        } else {
            UIView.performWithoutAnimation({
                self.scrollRectToVisible(rect, animated: false)
            })
        }
    }
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    public func hidePlaceHolder() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = true
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.count.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
}

// MARK: > UIColor
public extension UIColor {
    public convenience init(rawRGBValue red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}

// MARK: > UIViewController
public extension UIViewController {
    
    public func add(asChildViewController viewController: UIViewController, toView containerView: UIView) {
        
        self.addChildViewController(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    public func remove(childViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    public func getKeyBoardHeightFromNotification(notifiation: Notification) -> CGFloat {
        
        if let userInfo = notifiation.userInfo,
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            return self.view.convert(keyboardSize, from: nil).height
        }
        return 0
    }
    
    public func getKeyboardHeight(fromNotification notification: Notification) -> CGFloat {
        
        guard let userInfo = notification.userInfo, let rect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }
        
        return self.view.convert(rect, from: nil).height
    }
}

// MARK: > UISearchBar
public extension UISearchBar {
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}

// MARK: > UIView
public extension UIView {
    
    public func rounded() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    public func roundedCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    public func addBorder(width: CGFloat, color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    public func addShadow(radius: CGFloat = 4) {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 4
    }
    
    public func addTopBorder(height: CGFloat, color: UIColor) {
        self.addOneSideBorder(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: height), color: color)
    }
    
    public func addBottomBorder(height: CGFloat, color: UIColor) {
        self.addOneSideBorder(frame: CGRect(x: 0, y: self.frame.size.height - height, width: self.frame.size.width, height: height), color: color)
    }
    
    public func addRightBorder(width: CGFloat, color: UIColor) {
        self.addOneSideBorder(frame: CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height), color: color)
    }
    
    public func addOneSideBorder(frame: CGRect, color: UIColor) {
        let border = CALayer()
        border.frame = frame
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

// MARK: > NSCoding
public extension NSCoding {
    public var archivedData: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}

public extension LazyMapCollection {
    public var array: [Element] {
        return Array(self)
    }
}

public protocol NumberConvertible {
    var toNumber: NSNumber { get }
}

// MARK: > Int64
extension Int64: NumberConvertible {
    
    public var toNumber: NSNumber {
        return NSNumber(value: self)
    }
    
    public var isEmpty: Bool {
        return self <= 0
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: > Int
extension Int: NumberConvertible {
    
    public var toNumber: NSNumber {
        return NSNumber(value: self)
    }
    
    public var isEmpty: Bool {
        return self <= 0
    }
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    public var isEqualToZero: Bool {
        return self == 0
    }
    
    public var hasData: Bool {
        return !isEmpty
    }
    
    public var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }
    
    public var second: DispatchTimeInterval {
        return seconds
    }
    
    public var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    public var millisecond: DispatchTimeInterval {
        return milliseconds
    }
    
    public var isFound: Bool {
        return self != NSNotFound
    }
    
    public var toSeconds: Double {
        return Double(self) / 1000
    }
}

// MARK: > DispatchTimeInterval
public extension DispatchTimeInterval {
    
    //Returns dispatch time
    public var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }
}

// MARK: > UserDefaults
public extension UserDefaults {
    
    // Convert int64 to number and store it
    public func setLong(value: Int64, forKey key: String) {
        
        UserDefaults.standard.set(value.toNumber, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func long(forkey key: String) -> Int64 {
        
        guard let num: NSNumber = UserDefaults.standard.object(forKey: key) as? NSNumber else {
            return 0
        }
        
        return num.int64Value
    }
}


// MARK: > UIScrollView
public extension UIScrollView {
    
    public func stopScrolling() {
        
        if !self.isDragging {
            return
        }
        
        var offset = self.contentOffset
        
        offset.x -= 1.0
        offset.y -= 1.0
        self.contentOffset = offset
        
        offset.x += 1.0
        offset.y += 1.0
        self.contentOffset = offset
    }
}

public extension UIColor {
    convenience public init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public extension UIButton {
    
    public func setFont(font: UIFont) {
        self.titleLabel?.font = font
    }
    
    public func setFontColor(color: UIColor) {
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(color, for: .selected)
        self.setTitleColor(color, for: .highlighted)
    }
    
    public func setTitle(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitle(title, for: .selected)
    }
}
