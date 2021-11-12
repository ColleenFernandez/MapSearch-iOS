
import Foundation
import Firebase
import SwiftyUserDefaults
import FirebaseDatabase
import FirebaseFirestore

class FirebaseAPI {
    
    static let ref = Database.database().reference()
    static let BADGE = "badge"
    
    static func getBadgeValueChanage(handler:@escaping (_ value: Int?)->()) -> UInt{
        return ref.child(BADGE).child("\(thisuser.user_id ?? 0)").observe(.childChanged) { (snapshot, error) in
            if let value = snapshot.value as? Int{
                handler(value)
            }else {
                handler(nil)
            }
        }
    }
    
    static func getBadgeValue(_ user_id: Int?, handler:@escaping (_ value: Int?)->()) -> UInt{
        return ref.child(BADGE).child("\(user_id ?? 0)").observe(.value) { (snapshot, error) in
            if let dic = snapshot.value as? Dictionary<String, Any>{
                if let value = dic.values.first as? Int{
                    handler(value)
                }else{
                    handler(nil)
                }
            }else {
                handler(nil)
            }
        }
    }
    
    static func removeBadgeCountValueChanage(_ handle : UInt) {
        ref.child(BADGE).child("u" + "\(thisuser!.user_id ?? 0)").removeObserver(withHandle: handle)
    }
}
