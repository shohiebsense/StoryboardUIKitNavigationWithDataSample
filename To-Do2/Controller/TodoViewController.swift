//
//  TodoViewController.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import UIKit
import CoreData


class TodoViewController: UITableViewController {
    
    
    var todoList : [Task] = []
    
    /// last task tapped!
    var lastIndexTapped : Int = 0
    
    var moc: NSManagedObjectContext!
    
    lazy var defaultFetchRequest: NSFetchRequest<Task> = {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        return fetchRequest
    }()
    
    var currentSelectedSortType: SortTypesAvailable = .sortByNameAsc
    
    var fetchedResultsController: NSFetchedResultsController<Task>!
    
    var resultsTableController: ResultsTableController!

    var hapticNotificationGenerator: UINotificationFeedbackGenerator? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        showOnboardingIfNeeded() /// present onboarding screen for first time
        setupEmptyState() /// show emppty view if no tasks present
        loadData() /// Core data setup and population
        setupSearchController() /// setup search view controller for searching
    }
    
    fileprivate func showOnboardingIfNeeded() {
        guard let onboardingController = self.storyboard?.instantiateViewController(identifier: Constants.ViewController.Onboarding) as? OnBoardingViewController else { return }
        
        if !onboardingController.alreadyShown() {
            DispatchQueue.main.async {
                self.present(onboardingController, animated: true)
            }
        }
    }
    
    fileprivate func setupEmptyState() {
        let emptyBackgroundView = EmptyState(.emptyList)
        tableView.backgroundView = emptyBackgroundView
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //self.sortButton.isEnabled = self.todoList.count > 0
        
        if todoList.isEmpty {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
            
        }
        
        return todoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.taskCell, for: indexPath) as! TaskCell
        let task = todoList[indexPath.row]
        cell.title.text = task.title
        //cell.subtitle.text = task.dueDate
        cell.starImage.isHidden = todoList[indexPath.row].isFavourite ? false : true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastIndexTapped = indexPath.row
        let task = todoList[indexPath.row]
        performSegue(withIdentifier: Constants.Segue.taskToTaskDetail, sender: task)
    }
    

    
    /// `UISwipeActionsConfiguration` for completing a task
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeTask = UIContextualAction(style: .normal, title: .empty) {  (_, _, _) in
            self.completeTask(at: indexPath.row)
        }
        completeTask.backgroundColor = .systemGreen
        completeTask.title = Constants.Action.complete
        let swipeActions = UISwipeActionsConfiguration(actions: [completeTask])
        
        return swipeActions
    }
    
    /// function to determine `View for Footer` in tableview.
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView() /// Returns an empty view.
    }
    
    fileprivate func setupSearchController() {
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewController.ResultsTable) as? ResultsTableController
        resultsTableController.tableView.delegate = self
//        searchController = UISearchController(searchResultsController: resultsTableController)
//        searchController.delegate = self
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.autocapitalizationType = .none
//        searchController.searchBar.delegate = self
//        searchController.view.backgroundColor = .white
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let persistenceContainer = appDelegate.persistentContainer
        moc = persistenceContainer.viewContext
        defaultFetchRequest.sortDescriptors = currentSelectedSortType.getSortDescriptor()
        defaultFetchRequest.predicate = NSPredicate(format: "isComplete = %d", false)
        setupFetchedResultsController(fetchRequest: defaultFetchRequest)
        /// reloading the table view with the fetched objects
        if let objects = fetchedResultsController.fetchedObjects {
            self.todoList = objects
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func setupFetchedResultsController(fetchRequest: NSFetchRequest<Task>) {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func completeTask(at index : Int){
        todoList[index].isComplete = true
        todoList.remove(at: index) /// removes task at index
        updateTask()
        tableView.reloadData()
    }
    
    func updateTask(){
        hapticNotificationGenerator = UINotificationFeedbackGenerator()
        hapticNotificationGenerator?.prepare()
        
        do {
            try moc.save()
            hapticNotificationGenerator?.notificationOccurred(.success)
        } catch {
            print(error.localizedDescription)
            hapticNotificationGenerator?.notificationOccurred(.error)
        }
        loadData()
        hapticNotificationGenerator = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskDetailVC = segue.destination as? TaskDetailsViewController {
            // Hide the tab bar when new controller is pushed onto the screen
            taskDetailVC.hidesBottomBarWhenPushed = true
            taskDetailVC.delegate = self
            taskDetailVC.task = sender as? Task
        }
    }
    
    
    @IBAction func addTaskTapped(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segue.taskToTaskDetail, sender: false)
    }
    
}


extension TodoViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            break
        @unknown default:
            break
        }
    }
}


//MARK: - TaskDelegate
/// protocol for `saving` or `updating` `Tasks`
extension TodoViewController : TaskDelegate{
    func didTapSave(task: Task) {
        todoList.append(task)
        do {
            try moc.save()
        } catch {
            todoList.removeLast()
            print(error.localizedDescription)
        }
        loadData()
    }
    
    func didTapUpdate(task: Task) {
        /// Reload tableview with new data
        //updateTask()
    }
    
    
}

// MARK: - Search Bar Delegate

extension TodoViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        /// perform search only when there is some text
        if let text: String = searchController.searchBar.text?.lowercased(), text.count > 0, let resultsController = searchController.searchResultsController as? ResultsTableController {
            resultsController.todoList = todoList.filter({ (task) -> Bool in
                if task.title?.lowercased().contains(text) == true || task.subTasks?.lowercased().contains(text) == true {
                    return true
                }
                return false
            })
            let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "title contains[c] %@", text)
            setupFetchedResultsController(fetchRequest: fetchRequest)
            resultsController.tableView.reloadData()
        } else {
            /// default case when text not available or text length is zero
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
}

extension TodoViewController {
    
    func showSortAlertController() {
        let alertController = UIAlertController(title: nil, message: "Choose sort type", preferredStyle: .actionSheet)
        
        SortTypesAvailable.allCases.forEach { (sortType) in
            let action = UIAlertAction(title: sortType.getTitleForSortType(), style: .default) { (_) in
                self.currentSelectedSortType = sortType
                self.loadData()
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: Constants.Action.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}

