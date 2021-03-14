//
//  ViewController.swift
//  InteraktifSozluk
//
//  Created by Erdogan Turpcu on 24.02.2021.
//

import UIKit
import Firebase

class AnaVC: UIViewController {

    @IBOutlet weak var sgmntKategoriler: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var fikirler = [Fikir]()
    private var fikirlerCollectionRef : CollectionReference!
    private var fikirlerListener : ListenerRegistration!
    private var secilenKategori = Kategoriler.Eglence.rawValue
    private var listenerHandle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        tableView.delegate = self
        tableView.dataSource = self
        
        fikirlerCollectionRef = Firestore.firestore().collection(Fikirler_REF)

    }

    override func viewWillAppear(_ animated: Bool) {
        listenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let girisVC = storyboard.instantiateViewController(identifier: "GirisVC")
                girisVC.modalPresentationStyle = .fullScreen
                self.present(girisVC, animated: true, completion: nil)
            } else {
                self.setListener()
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Sayfa değiştiğinde sunucuyu dinlemeye devam etmesin
        if fikirlerListener != nil {
            fikirlerListener.remove()
        }
    }
    
    func setListener() {
        
        if secilenKategori == Kategoriler.Populer.rawValue {
            fikirlerListener = fikirlerCollectionRef.yeniWhereSorgusu()
                .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    debugPrint("Kayıtları getirirken bir hata oluştu : \(error.localizedDescription)")
                } else {
                    self.fikirler.removeAll(keepingCapacity: false)
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot, begeniyeGoreSirala: true)
                    self.tableView.reloadData()
                }
            }
        } else {
            fikirlerListener = fikirlerCollectionRef
                .whereField(KATEGORI, isEqualTo: secilenKategori)
                .order(by: Eklenme_Tarihi, descending: true)
                .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    debugPrint("Kayıtları getirirken bir hata oluştu : \(error.localizedDescription)")
                } else {
                    self.fikirler.removeAll(keepingCapacity: false)
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func kategoriChanged(_ sender: Any) {
        switch sgmntKategoriler.selectedSegmentIndex {
        case 0 :
            secilenKategori = Kategoriler.Eglence.rawValue
        case 1 :
            secilenKategori = Kategoriler.Absurt.rawValue
        case 2 :
            secilenKategori = Kategoriler.Gundem.rawValue
        case 3:
            secilenKategori = Kategoriler.Populer.rawValue
        default :
            secilenKategori = Kategoriler.Eglence.rawValue
        }
        fikirlerListener.remove()
        setListener()
    }
    
    @IBAction func btnOturumKapatPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let oturumHatasi as NSError {
            debugPrint("Oturum kapatılırken hata meydana geldi : \(oturumHatasi.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "YorumlarSegue" {
            if let hedefVC = segue.destination as? YorumlarVC {
                if let secilenFikir = sender as? Fikir {
                    hedefVC.secilenFikir = secilenFikir
                }
            }
        }
    }
    
}

extension AnaVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fikirler.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FikirCell", for: indexPath) as? FikirCell {
            cell.gorunumAyarla(fikir: fikirler[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "YorumlarSegue", sender: fikirler[indexPath.row])
    }
}

extension AnaVC : FikirDelegate {
    func seceneklerFikirPressed(fikir: Fikir) {
        let alert = UIAlertController(title: "Sil", message: "Paylaşımınızı silmek mi istiyorsunuz?", preferredStyle: .actionSheet)
        
        let silAction = UIAlertAction(title: "Sil", style: .default) { (action) in
            let yorumlarCollRef = Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).collection(YORUMLAR_REF)
            let begeniCollRef = Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).collection(BEGENI_REF)
            
            self.topluKayitSil(collectionRef: begeniCollRef, completion: { (hata) in
                if let hata = hata {
                    debugPrint("Beğeniler silinirken bir hata meydana geldi : \(hata.localizedDescription)")
                } else {
                    self.topluKayitSil(collectionRef: yorumlarCollRef, completion: { (hata) in
                        if let hata = hata {
                            debugPrint("Fikre Ait Yorumlar Silinirlen Hata Meydana Geldi : \(hata.localizedDescription)")
                        } else {
                            Firestore.firestore().collection(Fikirler_REF).document(fikir.documentId).delete { (hata) in
                                if let hata = hata {
                                    debugPrint("Fikir Silinirken Hata Meydana Geldi : \(hata.localizedDescription)")
                                } else {
                                    alert.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    })
                }
            })
            
            
        }
        
        let iptalAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        alert.addAction(silAction)
        alert.addAction(iptalAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func topluKayitSil(collectionRef : CollectionReference, silinecekKayitSayisi : Int = 100, completion : @escaping (Error?) -> ()) {
        collectionRef.limit(to: silinecekKayitSayisi).getDocuments{ (kayitSetleri, hata) in
            guard let kayitSetleri = kayitSetleri else {
                completion(hata)
                return
            }
            guard kayitSetleri.count > 0 else {
                completion(nil)
                return
            }
            
            let batch = collectionRef.firestore.batch()
            kayitSetleri.documents.forEach { batch.deleteDocument($0.reference)}
            batch.commit { (batchHata) in
                if let hata = batchHata {
                    completion(hata)
                } else {
                    self.topluKayitSil(collectionRef: collectionRef, silinecekKayitSayisi: silinecekKayitSayisi, completion: completion)
                }
    
            }
            
        }
    }
    
}

