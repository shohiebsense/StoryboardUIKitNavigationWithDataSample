//
//  TaskDetailsViewController.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import UIKit

protocol TaskDelegate: class {
    func didTapSave(task: Task)
    func didTapUpdate(task: Task)
}

class TaskDetailsViewController: UIViewController{

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    
    var task : Task? = nil
    var isUpdate : Bool = false
    var hapticGenerator: UINotificationFeedbackGenerator? = nil
    weak var delegate : TaskDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        isUpdate = (task != nil)
        loadTaskForUpdate()
        taskTitleTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        saveButton.title = isUpdate ? Constants.Action.update : Constants.Action.add

    }
    
    func loadTaskForUpdate() {
        guard let task = self.task else {
            //subTasksTextView.textColor = .placeholderText
            return
        }
        taskTitleTextField.text = task.title
     
    }
    
    @IBAction func saveTaped(_ sender: Any) {
        hapticGenerator = UINotificationFeedbackGenerator()
        hapticGenerator?.prepare()
        
        guard let task = createTaskBody() else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        hapticGenerator?.notificationOccurred(.success)

        if isUpdate {
            self.delegate?.didTapUpdate(task: task)
        } else {
            self.delegate?.didTapSave(task: task)
        }
        self.navigationController?.popViewController(animated: true)
        
        hapticGenerator = nil
    }
    
    
    func createTaskBody()->Task? {
        let title = taskTitleTextField.text?.trim() ?? .empty
       
        /// check if we are updating the task or creatiing the task
        if self.task == nil {
            let mainController = self.delegate as! TodoViewController
            self.task = Task(context: mainController.moc)
        }
        task?.title = title
       
        task?.isComplete = false
        
        return task
    }
    
    
}


extension TaskDetailsViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == taskTitleTextField {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your subtasks here"
            textView.textColor = .placeholderText
        }
    }
}

