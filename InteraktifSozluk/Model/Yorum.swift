//
//  Yorum.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 7.03.2021.
//

import Foundation
import Firebase

class Yorum {
    
    private(set) var kullaniciAdi : String!
    private(set) var eklenmeTarihi : Date!
    private(set) var yorumText : String!
    private(set) var documentId : String!
    private(set) var kullaniciId : String!
    
    init(kullaniciAdi : String, eklenmeTarihi : Date, yorumText : String, documentId : String, kullaniciId : String) {
        self.kullaniciAdi = kullaniciAdi
        self.eklenmeTarihi = eklenmeTarihi
        self.yorumText = yorumText
        self.documentId = documentId
        self.kullaniciId = kullaniciId
    }
    
    class func yorumlariGetir(snapshot : QuerySnapshot?) -> [Yorum] {
        var yorumlar = [Yorum]()
        
        guard let snap = snapshot else {return yorumlar}
        
        for kayit in snap.documents {
            let veri = kayit.data()
            let kullaniciAdi = veri[KULLANICI_ADI] as? String ?? "Misafir"
            let ts = veri[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
            let eklenmeTarihi = ts.dateValue()
            let yorumText = veri[YORUM_TEXT] as? String ?? "Yorum yok."
            let documentId = kayit.documentID
            let kullaniciId = veri[KULLANICI_ID] as? String ?? ""
            
            let yeniYorum = Yorum(kullaniciAdi: kullaniciAdi, eklenmeTarihi: eklenmeTarihi, yorumText: yorumText, documentId: documentId, kullaniciId: kullaniciId)
            yorumlar.append(yeniYorum)
        }
        
        
        return yorumlar
    }
    
    
}
