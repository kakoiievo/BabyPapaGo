//
//  ViewController.swift
//  BabyLetsGo
//
//  Created by Yung on 2018/11/15.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UITableViewDelegate,UIPickerViewDataSource,
UIPickerViewDelegate{
 
    
    
   
    @IBOutlet weak var tempeTureLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperTureImage: UIImageView!
    @IBOutlet weak var cityText: UITextField!
   
    
    
    //記錄目前輸入元件的Y軸的底緣位置(跟虛擬鍵盤配合)
    var currentObjectBottomYposion:CGFloat = 0
    
    //let weather = "http://api.openweathermap.org/data/2.5/weather"
    let weather = "http://api.openweathermap.org/data/2.5/weather?"
    let APiKey  = "048c7e8aaf91524fb38f294d0ebb64df"
    
    let weatherDataModel = WeatherDataModel()
    
    let cityClass = ["Keelung","Taipei","Taoyuan","Hsinchu",
                     "Miaoli", "Taichung", "Jiayi", "Tainan", "Kaohsiung", "Pingdong", "Taitung", "Hualien", "Yilan",""]
    
    
    var cityPickView: UIPickerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //24.688176, 120.900805
        
        
        
        
        cityPickView = UIPickerView()
        cityText.inputView = cityPickView
        
        cityPickView.delegate = self
        cityPickView.dataSource = self
        
        let latitude = String(24.688176)
        let longitude = String(120.900805)
        
        let inputs:[String:String] = ["lat":latitude,"lon":longitude,"appid":APiKey]
        
        //getweatherData(url: weather, keys: inputs)
        
       
        
        
        
    
    }
    
    

    func getweatherData(url:String,keys:[String:String])
    {
        
        
        Alamofire.request(url, method: .get, parameters: keys, encoding: URLEncoding.default, headers: nil).responseJSON { (respones) in
            
            if respones.result.isSuccess
            {
                //print("go data 取得成功")
                let weatherJSON:JSON = JSON(respones.result.value)
                //print(weatherJSON)
                self.updataWeather(json: weatherJSON)
                
            }else
            {
                //print("eeror\(String(describing:respones.result.error))")
            }
        }
        
    }
    
    //MARK: - updataWqather func
    func updataWeather(json:JSON)
    {
        
        //使用SwiftyJSON 直接跳到想要的數據
        if let tempture = json["main"]["temp"].double
        {
            
            weatherDataModel.temperture = Int(tempture - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconname = weatherDataModel.updataIcon(conditionId: weatherDataModel.condition)
            
            //data to view
            updataUI()
            
        }else
        {
            cityLabel.text = "weather error"
        }
        
        
     }
    
    
    func updataUI()
    {
        tempeTureLabel.text = String(weatherDataModel.temperture) + "˚"
        //temperTureImage.image = UIImage(named: weatherDataModel.weatherIconname)
        cityLabel.text = weatherDataModel.city
        
        print("溫度：\(tempeTureLabel),城市：\(cityLabel)")
    }
    
    
    //MARK: - CityaddBtn
    @IBAction func addCityBtn(_ sender: UIButton) {
        
        if cityText.text != ""
        {
            //let input1 = cityText.text!
            let key_s: [String:String] = ["q":cityText.text!,"appid":APiKey]
            getweatherData(url: weather, keys: key_s)
            
            if cityText.text == "Keelung"
            {
                cityLabel.text = "基隆"
                
                if cityText.text == "Taipei"
                {
                    cityLabel.text = "台北"
                    
                    if cityText.text == "Taoyuan"
                    {
                        cityLabel.text = "桃園"
                    }
                }
                
            }
            
        }else{
            
            let alert:UIAlertController = UIAlertController(title: "城市名稱錯誤", message: "請輸入完整城市名稱", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return cityClass.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        
        return cityClass[row]
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cityText.text = cityClass[row]
       // cityLabel.text = cityClass[row]
    }
    
    //MARK: - 自訂手勢
    //觸碰開始/結束
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

}

