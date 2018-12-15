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
        print("w2l42i3\(sender.userInfo!)")
        
        
        if let keyBoardHeight = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]as? NSValue)?.cgRectValue.size.height
        {
            
            print("鍵盤高度\(keyBoardShow)")
            
            //計算可視高度(底view - 鍵盤高度)
            let visiableHeight = self.view.frame.height - keyBoardHeight
            
            
            //如果Y軸『底緣位置』 比 『可視高度』 還高。表示輸入元件被鍵盤遮住
            if  currentObjectBottomYposion > visiableHeight
            {
                //移動『Y軸底緣位置』與『可視高度』之間的差值
                self.view.frame.origin.y -= currentObjectBottomYposion - visiableHeight + 10
                
            }
            
        }
        
        
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
        
        
    }
    
}
