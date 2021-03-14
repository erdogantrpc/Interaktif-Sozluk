//
//  FikirCell.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 3.03.2021.
//

import UIKit
import Firebase

class FikirCell: UITableViewCell {

    @IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var lblEklenmeTarihi: UILabel!
    @IBOutlet weak var lblFikirText: UILabel!
    @IBOutlet weak var lblBegeniSayisi: UILabel!
    @IBOutlet weak var imgBegeni: UIImageView!
    @IBOutlet weak var lblYorumSayisi: UILabel!
    @IBOutlet weak var imgSecenekler: UIImageView!
    
    var secilenFikir : Fikir!
    var delegate : FikirDelegate?
    let fireStore = Firestore.firestore()
    var begeniler = [Begeni]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgBegeni.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgBegeniTapped))
        imgBegeni.addGestureRecognizer(tap)
    }
    
    func begenileriGetir() {
        let begeniSorgu = fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId).collection(BEGENI_REF)
            .whereField(KULLANICI_ID, isEqualTo: Auth.auth().currentUser?.uid ?? "")
        
        begeniSorgu.getDocuments { (snapshot, hata) in
            self.begeniler = Begeni.begenileriGetir(snapshot: snapshot)
            
            if self.begeniler.count > 0 {
                self.imgBegeni.image = UIImage(named: "yildizRenkli")
            } else {
                self.imgBegeni.image = UIImage(named: "yildizTransparan")
            }
            
        }
        
    }
    
    @objc func imgBegeniTapped() {
        
        fireStore.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let secilenFikirKayit : DocumentSnapshot
            do {
                try secilenFikirKayit = transaction.getDocument(self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId))
            } catch let hata as NSError {
                debugPrint("Begeni işleminda hata meydana geldi : \(hata.localizedDescription)")
                return nil
            }
            
            guard let eskiBegeniSayisi = (secilenFikirKayit.data()?[Begeni_Sayisi] as? Int) else {return nil}
            let secilenFikirRef = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId)
            
            if self.begeniler.count > 0 {
                //Kullanıcı daha önce beğenmiş
                transaction.updateData([Begeni_Sayisi : eskiBegeniSayisi-1], forDocument: secilenFikirRef)
                
                let eskiBegeniRef = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId).collection(BEGENI_REF)
                    .document(self.begeniler[0].documentId)
                transaction.deleteDocument(eskiBegeniRef)
            } else {
                //Kullanıcı daha önce beğenmemiş
                transaction.updateData([Begeni_Sayisi : eskiBegeniSayisi+1], forDocument: secilenFikirRef)
                
                let yeniBegeniRef = self.fireStore.collection(Fikirler_REF).document(self.secilenFikir.documentId).collection(BEGENI_REF).document()
                transaction.setData([KULLANICI_ID : Auth.auth().currentUser?.uid ?? "" ], forDocument: yeniBegeniRef)
                
            }
            
            return nil
        }) { (nesne, hata) in
            if let hata = hata {
                debugPrint("Beğenilerde bir hata meydana geldi : \(hata.localizedDescription)")
            }
        }
        
    }
    
    func gorunumAyarla(fikir : Fikir, delegate : FikirDelegate?) {
        secilenFikir = fikir
        lblKullaniciAdi.text = fikir.kullaniciAdi
        lblFikirText.text = fikir.fikirText
        lblBegeniSayisi.text = "\(fikir.begeniSayisi ?? 0)"
        
        let tarihFormat = DateFormatter()
        tarihFormat.dateFormat = "dd.MM.YYYY, hh:mm"
        let eklenmeTarihi = tarihFormat.string(from: fikir.eklenmeTarihi)
        lblEklenmeTarihi.text = eklenmeTarihi
        lblYorumSayisi.text = "\(fikir.yorumSayisi ?? 0)"
        
        imgSecenekler.isHidden = true
        self.delegate = delegate
        
        if fikir.kullaniciId == Auth.auth().currentUser?.uid {
            imgSecenekler.isHidden = false
            imgSecenekler.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgFikirSeceneklerPressed))
            imgSecenekler.addGestureRecognizer(tap)
        }
        
        begenileriGetir()
    }
    
    @objc func imgFikirSeceneklerPressed() {
        delegate?.seceneklerFikirPressed(fikir: secilenFikir)
    }


}
protocol FikirDelegate {
    func seceneklerFikirPressed(fikir : Fikir)
}
