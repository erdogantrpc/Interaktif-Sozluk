//
//  KullaniciOlusturVC.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 7.03.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class KullaniciOlusturVC: UIViewController {

    @IBOutlet weak var txtEmailAdresi: UITextField!
    @IBOutlet weak var txtParola: UITextField!
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    @IBOutlet weak var btnHesapOlustur: UIButton!
    @IBOutlet weak var btnVazgec: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnHesapOlustur.layer.cornerRadius = 10
        btnVazgec.layer.cornerRadius = 10

        
    }
    

    @IBAction func btnHesapOlusturPressed(_ sender: Any) {
        guard let emailAdresi = txtEmailAdresi.text,
              let parola = txtParola.text,
              let kullaniciAdi = txtKullaniciAdi.text else {return}
    
        Auth.auth().createUser(withEmail: emailAdresi, password: parola) { (kullaniciBilgileri, hata) in
            if let hata = hata {
                debugPrint("Kullanıcı oluşturulurken hata meydana geldi :  \(hata.localizedDescription)")
            }
            
            let changeRequest = kullaniciBilgileri?.user.createProfileChangeRequest()
            changeRequest?.displayName = kullaniciAdi
            changeRequest?.commitChanges(completion: { (hata) in
                if let hata = hata {
                    debugPrint("Kullanıcı Adı güncellenirken hata meydana geldi :  \(hata.localizedDescription)")
                }
            })
            
            guard let kullaniciId = kullaniciBilgileri?.user.uid else {return}
            Firestore.firestore().collection(KULLANICILAR_REF).document(kullaniciId).setData([KULLANICI_ADI : kullaniciAdi, KULLANICI_OLUSTURMA_TARIHI : FieldValue.serverTimestamp()]) { (hata) in
                if let hata = hata {
                    debugPrint("Kullanıcı eklenirken bir hata meydana geldi :  \(hata.localizedDescription)")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            
            
        }
    
    
    }
    
    @IBAction func btnVazgecPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
