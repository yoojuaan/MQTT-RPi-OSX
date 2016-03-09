//
//  SettingsViewController.swift
//  MQTT-RPi-OSX
//
//  Created by Juan Hernandez on 7/3/16.
//  Copyright © 2016 Juan Hernandez. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet var backgroundView: NSView!
    @IBOutlet weak var serverTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var userTextField: NSTextField!
    @IBOutlet weak var pwdTextField: NSSecureTextField!
    @IBOutlet weak var topicSelect: NSPopUpButton!
    @IBOutlet weak var buttonTest: NSButton!
    @IBOutlet weak var addTopicTextField: NSTextField!
    
    var topicStrings:[String] = ["GPIO", "depto/living", "depto/cocina", "depto/cuarto", "depto/bano"]
    var indexTopic = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topicSelect.removeAllItems()
        topicSelect.addItemsWithTitles(topicStrings)
        
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceServerText") != nil{
            serverTextField.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferenceServerText")!
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferencePortText") != nil{
            portTextField.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferencePortText")!
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceUserText") != nil{
            userTextField.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferenceUserText")!
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceTopicText") != nil{
            topicSelect.selectItemWithTitle(NSUserDefaults.standardUserDefaults().stringForKey("preferenceTopicText")!)
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferencePwdText") != nil{
            pwdTextField.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferencePwdText")!
        }
        
    }
    
    override func viewDidAppear() {
        if NSUserDefaults.standardUserDefaults().arrayForKey("preferenceArrayTopicStrings") != nil {
            //topicStrings = NSUserDefaults.standardUserDefaults().arrayForKey("preferenceArrayTopicStrings")
        }
        
    }

    @IBAction func serverEndEditing(sender: NSTextField) {
        let serverText = serverTextField.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(serverText, forKey: "preferenceServerText")
        NSUserDefaults.standardUserDefaults().synchronize()
    }    
    @IBAction func portEditingEnd(sender: NSTextField) {
        let portText = portTextField.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(portText, forKey: "preferencePortText")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    @IBAction func userEndEditing(sender: NSTextField) {
        let userText = userTextField.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(userText, forKey: "preferenceUserText")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    @IBAction func pwdEndEditing(sender: NSSecureTextField) {
        let pwdText = pwdTextField.stringValue;
        NSUserDefaults.standardUserDefaults().setObject(pwdText, forKey: "preferencePwdText")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func addTopicEndEditing(sender: NSTextField) {
        let newTopic = addTopicTextField.stringValue
        if newTopic != ""{
            topicStrings.append(newTopic)
            topicSelect.addItemsWithTitles(topicStrings)
            NSUserDefaults.standardUserDefaults().setObject(topicStrings, forKey: "preferenceArrayTopicStrings")
            NSUserDefaults.standardUserDefaults().synchronize()
            addTopicTextField.hidden = true
            addTopicTextField.stringValue = ""
        }else{
            addTopicTextField.hidden = true
        }
    }
    
    @IBAction func clickAcceptButton(sender: NSButton) {
        
    }
    
    @IBAction func clickAddButton(sender: NSButton) {
        addTopicTextField.hidden = false
        addTopicTextField.becomeFirstResponder()
    }
    @IBAction func clickRemoveButton(sender: NSButton) {
        if indexTopic < topicStrings.count{
            topicStrings.removeAtIndex(indexTopic)
            topicSelect.removeAllItems()
            topicSelect.addItemsWithTitles(topicStrings)
            //NSUserDefaults.standardUserDefaults().setObject(topicStrings, forKey: "preferenceArrayTopicStrings")
            //NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    @IBAction func clickSelectTopic(sender: NSPopUpButton) {
        var text = ""
        text = topicSelect.titleOfSelectedItem!
        NSUserDefaults.standardUserDefaults().setObject(text, forKey: "preferenceTopicText")
        NSUserDefaults.standardUserDefaults().synchronize()
        indexTopic = topicSelect.indexOfSelectedItem
    }
    
    
}
