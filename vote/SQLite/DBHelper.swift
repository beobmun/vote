//
//  DBHelper.swift
//  vote
//
//  Created by 한법문 on 2022/01/20.
//

import Foundation
import SQLite3

enum SQLiteTableName {
    case recentSearchCandidate
}

struct OverallData: Codable, Identifiable {
    var id = UUID()
    var election: Election
    var commonCode: CommonCode
    var candidateItem: CandidateItem
    var posterImage: URL
    var elected: Bool
    var pledgeArray: [Pledge]
}

class DBHelper {
    static let shared = DBHelper()
    
    var db: OpaquePointer?
    var path = "mySqlite.sqlite"
    
    init() {
        self.db = createDB()
    }
    
    func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        do {
            let filePath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(path)
            if sqlite3_open(filePath.path, &db) == SQLITE_OK {
                print("Success create db Path")
                return db
            }
        }
        catch {
            print("error in createDB")
        }
        print("error in createDB - sqlite3_open")
        return nil
    }
    
    func createTable(_ tableName: String, _ columm: [String]) {
        var columms: String {
            var columms = "id INTEGER primary key autoincrement"
            for col in columm {
                columms += ", \(col) text"
            }
            return columms
        }
        
        let query = "create table if not exists \(tableName) (\(columms))"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("create table success")
            } else {
                print("create table step fail")
            }
        } else {
            print("error: create table sqlite3 prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    func deleteTable(_ tableName: String) {
        let query = "DROP TABLE \(tableName)"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("delete table success")
            } else {
                print("delete table step fail")
            }
        } else {
            print("delete table prepare fail")
        }
    }
    
    
    // 구조체를 insert 하기 위해서는
    //        do {
    //            let data = try JSONEncoder().encode(insertData)
    //            let dataToString = String(data: data, encoding: .utf8)
    //        }
    //        catch {
    //            print("JsonEncoder Error")
    //        }
    // 인코딩해서 텍스트(스트링)으로 변환 후 넣기
    
    func insertData(_ tableName: String, _ columm: [String], _ insertData: [String]) {
        var columms: String {
            var columms = "id"
            for col in columm {
                columms += ", \(col)"
            }
            return columms
        }
        
        var values: String {
            var values = "?"
            for _ in (0..<columm.count) {
                values += ", ?"
            }
            return values
        }
        
        let query = "insert into \(tableName) (\(columms)) values (\(values))"
        var statement: OpaquePointer? = nil
        

        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            for i in (0..<insertData.count) {
                sqlite3_bind_text(statement, Int32(i + 2), NSString(string: insertData[i]).utf8String, -1, nil)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("insert data success")
            } else {
                print("insert data sqlite3 step fail")
            }
            
        } else {
            print("insert Data prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    func readData(_ tableName: String, _ columm: [String]) -> (Dictionary<Int, Any>) {
        let query = "select * from \(tableName)"
        var statement: OpaquePointer? = nil
        var readData = Dictionary<Int,Dictionary<String, String>>()
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                var data = Dictionary<String, String>()
                for i in (0..<columm.count) {
                    data[columm[i]] = String(cString: sqlite3_column_text(statement, Int32(i + 1)))
                }
                readData[Int(id)] = data
//                let overallData = String(cString: sqlite3_column_text(statement, 1))
//                do {
//                    let data = try JSONDecoder().decode(OverallData.self, from: overallData.data(using: .utf8)!)
//                    print("readData Result : \(id) \(data.candidateItem.name)")
//                } catch {
//                    print("JSONDecoder Error")
//                }
            }
        } else {
            print("read Data prepare fail")
        }
        sqlite3_finalize(statement)
        return readData
    }
    
    func deleteData(_ tableName: String, _ id: Int) {
        let query = "delete from \(tableName) where id == \(id)"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("delete data success")
            } else {
                print("delete data step fail")
            }
        } else {
            print("delete data prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    func updateData(_ tableName: String) {
        let query = "update \(tableName) set id = 2 where id = 5"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("success updateData")
            } else {
                print("updataData sqlite3 step fail")
            }
        } else {
            print("updateData prepare fail")
        }
    }
}
