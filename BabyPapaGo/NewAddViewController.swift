//
//  NewAddViewController.swift
//  BabyPapaGo
//
//  Created by Yung on 2018/12/13.
//  Copyright © 2018 Yung. All rights reserved.
//

import UIKit
import SQLite3

class NewAddViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    @IBOutlet weak var newName: UITextField!
    @IBOutlet weak var newPhone: UITextField!
    @IBOutlet weak var newAddress: UITextField!
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var newListName: UITextField!
    
    
    
    var db:OpaquePointer?
    
    var currentObjectBottomYposion:CGFloat = 0
    
    var NewMaTableViewController:MamaTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let delegate = UIApplication.shared.delegate as? AppDelegate
        {
            db = delegate.db
            
        }
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHie), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - 自訂函式   鍵盤彈出通知(配合擋住輸入框時)
    
    @objc func keyBoardShow(_ sender:Notification)
    {
        
        
        
        if let keyBoardHeight = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]as? NSValue)?.cgRectValue.size.height
        {
            
            print("鍵盤高度\(keyBoardShow)")
            
            //計算可視高度(底view - 鍵盤高度)
            let visiableHeight = self.view.frame.height - keyBoardHeight
            
            
            //如果Y軸『底緣位置』 比 『可視高度』 還高。表示輸入元件被鍵盤遮住
            if  currentObjectBottomYposion > visiableHeight
            {
                //移動『Y軸底緣位置』與『可視高度』之間的差值
                self.view.frame.origin.y -= currentObjectBottomYposion - visiableHeight + 15
                
            }
            
        }
        
        
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        print("影像挑選：\(info)")
        //取得選定的照片（包含相機與相簿）
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        newImage.contentMode = .scaleAspectFill
        newImage.clipsToBounds = true
        
        newImage.layer.cornerRadius = newImage.layer.frame.size.width / 2
        
        //將照片顯示在大頭照位置
        newImage.image = image
        //退掉影像挑選控制器的畫面
        picker.dismiss(animated: true, completion: nil)
    }
    
    //鍵盤彈出時 由通知中心呼叫的函式
    @objc func keyBoardWillHie()
    {
        print("鍵盤收合")
        
        //將底層的View做歸位
        self.view.frame.origin.y = 0
    }
    
    //MARK: - 自訂手勢
    //觸碰開始/結束
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func didEnd(_ sender: UITextField)
    {
        print("點擊到囉 開始編輯")
        
    }
    
    @IBAction func didBegin(_ sender: UITextField)
    {
        currentObjectBottomYposion = sender.frame.origin.y + sender.frame.height
        
        switch sender.tag {
        case 1:
            sender.keyboardType = .namePhonePad
        case 2:
            sender.keyboardType = .phonePad
        case 3:
            sender.keyboardType = .namePhonePad
        case 4:
            sender.keyboardType = .namePhonePad
        default:
            sender.keyboardType = .default
        }
        
    }
    @IBAction func getPhoto(_ sender: UIButton)
    {
        ///初始化影像挑選控制器()
        let imagepicker = UIImagePickerController()
        
        //設定影像挑選控制器為{相簿}
        imagepicker.sourceType = .photoLibrary
        
        //指定影像挑選控制器相關代理事件 實做在此類別
        imagepicker.delegate = self
        
        //選中相片後 放上ImageView
        self.show(imagepicker, sender: nil)
        
    }

    @IBAction func addInDataBase(_ sender: UIButton)
    {
        if newName.text! == "" || newAddress.text! == "" || newPhone.text! == "" || newListName.text! == ""
        {
            let alert = UIAlertController(title: "輸入錯誤", message: "資料不可為空白！", preferredStyle: .alert)
            //在訊息視窗加上一個按鈕
            alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: nil))
            //顯示訊息視窗
            self.present(alert, animated: true, completion: nil)
            
            
            //直接離開函式
            return
        }
        
        //檢查有無照片
        if newImage.image == nil
        {
            let alert = UIAlertController(title: "缺少大頭照", message: "尚未上傳照片！", preferredStyle: .alert)
            //在訊息視窗加上一個按鈕
            alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: nil))
            //顯示訊息視窗
            self.present(alert, animated: true, completion: nil)
            
            
            //直接離開函式
            return
            
        }
            
        
        if db != nil
        {
            let sql = "insert into BabypapaList(name,listname,address,phone,picture) values('\(newName.text!)','\(newListName.text!)',\(newAddress.text!),\(newPhone.text!),'?')"
            
            print("更新指令\(sql)")
            
            //將SQL指令轉為Ｃ語言
            let cSql = sql.cString(using: .utf8)
            
            //宣告儲存執行結果
            var statament:OpaquePointer?
            
            sqlite3_prepare_v3(db, cSql, -1, 0, &statament, nil)
            
            //先準備圖檔資訊
            //先準備圖檔資訊
            let imageData = newImage.image!.jpegData(compressionQuality: 0.8)!
            
            
            //綁定更新指令 所在的圖檔
            sqlite3_bind_blob(statament, 4, (imageData as NSData).bytes, Int32(imageData.count), nil)
            
            if sqlite3_step(statament) == SQLITE_DONE
            {
                //==================回寫上一頁的離線資料====================
                //Step1.先準備要新增的一本字典
                let newRow:[String:Any?] = ["name":newName.text!,"picture":imageData,"phone":newPhone.text!,"address":newAddress.text!,]
//                //Step2.決定新字典回寫上一頁的離線資料的位置
//                for (index,item) in NewMaTableViewController.arrTable.enumerated()
//                {
//                    //如果現在當筆離線資料的學號，已經比新增的學號資料還大，則將新資料安插在此
//                    if txtNo.text! < (item["no"]! as! String)
//                    {
//                        myTableViewController.arrTable.insert(newRow, at: index)
//                        break
//                    }
                let alert = UIAlertController(title: "資料庫訊息", message: "資料新增成功", preferredStyle: .alert)
                
                
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            sqlite3_finalize(statament)
            
        }
        
        
    }
    
}
