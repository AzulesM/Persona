//
//  EthViewController.swift
//  Persona
//
//  Created by Azules on 2018/11/8.
//  Copyright © 2018年 Azules. All rights reserved.
//

import UIKit
import web3swift

class EthViewController: UIViewController {

    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    var web3Rinkeby: web3?
    var bip32Keystore: BIP32Keystore?
    var keystoreManager: KeystoreManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Persona"
        
        createButton.layer.cornerRadius = createButton.frame.size.height / 2.0
                
        web3Rinkeby = Web3.InfuraRinkebyWeb3()
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let path = directory! + "/keystore/"
        keystoreManager =  KeystoreManager.managerForPath(path, scanForHDwallets: true, suffix: "json")
        
        if (keystoreManager?.addresses?.count)! > 0 {
            self.web3Rinkeby?.addKeystoreManager(keystoreManager)
            self.bip32Keystore = keystoreManager?.bip32keystores[0]
            self.updateUI()
        }
    }

    @IBAction func didTapCreateButton() {
        let alert = UIAlertController(title: "Enter Passphrase", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Passphrase"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let create = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            let passphrase = alert.textFields?.first?.text
            
            if let passphrase = passphrase, passphrase != "" {
                Spinner.start()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
                        self?.bip32Keystore = try! BIP32Keystore(mnemonics: mnemonic, password: passphrase, mnemonicsPassword: String(passphrase.reversed()))
                        let keyData = try JSONEncoder().encode(self?.bip32Keystore?.keystoreParams)
                        
                        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                        FileManager.default.createFile(atPath: directory! + "/keystore" + "/key.json", contents: keyData, attributes: nil)
                        
                        guard let _ = self?.bip32Keystore?.addresses?.first else {return}
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.updateUI()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(create)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUI() {
        Spinner.stop()
        addressTitle.text = "Address"
        address.text = self.bip32Keystore?.addresses?.first?.address
        createButton.isHidden = true

        let ethAddress = EthereumAddress(address.text ?? "")
        let balanceBigInt = web3Rinkeby?.eth.getBalance(address: ethAddress!).value
        balance.text = "Ether Balance: \(String(describing: Web3.Utils.formatToEthereumUnits(balanceBigInt ?? 0)!))"
    }

}
