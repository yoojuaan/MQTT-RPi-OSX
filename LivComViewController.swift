//
//  LivComViewController.swift
//  MQTT-RPi-OSX
//
//  Created by Juan Hernandez on 7/3/16.
//  Copyright © 2016 Juan Hernandez. All rights reserved.
//

import Cocoa
import CocoaMQTT


class LivComViewController: NSViewController {

    @IBOutlet weak var serverTextView: NSTextField!
    @IBOutlet weak var portTextView: NSTextField!
    @IBOutlet weak var userTextView: NSTextField!
    @IBOutlet weak var topicTextView: NSTextField!
    @IBOutlet weak var stateTextView: NSTextField!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var comTextView: NSTextField!
    @IBOutlet weak var livTextView: NSTextField!
    @IBOutlet weak var comButton: NSButton!
    @IBOutlet weak var livButton: NSButton!
    
    var mqtt: CocoaMQTT?
    var stateConnection:Bool = false
    var stateCom:Bool = false
    var stateLiv:Bool = false
    
    var pwdText:String = ""
    var serverText:String = ""
    var topicText:String = ""
    var portInt:Int = 1883
    var portText:UInt16 = 1883
    var userText:String = ""
    
    
    //---------------------------------------------------------------------------------//
    //---------------------------------Funcion-de-Arranque-----------------------------//
    //---------------------------------------------------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateCom = false
        stateLiv = false
        mqttSettings()
    }
    
    //---------------------------------------------------------------------------------//
    //----------------------------------Funcion-onResume-------------------------------//
    //---------------------------------------------------------------------------------//
    
    override func viewDidAppear() {
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceServerText") != nil{
            serverTextView.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferenceServerText")!
            serverText = serverTextView.stringValue
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferencePortText") != nil{
            portTextView.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferencePortText")!
            portInt = Int(portTextView.stringValue)!
            portText = UInt16(portInt)
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceUserText") != nil{
            userTextView.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferenceUserText")!
            userText = userTextView.stringValue
        }
        if NSUserDefaults.standardUserDefaults().stringForKey("preferenceTopicText") != nil{
            topicTextView.stringValue = NSUserDefaults.standardUserDefaults().stringForKey("preferenceTopicText")!
            topicText = topicTextView.stringValue
        }
    }
    
    //---------------------------------------------------------------------------------//
    //---------------------------Funcion-MQTTConnect/Disconnect------------------------//
    //---------------------------------------------------------------------------------//
    
    func Connect(){
        if stateConnection == false{
            pwdText = NSUserDefaults.standardUserDefaults().stringForKey("preferencePwdText")!
            mqttSettings()
            mqtt!.connect()
            stateTextView.stringValue = "Conectado al Broker"
            connectButton.title = "Desconectar"
            stateConnection = true
        }
        else{
            mqtt!.disconnect()
            stateTextView.stringValue = "Desconectado"
            connectButton.title = "Conectar"
            stateConnection = false
        }
    }
    
    //---------------------------------------------------------------------------------//
    //-----------------------------------Enviar-Mensaje--------------------------------//
    //---------------------------------------------------------------------------------//
    
    func sendMessage(mensaje:String){
        let message = mensaje
        mqtt?.publish(topicText, withString: message, qos: .QOS1)
    }
    
    //---------------------------------------------------------------------------------//
    //--------------------------------Funcion-MQTTSettings-----------------------------//
    //---------------------------------------------------------------------------------//
    
    func mqttSettings(){
        let clientIdPid = "newClient"
        mqtt = CocoaMQTT(clientId: clientIdPid, host: serverText, port: portText)
        if let mqtt = mqtt {
            mqtt.username = userText
            mqtt.password = pwdText
            mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieut")
            mqtt.keepAlive = 90
            mqtt.delegate = self;
        }
    }
    
    //---------------------------------------------------------------------------------//
    //------------------------------Funcion-ConnectionAlert----------------------------//
    //---------------------------------------------------------------------------------//
    
    func connectionAlert(){
        let alert = NSAlert()
        alert.messageText = "Servidor Desconecado"
        alert.informativeText = "Por favor conecte al servidor primero."
        alert.addButtonWithTitle("Conectar")
        alert.addButtonWithTitle("Cancelar")
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.icon = NSImage(named: "NSCaution")
        
        
        
        alert.beginSheetModalForWindow(self.view .window!, completionHandler: { [unowned self] (returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn {
                self.Connect()
            }
            })
        
    }
    
    //---------------------------------------------------------------------------------//
    //--------------------------------Accion-de-los-Botones----------------------------//
    //---------------------------------------------------------------------------------//

    //--------------------------Boton-Conectar--------------------------//
    
    @IBAction func clickConnectButton(sender: NSButton) {
        Connect()
    }
    
    //--------------------------Boton-Comedor--------------------------//
    
    @IBAction func clickComButton(sender: NSButton) {
        if(stateConnection){
            if(stateCom){
                self.sendMessage("comedoroff")
                comTextView.stringValue = "Comedor Apagado"
                comButton.image = NSImage(named: "foco_n")
                stateCom = false
            }else{
                self.sendMessage("comedoron")
                comTextView.stringValue = "Comedor Encendido"
                comButton.image = NSImage(named: "foco_a")
                stateCom = true
            }
        }else{
            connectionAlert()
        }
    }
    
    //--------------------------Boton-Living--------------------------//
    
    @IBAction func clickLivButton(sender: NSButton) {
        if(stateConnection){
            if(stateLiv){
                self.sendMessage("livingoff")
                livTextView.stringValue = "Living Apagado"
                livButton.image = NSImage(named: "foco_n")
                stateLiv = false
            }else{
                self.sendMessage("livingon")
                livTextView.stringValue = "Living Encendido"
                livButton.image = NSImage(named: "foco_a")
                stateLiv = true
            }
        }else{
            //TODO: Alert
        }
    }
}

//---------------------------------------------------------------------------------//
//------------------------------Extension CocoaDelegate----------------------------//
//---------------------------------------------------------------------------------//

extension LivComViewController: CocoaMQTTDelegate {
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int){
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck){
        if ack == .ACCEPT{
            mqtt.subscribe("GPIO", qos: CocoaMQTTQOS.QOS1)
            mqtt.ping()
        }
    }
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string) with id \(id)")
        NSNotificationCenter.defaultCenter().postNotificationName("MQTTMessageNotification", object: self, userInfo: ["message": message.string!, "topic": message.topic])
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect")
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }
    
}