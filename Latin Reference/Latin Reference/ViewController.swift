//
//  ViewController.swift
//  Latin Reference
//
//  Created by Drake Deuel on 12/4/17.
//  Copyright © 2017 Drake Deuel. All rights reserved.
//

import UIKit

var outText: String = ""

// create model struct based on json file
struct Word: Decodable {
    let base_forms: [String?]?
    let declension: Int?
    let conjugation: Int?
    let definition: String?
    let type: Class?
    let gender: Gender?
    enum CodingKeys : String, CodingKey {
        case base_forms, declension, conjugation, definition, gender
        case type = "class"
    }
}
struct Class : Decodable {
    let value: String?
}
struct Gender : Decodable {
    let value: String?
}

// class to handle loading local json file
public final class DataManager {
    public static func getJSONFromURL(_ resource:String, completion:@escaping (_ data:Data?, _ error:Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let filePath = Bundle.main.path(forResource: resource, ofType: "json")
            let url = URL(fileURLWithPath: filePath!)
            let data = try! Data(contentsOf: url, options: .uncached)
            completion(data, nil)
        }
        
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameEnglishTextField: UITextField!
    @IBOutlet weak var nameOutput: UITextView!
    
    var words: [Word]?
    
    // function is called on inital load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load in the json file as a Swift struct
        DataManager.getJSONFromURL("words") { (data, error) in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                self.words = try decoder.decode([Word].self, from: data)
            }
            catch {
                print("failed to convert data")
                }
        }
        
        // Handle the text field's user input through delegate callbacks
        nameTextField.delegate = self
        nameEnglishTextField.delegate = self
    }
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    // function is called when user hits search button
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // lowercase user's input
        let userInput: String = textField.text!.lowercased()
        
        //wait for words struct to be loaded
        DispatchQueue.global(qos: .background).async {
            while(self.words == nil) {
                usleep(100000)
            }
    // if user inputted to latin text field
    if(textField == self.nameTextField) {
        outText = ""
    // iterate through words struct for match to user input
    for word in self.words! {
        if(word.base_forms != nil) {
            for principalPart in word.base_forms! {
                if principalPart == userInput {
                    outText += "Principal Parts:  "
                    for part in word.base_forms! {
                        if(part != nil) {
                            outText += part! + ", "
                        }
                    }
                    // format the string to be output
                    outText += "\n\n"
                    if(word.declension != nil) {
                        outText += "Declension:  " + String(word.declension!) + "\n\n"
                    }
                    if(word.conjugation != nil) {
                        outText += "Conjugation:  " + String(word.conjugation!) + "\n\n"
                    }
                    if(word.definition != nil) {
                        outText += "Definition:  " + word.definition! + "\n\n"
                    }
                    if(word.type?.value != nil) {
                        outText += "Class: " + word.type!.value! + "\n\n"
                    }
                    if(word.gender?.value != nil) {
                        outText += "Gender:  " + word.gender!.value! + "\n"
                    }
                    outText += "---------\n"
                    }
                }
            }
        }
        // go to main thread to output string to ui
        DispatchQueue.main.async {
            self.nameOutput.text = outText
    }
    }
    // if user inputted to English text field
    if(textField == self.nameEnglishTextField) {
        outText = ""
        // iterate over words struct for a match in the defintion to user's input
        for word in self.words! {
            if(word.definition != nil) {
                if word.definition!.contains(userInput) {
                    outText += "Principal Parts:  "
                    for part in word.base_forms! {
                        if(part != nil) {
                            outText += part! + ", "
                        }
                    }
                    // format the string to be output
                    outText += "\n\n"
                    if(word.declension != nil) {
                        outText += "Declension:  " + String(word.declension!) + "\n\n"
                    }
                    if(word.conjugation != nil) {
                        outText += "Conjugation:  " + String(word.conjugation!) + "\n\n"
                    }
                    if(word.definition != nil) {
                        outText += "Definition:  " + word.definition! + "\n\n"
                    }
                    if(word.type?.value != nil) {
                        outText += "Class: " + word.type!.value! + "\n\n"
                    }
                    if(word.gender?.value != nil) {
                        outText += "Gender:  " + word.gender!.value! + "\n"
                    }
                    outText += "---------\n"
                }
            }
        }
        // go to main thread to output string to ui
        DispatchQueue.main.async {
            self.nameOutput.text = outText
        }
            }
            
        }
    }
}

