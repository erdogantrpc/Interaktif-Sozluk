//
//  Uzantilar.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 14.03.2021.
//

import Foundation
import Firebase

extension Query {
    func yeniWhereSorgusu() -> Query {
        let tarihVeriler = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        guard let bugun = Calendar.current.date(from: tarihVeriler),
              let bitis = Calendar.current.date(byAdding: .hour, value: 24 ,to: bugun) else {
            fatalError("Belirtilen Tarih Aralıklarında Herhangi Bir Kayıt Bulunamadı")
        }
        return whereField(Eklenme_Tarihi, isLessThanOrEqualTo: bitis).whereField(Eklenme_Tarihi, isGreaterThanOrEqualTo: bugun).limit(to: 30)
    }
}
