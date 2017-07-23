//  Core.swift
//  Formal (https://github.com/Meniny/Formal)
//
//  Copyright (c) 2016 Meniny (https://meniny.cn)
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

// MARK: FormalRow

internal class FormalRowDefaults {
    static var cellUpdate = [String: (FormalBaseCell, FormalBaseRow) -> Void]()
    static var cellSetup = [String: (FormalBaseCell, FormalBaseRow) -> Void]()
    static var onCellHighlightChanged = [String: (FormalBaseCell, FormalBaseRow) -> Void]()
    static var rowInitialization = [String: (FormalBaseRow) -> Void]()
    static var onRowValidationChanged = [String: (FormalBaseCell, FormalBaseRow) -> Void]()
    static var rawCellUpdate = [String: Any]()
    static var rawCellSetup = [String: Any]()
    static var rawOnCellHighlightChanged = [String: Any]()
    static var rawRowInitialization = [String: Any]()
    static var rawOnRowValidationChanged = [String: Any]()
}

// MARK: FormCells

public struct FormalCellProvider<FormalCell: FormalBaseCell> where FormalCell: FormalCellType {

    /// Nibname of the cell that will be created.
    public private (set) var nibName: String?

    /// Bundle from which to get the nib file.
    public private (set) var bundle: Bundle!

    public init() {}

    public init(nibName: String, bundle: Bundle? = nil) {
        self.nibName = nibName
        self.bundle = bundle ?? Bundle(for: FormalCell.self)
    }

    /**
     Creates the cell with the specified style.
     
     - parameter cellStyle: The style with which the cell will be created.
     
     - returns: the cell
     */
    func makeCell(style: UITableViewCellStyle) -> FormalCell {
        if let nibName = self.nibName {
            return bundle.loadNibNamed(nibName, owner: nil, options: nil)!.first as! FormalCell
//            if let views = bundle.loadNibNamed(nibName, owner: nil, options: nil) {
//                if let first = views.first {
//                    return first as! FormalCell
//                }
//            }
        }
        return FormalCell.init(style: style, reuseIdentifier: nil)
    }
}

/**
 Enumeration that defines how a controller should be created.
 
 - Callback->FormalControllerType: Creates the controller inside the specified block
 - NibFile:          Loads a controller from a nib file in some bundle
 - StoryBoard:       Loads the controller from a Storyboard by its storyboard id
 */
public enum FormalControllerProvider<FormalControllerType: UIViewController> {

    /**
     *  Creates the controller inside the specified block
     */
    case callback(builder: (() -> FormalControllerType))

    /**
     *  Loads a controller from a nib file in some bundle
     */
    case nibFile(name: String, bundle: Bundle?)

    /**
     *  Loads the controller from a Storyboard by its storyboard id
     */
    case storyBoard(storyboardId: String, storyboardName: String, bundle: Bundle?)

    func makeController() -> FormalControllerType {
        switch self {
            case .callback(let builder):
                return builder()
            case .nibFile(let nibName, let bundle):
                return FormalControllerType.init(nibName: nibName, bundle:bundle ?? Bundle(for: FormalControllerType.self))
            case .storyBoard(let storyboardId, let storyboardName, let bundle):
                let sb = UIStoryboard(name: storyboardName, bundle: bundle ?? Bundle(for: FormalControllerType.self))
                return sb.instantiateViewController(withIdentifier: storyboardId) as! FormalControllerType
        }
    }
}

/**
 Defines how a controller should be presented.
 
 - Show?:           Shows the controller with `showViewController(...)`.
 - PresentModally?: Presents the controller modally.
 - SegueName?:      Performs the segue with the specified identifier (name).
 - SegueClass?:     Performs a segue from a segue class.
 */
public enum FormalPresentationMode<FormalControllerType: UIViewController> {

