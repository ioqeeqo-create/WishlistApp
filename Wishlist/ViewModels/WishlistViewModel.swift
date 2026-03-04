import CoreData
import SwiftUI

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var wishlists: [WishlistEntity] = []
    @Published var userProfile: UserProfileEntity?

    private let ctx: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.ctx = context
        fetchAll()
        fetchOrCreateProfile()
        if wishlists.isEmpty { seedDefaults() }
    }

    // MARK: Fetch
    func fetchAll() {
        let req = WishlistEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        wishlists = (try? ctx.fetch(req)) ?? []
    }

    func fetchOrCreateProfile() {
        let req = UserProfileEntity.fetchRequest()
        if let p = (try? ctx.fetch(req))?.first { userProfile = p; return }
        let p = UserProfileEntity(context: ctx); p.nickname = "Мой профиль"
        save(); userProfile = p
    }

    // MARK: Seed
    private func seedDefaults() {
        let emojis  = ["🎁","💻","📚","✈️"]
        for i in 0..<4 {
            let w = WishlistEntity(context: ctx)
            w.id = UUID(); w.name = WishlistPreset.names[i]
            w.emoji = emojis[i]; w.colorHex = WishlistPreset.colors[i]
            w.createdAt = Date().addingTimeInterval(Double(i))
        }
        save(); fetchAll()
    }

    // MARK: Wishlists CRUD
    func createWishlist(name: String, emoji: String, colorHex: String) {
        let w = WishlistEntity(context: ctx)
        w.id = UUID(); w.name = name; w.emoji = emoji
        w.colorHex = colorHex; w.createdAt = Date()
        save(); fetchAll()
    }

    func updateWishlist(_ w: WishlistEntity, name: String, emoji: String, colorHex: String) {
        w.name = name; w.emoji = emoji; w.colorHex = colorHex
        save(); fetchAll()
    }

    func deleteWishlist(_ w: WishlistEntity) {
        ctx.delete(w); save(); fetchAll()
    }

    // MARK: Items CRUD
    func addItem(to wishlist: WishlistEntity, title: String,
                 urlString: String?, description: String?, imageData: Data?) {
        let i = WishlistItemEntity(context: ctx)
        i.id = UUID(); i.title = title; i.createdAt = Date()
        i.urlString = urlString?.isEmpty == false ? urlString : nil
        i.descriptionText = description?.isEmpty == false ? description : nil
        i.imageData = imageData; i.wishlist = wishlist
        save(); fetchAll()
    }

    func updateItem(_ item: WishlistItemEntity, title: String,
                    urlString: String?, description: String?, imageData: Data?) {
        item.title = title
        item.urlString = urlString?.isEmpty == false ? urlString : nil
        item.descriptionText = description?.isEmpty == false ? description : nil
        if let d = imageData { item.imageData = d }
        save(); fetchAll()
    }

    func deleteItem(_ item: WishlistItemEntity) {
        ctx.delete(item); save(); fetchAll()
    }

    // MARK: Profile
    func updateProfile(nickname: String, avatarData: Data?) {
        userProfile?.nickname = nickname
        if let d = avatarData { userProfile?.avatarData = d }
        save()
    }

    // MARK: Share
    func shareText(for w: WishlistEntity) -> String {
        var t = "🎁 Мой вишлист «\(w.name)»\n\n"
        for item in w.itemsArray {
            t += "• \(item.title)"
            if let u = item.urlString { t += "\n  🔗 \(u)" }
            if let d = item.descriptionText { t += "\n  📝 \(d)" }
            t += "\n\n"
        }
        return t
    }

    private func save() { PersistenceController.shared.save() }
}
