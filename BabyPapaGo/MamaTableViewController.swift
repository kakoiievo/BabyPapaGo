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
            
            sqlite3_prepare_v2(db!, cSql, -1, &statement, nil)
            
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
                
        
                //儲存數位檔案的(第3欄)
                var imageData:Data!
                
                //讀取檔案的位元資料(用於照片或是其他檔案)
                if let totalBytes = sqlite3_column_blob(statement, 5)
                {
                    
                    //讀取檔案長度
                    let fileLength = sqlite3_column_bytes(statement, 5)
                    
                    //將檔案資訊還原成Data
                    imageData = Data(bytes: totalBytes, count: Int(fileLength))
                    
                }
                else
                {
                    let aImage = UIImage(named: "test.jpeg")
                    //imageData = aImage?.jpegData(compressionQuality: 0.8)
                    dicRow["picture"] = aImage
                }
                
                
                
                
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
        cell.listImage.image = arrTable[indexPath.row]["picture"] as? UIImage
        
        
        /*
        //經緯度轉換
        let geoCoder = CLGeocoder()
        var lat:Double = 0
        var long:Double = 0
        geoCoder.geocodeAddressString(cell.listAddRess.text!, completionHandler: {
            (placemarks:[Any]!, error) -> Void in
            if error != nil{
                print(error as Any)
                //return
            }
            if placemarks != nil && placemarks.count > 0{
                let placemark = placemarks[0] as! CLPlacemark
                //placemark.location.coordinate 取得經緯度的參數
                lat = placemark.location!.coordinate.latitude
                long = placemark.location!.coordinate.longitude
                print("latitude: \(lat) \n")
                print("longitude: \(long) ")
                let latLabel: UILabel = cell.viewWithTag(4) as! UILabel
                latLabel.text = String(lat)
                let longLabel: UILabel = cell.viewWithTag(5) as! UILabel
                longLabel.text = String(long)
                let userLatitude = self.myUserDefaults.object(forKey: "userLatitude") as? Double
                let userLongitude = self.myUserDefaults.object(forKey: "userLongitude") as? Double
                print(userLatitude)
                print(userLongitude)
                
                
                //self.reverseGeocodeLocation(_latitude: userLatitude!, _longitude: userLongitude!)
                let mmLabel: UILabel = cell.viewWithTag(6) as! UILabel
                let km = (self.getDistance(lat1:userLatitude!,lng1:userLongitude!,lat2:lat,lng2:long))
                let mm = km * 1000
                if mm>=1000
                {
                    mmLabel.text = "\(String(format: "%.2f", km)) 公里"
                }else{
                    mmLabel.text = "\(String(mm)) 公尺"
                }
                
                
                //print(tmp)
            }
        })
    */
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        currentRow = indexPath.row
        
        let geoCoder = CLGeocoder()
        //由地理資訊編碼器將地址轉為經緯度
        geoCoder.geocodeAddressString(arrTable[currentRow]["address"]! as! String) { (placemarks, error) in
//            if error != nil
//            {
//                print("地址轉換經緯度失敗！")
//                return
//            }
//            if placemarks == nil
//            {
//                print("查無地址對應的經緯度")
//                return
//            }
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
        
            self.arrTable.remove(at: indexPath.row)
            
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return[moreAction,deleteAction]
        
        
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