    /**
     *  Shows the controller, created by the specified provider, with `showViewController(...)`.
     */
    case show(controllerProvider: FormalControllerProvider<FormalControllerType>, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Presents the controller, created by the specified provider, modally.
     */
    case presentModally(controllerProvider: FormalControllerProvider<FormalControllerType>, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Performs the segue with the specified identifier (name).
     */
    case segueName(segueName: String, onDismiss: ((UIViewController) -> Void)?)

    /**
     *  Performs a segue from a segue class.
     */
    case segueClass(segueClass: UIStoryboardSegue.Type, onDismiss: ((UIViewController) -> Void)?)

    case popover(controllerProvider: FormalControllerProvider<FormalControllerType>, onDismiss: ((UIViewController) -> Void)?)

    public var onDismissCallback: ((UIViewController) -> Void)? {
        switch self {
            case .show(_, let completion):
                return completion
            case .presentModally(_, let completion):
                return completion
            case .segueName(_, let completion):
                return completion
            case .segueClass(_, let completion):
                return completion
            case .popover(_, let completion):
                return completion
        }
    }

    /**
     Present the view controller provided by FormalPresentationMode. Should only be used from custom row implementation.
     
     - parameter viewController:           viewController to present if it makes sense (normally provided by makeController method)
     - parameter row:                      associated row
     - parameter presentingViewController: form view controller
     */
    public func present(_ viewController: FormalControllerType!, row: FormalBaseRow, presentingController: FormalViewController) {
        switch self {
            case .show(_, _):
                presentingController.show(viewController, sender: row)
            case .presentModally(_, _):
                presentingController.present(viewController, animated: true)
            case .segueName(let segueName, _):
                presentingController.performSegue(withIdentifier: segueName, sender: row)
            case .segueClass(let segueClass, _):
                let segue = segueClass.init(identifier: row.tag, source: presentingController, destination: viewController)
                presentingController.prepare(for: segue, sender: row)
                segue.perform()
            case .popover(_, _):
                guard let porpoverController = viewController.popoverPresentationController else {
                    fatalError()
                }
                porpoverController.sourceView = porpoverController.sourceView ?? presentingController.tableView
                presentingController.present(viewController, animated: true)
            }

    }

    /**
     Creates the view controller specified by presentation mode. Should only be used from custom row implementation.
     
     - returns: the created view controller or nil depending on the FormalPresentationMode type.
     */
    public func makeController() -> FormalControllerType? {
        switch self {
            case .show(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .presentModally(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            case .popover(let controllerProvider, let completionCallback):
                let controller = controllerProvider.makeController()
                controller.modalPresentationStyle = .popover
                let completionController = controller as? RowControllerType
                if let callback = completionCallback {
                    completionController?.onDismissCallback = callback
                }
                return controller
            default:
                return nil
        }
    }
}

/**
 *  Protocol to be implemented by custom formatters.
 */
public protocol FormalFormatterProtocol {
    func getNewPosition(forPosition: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition
}

// MARK: Predicate Machine

enum FormalConditionType {
    case hidden, disabled
}

/**
 Enumeration that are used to specify the disbaled and hidden conditions of rows
 
 - Function:  A function that calculates the result
 - Predicate: A predicate that returns the result
 */
public enum FormalCondition {
    /**
     *  Calculate the condition inside a block
     *
     *  @param tags Array of tags of the rows this function depends on
     *  @param closure The closure that calculates the result
     *
     *  @return If the condition is true or false
     */
    case closure(tags: [String], closure: (Formal)->Bool)

    /**
     *  Calculate the condition using a NSPredicate
     *
     *  @param NSPredicate The predicate that will be evaluated
     *
     *  @return If the condition is true or false
     */
    case predicate(NSPredicate)
}

extension FormalCondition : ExpressibleByBooleanLiteral {

    /**
     Initialize a condition to return afixed boolean value always
     */
    public init(booleanLiteral value: Bool) {
        self = FormalCondition.closure(tags: []) { _ in return value }
    }
}

extension FormalCondition : ExpressibleByStringLiteral {

    /**
     Initialize a FormalCondition with a string that will be converted to a NSPredicate
     */
    public init(stringLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }

    /**
     Initialize a FormalCondition with a string that will be converted to a NSPredicate
     */
    public init(unicodeScalarLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }

    /**
     Initialize a FormalCondition with a string that will be converted to a NSPredicate
     */
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .predicate(NSPredicate(format: value))
    }
}

// MARK: Errors

/**
Errors thrown by Formal

- DuplicatedTag: When a section or row is inserted whose tag dows already exist
*/
public enum FormalError: Error {
    case duplicatedTag(tag: String)
}

//Mark: FormalViewController

/**
*  A protocol implemented by FormalViewController
*/
public protocol FormalViewControllerProtocol {
    var tableView: UITableView! { get }

    func beginEditing<F: Equatable>(of: FormalCell<F>)
    func endEditing<F: Equatable>(of: FormalCell<F>)

    func insertAnimation(forRows rows: [FormalBaseRow]) -> UITableViewRowAnimation
    func deleteAnimation(forRows rows: [FormalBaseRow]) -> UITableViewRowAnimation
    func reloadAnimation(oldRows: [FormalBaseRow], newRows: [FormalBaseRow]) -> UITableViewRowAnimation
    func insertAnimation(forSections sections: [FormalSection]) -> UITableViewRowAnimation
    func deleteAnimation(forSections sections: [FormalSection]) -> UITableViewRowAnimation
    func reloadAnimation(oldSections: [FormalSection], newSections: [FormalSection]) -> UITableViewRowAnimation
}

/**
 *  Navigation options for a form view controller.
 */
public struct RowNavigationOptions: OptionSet {

    private enum NavigationOptions: Int {
        case disabled = 0, enabled = 1, stopDisabledRow = 2, skipCanNotBecomeFirstResponderRow = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: NavigationOptions ) { self.rawValue = options.rawValue }

    /// No navigation.
    public static let Disabled = RowNavigationOptions(.disabled)

    /// Full navigation.
    public static let Enabled = RowNavigationOptions(.enabled)

    /// Break navigation when next row is disabled.
    public static let StopDisabledRow = RowNavigationOptions(.stopDisabledRow)

    /// Break navigation when next row cannot become first responder.
    public static let SkipCanNotBecomeFirstResponderRow = RowNavigationOptions(.skipCanNotBecomeFirstResponderRow)
}

/**
 *  Defines the configuration for the keyboardType of FieldRows.
 */
public struct FormalKeyboardReturnTypeConfiguration {
    /// Used when the next row is available.
    public var nextKeyboardType = UIReturnKeyType.next

    /// Used if next row is not available.
    public var defaultKeyboardType = UIReturnKeyType.default

    public init() {}

    public init(nextKeyboardType: UIReturnKeyType, defaultKeyboardType: UIReturnKeyType) {
        self.nextKeyboardType = nextKeyboardType
        self.defaultKeyboardType = defaultKeyboardType
    }
}

/**
 *  Options that define when an inline row should collapse.
 */
public struct InlineRowHideOptions: OptionSet {

    private enum _InlineRowHideOptions: Int {
        case never = 0, anotherInlineRowIsShown = 1, firstResponderChanges = 2
    }
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: _InlineRowHideOptions ) { self.rawValue = options.rawValue }

    /// Never collapse automatically. Only when user taps inline row.
    public static let Never = InlineRowHideOptions(.never)

    /// Collapse qhen another inline row expands. Just one inline row will be expanded at a time.
    public static let AnotherInlineRowIsShown = InlineRowHideOptions(.anotherInlineRowIsShown)

    /// Collapse when first responder changes.
    public static let FirstResponderChanges = InlineRowHideOptions(.firstResponderChanges)
}

/// View controller that shows a formal.
open class FormalViewController: UIViewController, FormalViewControllerProtocol, FormalDelegate {

    @IBOutlet public var tableView: UITableView!

    private lazy var _formal: Formal = { [weak self] in
        let formal = Formal()
        formal.delegate = self
        return formal
        }()

    public var formal: Formal {
        get { return _formal }
        set {
            guard formal !== newValue else { return }
            _formal.delegate = nil
            tableView?.endEditing(false)
            _formal = newValue
            _formal.delegate = self
            if isViewLoaded {
                tableView?.reloadData()
            }
        }
    }

    /// Extra space to leave between between the row in focus and the keyboard
    open var rowKeyboardSpacing: CGFloat = 0

    /// Enables animated scrolling on row navigation
    open var animateScroll = false

    /// Accessory view that is responsible for the navigation between rows
    open var navigationAccessoryView: FormalNavigationAccessoryView!

    /// Defines the behaviour of the navigation between rows
    public var navigationOptions: RowNavigationOptions?
    private var tableViewStyle: UITableViewStyle = .grouped

    public init(style: UITableViewStyle) {
        super.init(nibName: nil, bundle: nil)
        tableViewStyle = style
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationAccessoryView = FormalNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44.0))
        navigationAccessoryView.autoresizingMask = .flexibleWidth

        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: tableViewStyle)
            tableView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
            if #available(iOS 9.0, *) {
                tableView.cellLayoutMarginsFollowReadableWidth = false
            }
        }
        if tableView.superview == nil {
            view.addSubview(tableView)
        }
        if tableView.delegate == nil {
            tableView.delegate = self
        }
        if tableView.dataSource == nil {
            tableView.dataSource = self
        }
        tableView.estimatedRowHeight = FormalBaseRow.estimatedRowHeight

        tableView.setEditing(true, animated: false)
        tableView.allowsSelectionDuringEditing = true
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateTableView = true
        let selectedIndexPaths = tableView.indexPathsForSelectedRows ?? []
        if !selectedIndexPaths.isEmpty {
            tableView.reloadRows(at: selectedIndexPaths, with: .none)
        }
        selectedIndexPaths.forEach {
            tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
        }

        let deselectionAnimation = { [weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            selectedIndexPaths.forEach {
                self?.tableView.deselectRow(at: $0, animated: context.isAnimated)
            }
        }

        let reselection = { [weak self] (context: UIViewControllerTransitionCoordinatorContext) in
            if context.isCancelled {
                selectedIndexPaths.forEach {
                    self?.tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
                }
            }
        }

        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: deselectionAnimation, completion: reselection)
        } else {
            selectedIndexPaths.forEach {
                tableView.deselectRow(at: $0, animated: false)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(FormalViewController.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FormalViewController.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let baseRow = sender as? FormalBaseRow
        baseRow?.prepare(for: segue)
    }

    /**
     Returns the navigation accessory view if it is enabled. Returns nil otherwise.
     */
    open func inputAccessoryView(for row: FormalBaseRow) -> UIView? {
        let options = navigationOptions ?? Formal.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard row.baseCell.cellCanBecomeFirstResponder() else { return nil}
        navigationAccessoryView.previousButton.isEnabled = nextRow(for: row, withDirection: .up) != nil
        navigationAccessoryView.doneButton.target = self
        navigationAccessoryView.doneButton.action = #selector(FormalViewController.navigationDone(_:))
        navigationAccessoryView.previousButton.target = self
        navigationAccessoryView.previousButton.action = #selector(FormalViewController.navigationAction(_:))
        navigationAccessoryView.nextButton.target = self
        navigationAccessoryView.nextButton.action = #selector(FormalViewController.navigationAction(_:))
        navigationAccessoryView.nextButton.isEnabled = nextRow(for: row, withDirection: .down) != nil
        return navigationAccessoryView
    }

    // MARK: FormalViewControllerProtocol

    /**
    Called when a cell becomes first responder
    */
    public final func beginEditing<F: Equatable>(of cell: FormalCell<F>) {
        cell.row.isHighlighted = true
        cell.row.updateCell()
        FormalRowDefaults.onCellHighlightChanged["\(type(of: cell.row!))"]?(cell, cell.row)
        cell.row.callbackOnCellHighlightChanged?()
        guard let _ = tableView, (formal.inlineRowHideOptions ?? Formal.defaultInlineRowHideOptions).contains(.FirstResponderChanges) else { return }
        let row = cell.baseRow
        let inlineRow = row?._inlineRow
        for row in formal.allRows.filter({ $0 !== row && $0 !== inlineRow && $0._inlineRow != nil }) {
            if let inlineRow = row as? FormalBaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }

    /**
     Called when a cell resigns first responder
     */
    public final func endEditing<F: Equatable>(of cell: FormalCell<F>) {
        cell.row.isHighlighted = false
        cell.row.wasBlurred = true
        FormalRowDefaults.onCellHighlightChanged["\(type(of: self))"]?(cell, cell.row)
        cell.row.callbackOnCellHighlightChanged?()
        if cell.row.validationOptions.contains(.validatesOnBlur) || (cell.row.wasChanged && cell.row.validationOptions.contains(.validatesOnChangeAfterBlurred)) {
            cell.row.validate()
        }
        cell.row.updateCell()
    }

    /**
     Returns the animation for the insertion of the given rows.
     */
    open func insertAnimation(forRows rows: [FormalBaseRow]) -> UITableViewRowAnimation {
        return .fade
    }

    /**
     Returns the animation for the deletion of the given rows.
     */
    open func deleteAnimation(forRows rows: [FormalBaseRow]) -> UITableViewRowAnimation {
        return .fade
    }

    /**
     Returns the animation for the reloading of the given rows.
     */
    open func reloadAnimation(oldRows: [FormalBaseRow], newRows: [FormalBaseRow]) -> UITableViewRowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the insertion of the given sections.
     */
    open func insertAnimation(forSections sections: [FormalSection]) -> UITableViewRowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the deletion of the given sections.
     */
    open func deleteAnimation(forSections sections: [FormalSection]) -> UITableViewRowAnimation {
        return .automatic
    }

    /**
     Returns the animation for the reloading of the given sections.
     */
    open func reloadAnimation(oldSections: [FormalSection], newSections: [FormalSection]) -> UITableViewRowAnimation {
        return .automatic
    }

    // MARK: TextField and TextView Delegate

    open func textInputShouldBeginEditing<F>(_ textInput: UITextInput, cell: FormalCell<F>) -> Bool {
        return true
    }

    open func textInputDidBeginEditing<F>(_ textInput: UITextInput, cell: FormalCell<F>) {
        if let row = cell.row as? FormalKeyboardReturnHandler {
            let next = nextRow(for: cell.row, withDirection: .down)
            if let textField = textInput as? UITextField {
                textField.returnKeyType = next != nil ? (row.keyboardReturnType?.nextKeyboardType ??
                    (formal.keyboardReturnType?.nextKeyboardType ?? Formal.defaultKeyboardReturnType.nextKeyboardType )) :
                    (row.keyboardReturnType?.defaultKeyboardType ?? (formal.keyboardReturnType?.defaultKeyboardType ??
                        Formal.defaultKeyboardReturnType.defaultKeyboardType))
            } else if let textView = textInput as? UITextView {
                textView.returnKeyType = next != nil ? (row.keyboardReturnType?.nextKeyboardType ??
                    (formal.keyboardReturnType?.nextKeyboardType ?? Formal.defaultKeyboardReturnType.nextKeyboardType )) :
                    (row.keyboardReturnType?.defaultKeyboardType ?? (formal.keyboardReturnType?.defaultKeyboardType ??
                        Formal.defaultKeyboardReturnType.defaultKeyboardType))
            }
        }
    }

    open func textInputShouldEndEditing<F>(_ textInput: UITextInput, cell: FormalCell<F>) -> Bool {
        return true
    }

    open func textInputDidEndEditing<F>(_ textInput: UITextInput, cell: FormalCell<F>) {

    }

    open func textInput<F>(_ textInput: UITextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String, cell: FormalCell<F>) -> Bool {
        return true
    }

    open func textInputShouldClear<F>(_ textInput: UITextInput, cell: FormalCell<F>) -> Bool {
        return true
    }

    open func textInputShouldReturn<F>(_ textInput: UITextInput, cell: FormalCell<F>) -> Bool {
        if let nextRow = nextRow(for: cell.row, withDirection: .down) {
            if nextRow.baseCell.cellCanBecomeFirstResponder() {
                nextRow.baseCell.cellBecomeFirstResponder()
                return true
            }
        }
        tableView?.endEditing(true)
        return true
    }

    // MARK: FormalDelegate

    open func valueHasBeenChanged(for: FormalBaseRow, oldValue: Any?, newValue: Any?) {}

    // MARK: UITableViewDelegate

    @objc open func tableView(_ tableView: UITableView, willBeginReorderingRowAtIndexPath indexPath: IndexPath) {
        // end editing if inline cell is first responder
        let row = formal[indexPath]
        if let inlineRow = row as? FormalBaseInlineRowType, row._inlineRow != nil {
            inlineRow.collapseInlineRow()
        }
    }
    
    // MARK: FormalDelegate
    
    open func sectionsHaveBeenAdded(_ sections: [FormalSection], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.insertSections(indexes, with: insertAnimation(forSections: sections))
        tableView?.endUpdates()
    }
    
    open func sectionsHaveBeenRemoved(_ sections: [FormalSection], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.deleteSections(indexes, with: deleteAnimation(forSections: sections))
        tableView?.endUpdates()
    }
    
    open func sectionsHaveBeenReplaced(oldSections: [FormalSection], newSections: [FormalSection], at indexes: IndexSet) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.reloadSections(indexes, with: reloadAnimation(oldSections: oldSections, newSections: newSections))
        tableView?.endUpdates()
    }
    
    open func rowsHaveBeenAdded(_ rows: [FormalBaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.insertRows(at: indexes, with: insertAnimation(forRows: rows))
        tableView?.endUpdates()
    }
    
    open func rowsHaveBeenRemoved(_ rows: [FormalBaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.deleteRows(at: indexes, with: deleteAnimation(forRows: rows))
        tableView?.endUpdates()
    }
    
    open func rowsHaveBeenReplaced(oldRows: [FormalBaseRow], newRows: [FormalBaseRow], at indexes: [IndexPath]) {
        guard animateTableView else { return }
        tableView?.beginUpdates()
        tableView?.reloadRows(at: indexes, with: reloadAnimation(oldRows: oldRows, newRows: newRows))
        tableView?.endUpdates()
    }

    // MARK: Private

    var oldBottomInset: CGFloat?
    var animateTableView = false
}

extension FormalViewController : UITableViewDelegate {

    // MARK: UITableViewDelegate

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.tableView else { return }
        let row = formal[indexPath]
        // row.baseCell.cellBecomeFirstResponder() may be cause FormalInlineRow collapsed then section count will be changed. Use orignal indexPath will out of  section's bounds.
        if !row.baseCell.cellCanBecomeFirstResponder() || !row.baseCell.cellBecomeFirstResponder() {
            self.tableView?.endEditing(true)
        }
        row.didSelect()
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.rowHeight }
        let row = formal[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.rowHeight
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView == self.tableView else { return tableView.rowHeight }
        let row = formal[indexPath.section][indexPath.row]
        return row.baseCell.height?() ?? tableView.estimatedRowHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return formal[section].header?.viewForSection(formal[section], type: .header)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return formal[section].footer?.viewForSection(formal[section], type:.footer)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = formal[section].header?.height {
            return height()
        }
        guard let view = formal[section].header?.viewForSection(formal[section], type: .header) else {
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = formal[section].footer?.height {
            return height()
        }
        guard let view = formal[section].footer?.viewForSection(formal[section], type: .footer) else {
            return UITableViewAutomaticDimension
        }
        guard view.bounds.height != 0 else {
            return UITableViewAutomaticDimension
        }
        return view.bounds.height
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = formal[indexPath.section] as? FormalMultivaluedSection else { return false }
        let row = formal[indexPath]
        guard !row.isDisabled else { return false }
        guard !(indexPath.row == section.count - 1 && section.multivaluedOptions.contains(.Insert) && section.showInsertIconInAddButton) else {
            return true
        }
        if indexPath.row > 0 && section[indexPath.row - 1] is FormalBaseInlineRowType && section[indexPath.row - 1]._inlineRow != nil {
            return false
        }
        return true
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = formal[indexPath]
            let section = row.section!
            if let _ = row.baseCell.findFirstResponder() {
                tableView.endEditing(true)
            }
            section.remove(at: indexPath.row)
            DispatchQueue.main.async {
                tableView.isEditing = !tableView.isEditing
                tableView.isEditing = !tableView.isEditing
            }
        } else if editingStyle == .insert {
            guard var section = formal[indexPath.section] as? FormalMultivaluedSection else { return }
            guard let multivaluedRowToInsertAt = section.multivaluedRowToInsertAt else {
                fatalError("Multivalued section multivaluedRowToInsertAt property must be set up")
            }
            let newRow = multivaluedRowToInsertAt(max(0, section.count - 1))
            section.insert(newRow, at: section.count - 1)
            DispatchQueue.main.async {
                tableView.isEditing = !tableView.isEditing
                tableView.isEditing = !tableView.isEditing
            }
            tableView.scrollToRow(at: IndexPath(row: section.count - 1, section: indexPath.section), at: .bottom, animated: true)
            if newRow.baseCell.cellCanBecomeFirstResponder() {
                newRow.baseCell.cellBecomeFirstResponder()
            } else if let inlineRow = newRow as? FormalBaseInlineRowType {
                inlineRow.expandInlineRow()
            }
        }
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let section = formal[indexPath.section] as? FormalMultivaluedSection, section.multivaluedOptions.contains(.Reorder) && section.count > 1 else {
            return false
        }
        if section.multivaluedOptions.contains(.Insert) && (section.count <= 2 || indexPath.row == (section.count - 1)) {
            return false
        }
        if indexPath.row > 0 && section[indexPath.row - 1] is FormalBaseInlineRowType && section[indexPath.row - 1]._inlineRow != nil {
            return false
        }
        return true
    }

    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard let section = formal[sourceIndexPath.section] as? FormalMultivaluedSection else { return sourceIndexPath }
        guard sourceIndexPath.section == proposedDestinationIndexPath.section else { return sourceIndexPath }

        let destRow = formal[proposedDestinationIndexPath]
        if destRow is FormalBaseInlineRowType && destRow._inlineRow != nil {
            return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
        }

        if proposedDestinationIndexPath.row > 0 {
            let previousRow = formal[IndexPath(row: proposedDestinationIndexPath.row - 1, section: proposedDestinationIndexPath.section)]
            if previousRow is FormalBaseInlineRowType && previousRow._inlineRow != nil {
                return IndexPath(row: proposedDestinationIndexPath.row + (sourceIndexPath.row < proposedDestinationIndexPath.row ? 1 : -1), section:sourceIndexPath.section)
            }
        }
        if section.multivaluedOptions.contains(.Insert) && proposedDestinationIndexPath.row == section.count - 1 {
            return IndexPath(row: section.count - 2, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard var section = formal[sourceIndexPath.section] as? FormalMultivaluedSection else { return }
        if sourceIndexPath.row < section.count && destinationIndexPath.row < section.count && sourceIndexPath.row != destinationIndexPath.row {

            let sourceRow = formal[sourceIndexPath]
            animateTableView = false
            section.remove(at: sourceIndexPath.row)
            section.insert(sourceRow, at: destinationIndexPath.row)
            animateTableView = true
            // update the accessory view
            let _ = inputAccessoryView(for: sourceRow)
        }
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let section = formal[indexPath.section] as? FormalMultivaluedSection else {
            return .none
        }
        if section.multivaluedOptions.contains(.Insert) && indexPath.row == section.count - 1 {
            return .insert
        }
        if section.multivaluedOptions.contains(.Delete) {
            return .delete
        }
        return .none
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return self.tableView(tableView, editingStyleForRowAt: indexPath) != .none
    }
}

extension FormalViewController : UITableViewDataSource {

    // MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int {
        return formal.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formal[section].count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    	formal[indexPath].updateCell()
        return formal[indexPath].baseCell
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formal[section].header?.title
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return formal[section].footer?.title
    }
}


extension FormalViewController : UIScrollViewDelegate {

    // MARK: UIScrollViewDelegate

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let tableView = tableView, scrollView === tableView else { return }
        tableView.endEditing(true)
    }
}

extension FormalViewController {

    // MARK: KeyBoard Notifications

    /**
     Called when the keyboard will appear. Adjusts insets of the tableView and scrolls it if necessary.
     */
    open func keyboardWillShow(_ notification: Notification) {
        guard let table = tableView, let cell = table.findFirstResponder()?.formCell() else { return }
        let keyBoardInfo = notification.userInfo!
        let endFrame = keyBoardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue

        let keyBoardFrame = table.window!.convert(endFrame.cgRectValue, to: table.superview)
        let newBottomInset = table.frame.origin.y + table.frame.size.height - keyBoardFrame.origin.y + rowKeyboardSpacing
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        oldBottomInset = oldBottomInset ?? tableInsets.bottom
        if newBottomInset > oldBottomInset! {
            tableInsets.bottom = newBottomInset
            scrollIndicatorInsets.bottom = tableInsets.bottom
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration((keyBoardInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double))
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: (keyBoardInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int))!)
            table.contentInset = tableInsets
            table.scrollIndicatorInsets = scrollIndicatorInsets
            if let selectedRow = table.indexPath(for: cell) {
                table.scrollToRow(at: selectedRow, at: .none, animated: animateScroll)
            }
            UIView.commitAnimations()
        }
    }

    /**
     Called when the keyboard will disappear. Adjusts insets of the tableView.
     */
    open func keyboardWillHide(_ notification: Notification) {
        guard let table = tableView, let oldBottom = oldBottomInset else { return }
        let keyBoardInfo = notification.userInfo!
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        tableInsets.bottom = oldBottom
        scrollIndicatorInsets.bottom = tableInsets.bottom
        oldBottomInset = nil
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((keyBoardInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double))
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: (keyBoardInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int))!)
        table.contentInset = tableInsets
        table.scrollIndicatorInsets = scrollIndicatorInsets
        UIView.commitAnimations()
    }
}

