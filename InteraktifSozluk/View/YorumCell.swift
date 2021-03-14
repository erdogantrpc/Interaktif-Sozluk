//
//  YorumCell.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 7.03.2021.
//

import UIKit
import Firebase

class YorumCell: UITableViewCell {

    
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    @IBOutlet weak var lblTarih: UILabel!
    @IBOutlet weak var lblYorum: UILabel!
    @IBOutlet weak var imgSecenekler: UIImageView!
    
    var delegate : YorumDelegate?
    var secilenYorum : Yorum!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func gorunumAyarla(yorum : Yorum, delegate : YorumDelegate?) {
        lblKullaniciAdi.text = yorum.kullaniciAdi
        lblYorum.text = yorum.yorumText
        let tarihFormat = DateFormatter()
        tarihFormat.dateFormat = "dd.MM.YYYY, hh:mm"
        let eklenmeTarihi = tarihFormat.string(from: yorum.eklenmeTarihi)
        lblTarih.text = eklenmeTarihi
        
        secilenYorum = yorum
        self.delegate = delegate
        imgSecenekler.isHidden = true
        if yorum.kullaniciId == Auth.auth().currentUser?.uid {
            imgSecenekler.isHidden = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgYorumSeceneklerPressed))
            imgSecenekler.isUserInteractionEnabled = true
            imgSecenekler.addGestureRecognizer(tap)
        }
    }
    
    @objc func imgYorumSeceneklerPressed() {
        delegate?.seceneklerYorumPressed(yorum: secilenYorum)
    }


}

protocol YorumDelegate {
    func seceneklerYorumPressed(yorum : Yorum)
}
