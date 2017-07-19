//
//  DatabaseManagement.swift
//  SqliteExample
//
//  Created by Zahid Shaikh on 06/05/17.
//  Copyright © 2017 Zahid Shaikh. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManagement: NSObject {
    static let shared:DatabaseManagement = DatabaseManagement()
    private let db: Connection?
    private let tblPoduct = Table("products")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let imageName = Expression<String>("imageName")
    var DBName = "ishop.sqlite3"
   private override init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print(path)
        do {
            db = try Connection("\(path)/ishop.sqlite3")
           // createTableProduct()
        } catch{
            db = nil
            print("Unable to open Database")
        }
    
    }
    
    
    private static var __once: () = {
        Static.instance = DatabaseManagement()
    }()
    
    
    struct Static {
        static var onceToken: Int = 0
        static var instance: DatabaseManagement? = nil
    }
    
    class var sharedInstance: DatabaseManagement {
        
        _ = DatabaseManagement.__once
        return Static.instance!
    }
    
    
    
    func getDocumentPath(_ fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    func copyFile(_ fileName: NSString) {
        
        let dbPath: String = getDocumentPath(fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
        }
    }
    
    func createDatabase()-> Bool{
        
        let path = getDocumentPath(DBName)
        
        print(path)
        let exists:Bool = FileManager.default.fileExists(atPath: path)
        if (exists) {
            /* a file of the same name exists, we don't care about this so won't do anything */
            return true;
        }
        
        copyFile(DBName as NSString)
        return false
        
    }
    
    func createTableProduct()  {
        do{
            try db!.run(tblPoduct.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(imageName)
                })
            print("create table successfully")
        } catch {
            print("unable to create table")
        }
    }
    
    func addProduct(inputName:String, inputImageName:String) -> Int64? {
        do {
            let insert = tblPoduct.insert(name <- inputName,imageName <- inputImageName)
            let id = try db!.run(insert)
            print("insert successsfullly to tblProduct")
            return id
        } catch {
        print("cannot insert to database")
        return nil
        }
    }
    
    func queryAllProduct() -> [Product] {
        var products = [Product] ()
        do {
            for product in try db!.prepare(self.tblPoduct){
                let newProduct = Product(id: product[id], name: product[name]  , imageName: product[imageName])
                products.append(newProduct)
                
            }
        } catch{
            print("cannot get list of product")
        }
        for product in products{
            print("each product = \(product)")
        }
        return products
    }
    
    func updateProduct(productId:Int64, newProduct:Product) -> Bool {
        let tblFilterProduct = tblPoduct.filter(id == productId)
        do {
            let update = tblFilterProduct.update([
                name <- newProduct.name,
                imageName <- newProduct.imageName
                ])
            if try db!.run(update) > 0 {
                print("update product succesfully")
                return true
            }
        }catch {
            print("update failed: \(error)")
        }
        return false
        
    }
    
    func deleteProduct(inputId:Int64) -> Bool {
        do{
            let tblFilterProduct = tblPoduct.filter(id == inputId)
            try db!.run(tblFilterProduct.delete())
            print("deleted succeaafully")
            return true
            
        } catch {
            print("delete failed")
        }
        return false
    
    }
    
    
}