public enum Direction { case up, down }

extension FormalViewController {

    // MARK: Navigation Methods

    func navigationDone(_ sender: UIBarButtonItem) {
        tableView?.endEditing(true)
    }

    func navigationAction(_ sender: UIBarButtonItem) {
        navigateTo(direction: sender == navigationAccessoryView.previousButton ? .up : .down)
    }

    public func navigateTo(direction: Direction) {
        guard let currentCell = tableView?.findFirstResponder()?.formCell() else { return }
        guard let currentIndexPath = tableView?.indexPath(for: currentCell) else { assertionFailure(); return }
        guard let nextRow = nextRow(for: formal[currentIndexPath], withDirection: direction) else { return }
        if nextRow.baseCell.cellCanBecomeFirstResponder() {
            tableView?.scrollToRow(at: nextRow.indexPath!, at: .none, animated: animateScroll)
            nextRow.baseCell.cellBecomeFirstResponder(withDirection: direction)
        }
    }

    func nextRow(for currentRow: FormalBaseRow, withDirection direction: Direction) -> FormalBaseRow? {

        let options = navigationOptions ?? Formal.defaultNavigationOptions
        guard options.contains(.Enabled) else { return nil }
        guard let next = direction == .down ? formal.nextRow(for: currentRow) : formal.previousRow(for: currentRow) else {
            return nil
        }
        if next.isDisabled && options.contains(.StopDisabledRow) {
            return nil
        }
        if !next.baseCell.cellCanBecomeFirstResponder() && !next.isDisabled && !options.contains(.SkipCanNotBecomeFirstResponderRow) {
            return nil
        }
        if !next.isDisabled && next.baseCell.cellCanBecomeFirstResponder() {
            return next
        }
        return nextRow(for: next, withDirection:direction)
    }
}

extension FormalViewControllerProtocol {

    // MARK: Helpers

    func makeRowVisible(_ row: FormalBaseRow) {
        guard let cell = row.baseCell, let indexPath = row.indexPath, let tableView = tableView else { return }
        if cell.window == nil || (tableView.contentOffset.y + tableView.frame.size.height <= cell.frame.origin.y + cell.frame.size.height) {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
