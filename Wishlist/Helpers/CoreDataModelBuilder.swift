import CoreData

extension PersistenceController {

    static func buildModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // ── WishlistEntity ────────────────────────────────────────────────
        let wishlistE = entity("WishlistEntity", attrs: [
            attr("id",         .UUIDAttributeType),
            attr("name",       .stringAttributeType, default: "Новый вишлист"),
            attr("emoji",      .stringAttributeType, default: "🎁"),
            attr("colorHex",   .stringAttributeType, default: "#A78BFA"),
            attr("createdAt",  .dateAttributeType),
        ])

        // ── WishlistItemEntity ────────────────────────────────────────────
        let itemE = entity("WishlistItemEntity", attrs: [
            attr("id",              .UUIDAttributeType),
            attr("title",           .stringAttributeType, default: ""),
            attr("urlString",       .stringAttributeType, optional: true),
            attr("descriptionText", .stringAttributeType, optional: true),
            attr("imageData",       .binaryDataAttributeType, optional: true),
            attr("createdAt",       .dateAttributeType),
        ])

        // ── UserProfileEntity ─────────────────────────────────────────────
        let profileE = entity("UserProfileEntity", attrs: [
            attr("nickname",   .stringAttributeType, default: "Мой профиль"),
            attr("avatarData", .binaryDataAttributeType, optional: true),
        ])

        // ── Relationships ─────────────────────────────────────────────────
        let wToI = rel("items",   dest: itemE,     toMany: true,  delete: .cascadeDeleteRule)
        let iToW = rel("wishlist",dest: wishlistE, toMany: false, delete: .nullifyDeleteRule)
        wToI.inverseRelationship = iToW
        iToW.inverseRelationship = wToI
        wishlistE.properties.append(wToI)
        itemE.properties.append(iToW)

        model.entities = [wishlistE, itemE, profileE]
        return model
    }

    // MARK: – Private builders
    private static func entity(_ name: String,
                                attrs: [NSAttributeDescription]) -> NSEntityDescription {
        let e = NSEntityDescription()
        e.name = name
        e.managedObjectClassName = name
        e.properties = attrs
        return e
    }

    private static func attr(_ name: String,
                              _ type: NSAttributeType,
                              optional: Bool = false,
                              default def: Any? = nil) -> NSAttributeDescription {
        let a = NSAttributeDescription()
        a.name = name; a.attributeType = type; a.isOptional = optional
        if let d = def { a.defaultValue = d }
        return a
    }

    private static func rel(_ name: String,
                             dest: NSEntityDescription,
                             toMany: Bool,
                             delete: NSDeleteRule) -> NSRelationshipDescription {
        let r = NSRelationshipDescription()
        r.name = name
        r.destinationEntity = dest
        r.minCount = 0; r.maxCount = toMany ? 0 : 1
        r.isOptional = true
        r.deleteRule = delete
        return r
    }
}
