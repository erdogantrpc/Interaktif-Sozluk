//
//  Fikir.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 3.03.2021.
//

import Foundation
import Firebase

class Fikir {
    
    private(set) var kullaniciAdi : String!
    private(set) var eklenmeTarihi : Date!
    private(set) var fikirText : String!
    private(set) var yorumSayisi : Int!
    private(set) var begeniSayisi : Int!
    private(set) var documentId : String!
    private(set) var kullaniciId : String!
    
    init(kullaniciAdi : String, eklenmeTarihi : Date, fikirText : String, yorumSayisi : Int, begeniSayisi : Int, documentId : String, kullaniciId : String) {
        self.kullaniciAdi = kullaniciAdi
        self.eklenmeTarihi = eklenmeTarihi
        self.fikirText = fikirText
        self.yorumSayisi = yorumSayisi
        self.begeniSayisi = begeniSayisi
        self.documentId = documentId
        self.kullaniciId = kullaniciId
    }
    
    class func fikirGetir(snapshot : QuerySnapshot?, begeniyeGoreSirala : Bool = false, yorumaGoreSirala : Bool = false) -> [Fikir] {
        
        var fikirler = [Fikir]()
        guard let snap = snapshot else { return fikirler }
        for document in snap.documents {
            let data = document.data()
            
            let kullaniciAdi = data[Kullanici_Adi] as? String ?? "Misafir"
            let timeStamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
            let eklenmeTarihi = timeStamp.dateValue()
            let fikirText = data[Fikir_Text] as? String ?? ""
            let yorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
            let begeniSayisi = data[Begeni_Sayisi] as? Int ?? 0
            let kullaniciId = data[KULLANICI_ID] as? String ?? ""
            let documentId = document.documentID
            
            
            let yeniFikir = Fikir(kullaniciAdi: kullaniciAdi, eklenmeTarihi: eklenmeTarihi, fikirText: fikirText, yorumSayisi: yorumSayisi, begeniSayisi: begeniSayisi, documentId: documentId, kullaniciId: kullaniciId)
            fikirler.append(yeniFikir)
        }
        
        if begeniyeGoreSirala {
            fikirler.sort { $0.begeniSayisi > $1.begeniSayisi}
        }
        if yorumaGoreSirala {
            fikirler.sort { $0.yorumSayisi > $1.yorumSayisi}
        }
        return fikirler
    }
    
}
