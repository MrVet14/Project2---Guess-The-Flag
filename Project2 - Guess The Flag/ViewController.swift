//
//  ViewController.swift
//  Project2 - Guess The Flag
//
//  Created by Vitali Vyucheiski on 3/2/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var numberOfGames = 0
    var maxScore = 0
    var newMaxScoreShowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        let defaults = UserDefaults.standard
        maxScore = defaults.integer(forKey: "maxScore")
        
        askQuestion()
        
        registerLocal()
        scheduleLocal()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + " - Your score is \(score) + " + "MaxScore:\(maxScore)"
        numberOfGames += 1
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: [], animations: { sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) }, completion: { _ in sender.transform = CGAffineTransform(scaleX: 1, y: 1) })
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            if maxScore < score { maxScore += 1 }
            save()
            if maxScore == score && !newMaxScoreShowed {
                newMaxScoreAC()
                newMaxScoreShowed.toggle()
            }
        } else {
            title = "Wrong"
            score -= 1
        }
        
        var message = "Your score is \(score)"
        
        if title == "Wrong" {
            message = "That's flag of \(countries[sender.tag].uppercased() ) - " + message
        }
        
        if numberOfGames == 10 {
            message += " - you've played 10 games!"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(maxScore, forKey: "maxScore")
    }
    
    func newMaxScoreAC() {
        let ac = UIAlertController(title: "You got new Best Score!", message: "Way to GO!!!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
// Notifications ---------------------
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "You played today?"
        content.body = "Time to get brand new max score"
        content.categoryIdentifier = "reminder"
        content.userInfo = [:]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 30
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
       center.add(request)
    }
    
}

