//
//  YorumDuzenleVC.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 14.03.2021.
//

import UIKit
import Firebase

class YorumDuzenleVC: UIViewController {

    @IBOutlet weak var txtYorum: UITextView!
    @IBOutlet weak var btnGuncelle: UIButton!
    
    var yorumVerisi : (secilenYorum : Yorum, secilenFikir : Fikir)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtYorum.layer.cornerRadius = 10
        btnGuncelle.layer.cornerRadius = 10
        
        txtYorum.text = yorumVerisi.secilenYorum.yorumText!
    }
    
    @IBAction func btnGuncellePressed(_ sender: Any) {
        guard let yorumText = txtYorum.text, txtYorum.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else {return}
        
        Firestore.firestore().collection(Fikirler_REF)
            .document(yorumVerisi.secilenFikir.documentId)
            .collection(YORUMLAR_REF)
            .document(yorumVerisi.secilenYorum.documentId)
            .updateData([YORUM_TEXT : yorumText]) { (hata) in
                if let hata = hata {
                    debugPrint("Yorum güncellenirken bir hata meydana geldi : \(hata.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
}
