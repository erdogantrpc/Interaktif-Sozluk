//
//  GirisVC.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 7.03.2021.
//

import UIKit
import Firebase

class GirisVC: UIViewController {

    @IBOutlet weak var txtEmailAdresi: UITextField!
    @IBOutlet weak var txtParola: UITextField!
    @IBOutlet weak var btnGirisYap: UIButton!
    @IBOutlet weak var btnHesapOlustur: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnGirisYap.layer.cornerRadius = 10
        btnHesapOlustur.layer.cornerRadius = 10
  
    }
    
    @IBAction func btnGirisYapPressed(_ sender: Any) {
        guard let emailAdresi = txtEmailAdresi.text,
              let parola = txtParola.text else {return}
        
        Auth.auth().signIn(withEmail: emailAdresi, password: parola) { (kullanici, hata) in
            if let hata = hata {
                debugPrint("Oturum açılırken hata meydana geldi :  \(hata.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
}
