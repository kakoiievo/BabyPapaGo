//
//  MamaTableViewController.swift
//  BabyMaMago
//
//  Created by Yung on 2018/12/6.
//  Copyright © 2018 Yung. All rights reserved.
//




import UIKit
import SQLite3
import CoreLocation
import MapKit


class MamaTableViewController: UITableViewController
{
    
    
    var db:OpaquePointer?
    
    
    var dicRow = [String:Any?]()

    var arrTable = [[String:Any?]]()
    
    //目前被點選的資料列  (用意是點擊到某一個導到下一個頁面 所要先給的變數)
    var currentRow = 0
    
    //4 預設為非搜尋狀態
    var isSearch = false
    //------------------------------------------------------------
    
    var myUserDefaults :UserDefaults!
    var myLocationManager :CLLocationManager!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate
        {
            db = delegate.db
            
        }
        getDataFromTable()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "編輯", style: .plain, target: self, action: #selector(btnEdintAction))
        
        //在導覽列又右側增新增按鈕
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "新增", style: .plain, target: self, action: #selector(btnAddAction))
        
        //設定導覽列的標題
        self.navigationItem.title = "BabyLetsGO"
        
        
        
        //設定導覽列的背景圖片
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "titleImage.png"), for: .default)
        
        
        //============設定下拉更新元件===================
        //為表格增加更新元件
        self.tableView.refreshControl = UIRefreshControl()
        
        //設下下拉更新元件到對應的剛剛的handleRefresh方法
        self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: "更新中...")
        //===============================================
        
    
       
    }
    
    //MARK:- babyDB get in table
    
    func getDataFromTable()
    {
        
        arrTable.removeAll()
        
        currentRow = 0
        
        if db != nil
        {
            
            let sql = "select name,listname,address,phone,picture from BabypapaList"
           
            
            //將sql指令 由swift語言字串 轉換為 Ｃ語言字串(即是字元陣列)
            let cSql = sql.cString(using: .utf8)!
            
            //宣告 儲存查詢結果的變數
            var statement:OpaquePointer?
            
            sqlite3_prepare_v3(db, cSql, -1, 0, &statement, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW
            {
                
                //先清空字典
                dicRow.removeAll()
                //讀取第1欄
                let name  = sqlite3_column_text(statement, 0)
                
                //將第0欄資料由C語言字串 轉換成Swift字串
                let babyName = String(cString: name!)
                dicRow["name"] = babyName
                
                
                let listname  = sqlite3_column_text(statement, 1)
                
                //將第0欄資料由C語言字串 轉換成Swift字串
                let babylistName = String(cString: listname!)
                dicRow["listname"] = babylistName
                
        
                //儲存數位檔案的(第4欄)
                var imageData:Data!
                
                //讀取檔案的位元資料(用於照片或是其他檔案)
                if let totalBytes = sqlite3_column_blob(statement, 4)
                {
                    
                    //讀取檔案長度
                    let fileLength = sqlite3_column_bytes(statement, 4)
                    
                    //將檔案資訊還原成Data
                    imageData = Data(bytes: totalBytes, count: Int(fileLength))
                    
                }
                else
                {
                    let aImage = UIImage(named: "test.jpeg")
                    imageData = aImage?.jpegData(compressionQuality: 0.8)
                    
                }
                dicRow["picture"] = imageData
                
                
                
                let phone = sqlite3_column_text(statement, 3)
                //let strPhone = String(cString: phone!)
                let babyPhone = String(cString: phone!)
                dicRow["phone"] = babyPhone
                
                let address = sqlite3_column_text(statement, 2)
                let strAddress = String(cString: address!)
                dicRow["address"] = strAddress
                
               
                //將當筆字典存入到陣列。arrTable！！！
                arrTable.append(dicRow)
            }
           print(arrTable)
            sqlite3_finalize(statement)
        }
        
        
        
        
    }
    
    
    // MARK: - 自定義函式
    //由導覽列的編輯按鈕呼叫
    @objc func btnEdintAction()
    {
        if !self.tableView.isEditing  //如果表格不在編輯狀態
        {
            self.tableView.isEditing = true //進入編輯狀態
            self.navigationItem.leftBarButtonItem?.title = "完成"
            
            
        }else
        {
            self.tableView.isEditing = false  //進入非編輯狀態
            self.navigationItem.leftBarButtonItem?.title = "編輯"
        }
    }
    

    
    @objc func btnAddAction()
    {
        //MARK: - Get NewAddViewController
        let addVC = self.storyboard!.instantiateViewController(withIdentifier: "NewAddViewController") as! NewAddViewController
        
        //傳遞資訊
        addVC.NewMaTableViewController = self
        
        //顯示新增畫面
        self.show(addVC, sender: nil)
    }
    
    @objc func handleRefresh()
    {
        
        print("下拉更新")
        
        //從updateSearchResults 移到這邊
        isSearch = false
        
      
        getDataFromTable()
        
      
        self.tableView.reloadData()
  
        self.tableView.refreshControl?.endRefreshing()
        
        
        
    }
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return arrTable.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTBCell", for: indexPath) as! ListTBCell
        
        
        
        cell.listAddRess.text = arrTable[indexPath.row]["address"] as? String
        cell.listPhone.text = arrTable[indexPath.row]["phone"]as? String
        cell.listName?.text = arrTable[indexPath.row]["name"] as? String
        cell.listImage.image = UIImage(data: arrTable[indexPath.row]["picture"]! as! Data)
        
      

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        currentRow = indexPath.row
        
        let geoCoder = CLGeocoder()
        //由地理資訊編碼器將地址轉為經緯度
        geoCoder.geocodeAddressString(arrTable[currentRow]["address"]! as! String) { (placemarks, error) in

            //取出地址對應的經緯度（只取陣列中的第一筆經緯度資訊）
            let toPlaceMark = placemarks!.first
            //將經緯度資訊轉為導航地圖目的地的大頭針
            let toPin = MKPlacemark(placemark: toPlaceMark!)
            //設定導航模式為開車模式（Apple地圖只有走路和開車兩種模式）
            let naviOption = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            //產生導航地圖上導航終點的大頭針
            let destMapItem = MKMapItem(placemark: toPin)
            //從現在位置導航到目的地
            destMapItem.openInMaps(launchOptions: naviOption)
        }
        
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let moreAction = UITableViewRowAction(style: .normal, title: "更多") { (rowAction, indexPath) in
            print("更多按鈕被按下")
            
            
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "確定Byby") { (rowAction, IndexPath) in
            
            print("刪除按鈕被按下去了 淦")
        
            //self.arrTable.remove(at: indexPath.row)
            
            
            //Step1.實際刪除資料庫當筆資料
            //Step1_1.準備SQL指令
            let sql = "delete from BabypapaList where name = '\(self.arrTable[indexPath.row]["name"]! as! String)'"
            //將SQL指令轉成C語言字串
            let cSql = sql.cString(using: .utf8)
            //宣告儲存執行結果的指令
            var statement:OpaquePointer?
            /*
             Step1_2.準備執行更新指令
             （第三個參數若為正數，則限定SQL指定的長度。負數則不限定SQL指定的長度。
             第四個參數為預備標誌-prepareFlag，準備給下一版本使用，目前沒有作用，其實預設為0。
             最後一個參數為預留參數，目前沒有作用！）
             */
            sqlite3_prepare_v3(self.db, cSql, -1, 0, &statement, nil)
            
            //Step1_3.執行SQL指令
            if sqlite3_step(statement) == SQLITE_DONE
            {
                //製作訊息視窗
                let alert = UIAlertController(title: "資訊庫訊息", message: "資料庫資料已刪除！", preferredStyle: .alert)
                //在訊息視窗加上一個按鈕
                alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                //顯示訊息視窗
                self.present(alert, animated: true, completion: nil)
            }
            //Step1_4.關閉SQL連線指令
            sqlite3_finalize(statement)
            
            //Step2.刪除陣列當筆資料(離線資料集)
            self.arrTable.remove(at: indexPath.row)
            //Step3.刪除表格上的儲存格
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [moreAction,deleteAction]
        
        
    }
    
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let temparr = arrTable[fromIndexPath.row]
        
        arrTable.remove(at: fromIndexPath.row)
        
        
        arrTable.insert(temparr, at: to.row)
        
        print("移動後之列\(arrTable)")

    }
    

    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
