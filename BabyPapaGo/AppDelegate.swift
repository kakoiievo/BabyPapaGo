//
//  AppDelegate.swift
//  BabyPapaGo
//
//  Created by Yung on 2018/12/12.
//  Copyright © 2018 Yung. All rights reserved.
//

import UIKit
import SQLite3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var db:OpaquePointer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let fileManger = FileManager.default
        
        let sourceFile = Bundle.main.path(forResource: "BabyPapaGo", ofType: "sqlite3")!
        
        print("==================================")
        print("抓到了\(sourceFile)")
        print("==================================")
        
        let destintionFile = NSHomeDirectory() + "/Documents/BabyPapaGo.sqlite3"
        
        
        print("==================================")
        print("這是\(destintionFile)")
        print("==================================")
        
        if !fileManger.fileExists(atPath: destintionFile)
        {
            //如果上面檔案不存在 就做以下的複製動作到『App跟目錄下的Doucments資料夾』
            try! fileManger.copyItem(atPath: sourceFile, toPath: destintionFile)
        }
        
        if sqlite3_open(destintionFile, &db) == SQLITE_OK
        {
            print("==================================")
            print("資料庫連線成功")
            print("==================================")
        }else
        {
            print("資料庫連線GG")
            // db = nil
        }
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

