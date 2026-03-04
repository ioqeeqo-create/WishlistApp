import CoreData
import Foundation

// MARK: - WishlistEntity
@objc(WishlistEntity)
public class WishlistEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var emoji: String
    @NSManaged public var colorHex: String
    @NSManaged public var createdAt: Date
    @NSManaged public var items: NSSet?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishlistEntity> {
        NSFetchRequest<WishlistEntity>(entityName: "WishlistEntity")
    }

    var itemsArray: [WishlistItemEntity] {
        (items as? Set<WishlistItemEntity> ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    @objc(addItemsObject:)  @NSManaged public func addToItems(_ v: WishlistItemEntity)
    @objc(removeItemsObject:) @NSManaged public func removeFromItems(_ v: WishlistItemEntity)
}

// MARK: - WishlistItemEntity
@objc(WishlistItemEntity)
public class WishlistItemEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var urlString: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var wishlist: WishlistEntity?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishlistItemEntity> {
        NSFetchRequest<WishlistItemEntity>(entityName: "WishlistItemEntity")
    }
}

// MARK: - UserProfileEntity
@objc(UserProfileEntity)
public class UserProfileEntity: NSManagedObject {
    @NSManaged public var nickname: String
    @NSManaged public var avatarData: Data?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileEntity> {
        NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
    }
}
