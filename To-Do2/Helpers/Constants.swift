//
//  Constants.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import Foundation



class Constants {
    
    struct ViewController{
        static let Onboarding = "OnboardingViewController"
        static let ResultsTable = "ResultsTableController"
    }
    
    struct Cell{
        static let taskCell = "todocell"
        static let photoCell = "AttachmentCell"
    }
    
    struct Segue{
        static let taskToTaskDetail = "gototask"
    }
    
    struct Key{
        static let onboarding = "already_shown_onboarding"
    }
    
    struct Action{
        static let star = "star"
        static let unstar = "unstar"
        static let add = "add"
        static let update = "update"
        static let delete = "delete"
        static let complete = "complete"
        static let cancel = "cancel"
    }
}
