import SwiftUI

struct WishlistPreviewCard: View {
    let name: String; let emoji: String; let color: Color
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.25)).frame(width: 80, height: 80)
                Text(emoji).font(.system(size: 42))
            }.shadow(color: color.opacity(0.4), radius: 14)
            Text(name).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 28)
        .liquidGlassCard(color: color).padding(.horizontal, 16)
    }
}

struct EmojiColorPickers: View {
    @Binding var emoji: String; @Binding var colorHex: String
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WishlistPreset.emojis, id: \.self) { e in
                        Button { emoji = e; HapticManager.impact(.light) } label: {
                            Text(e).font(.system(size: 28)).frame(width: 52, height: 52)
                                .background(Circle().fill(emoji == e ? Color(hex: colorHex).opacity(0.3) : Color.white.opacity(0.08))
                                    .overlay(Circle().strokeBorder(emoji == e ? Color(hex: colorHex) : .clear, lineWidth: 2)))
                        }
                    }
                }.padding(.horizontal, 16)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WishlistPreset.colors, id: \.self) { hex in
                        Button { colorHex = hex; HapticManager.impact(.light) } label: {
                            Circle().fill(Color(hex: hex)).frame(width: 44, height: 44)
                                .overlay(Circle().strokeBorder(.white, lineWidth: colorHex == hex ? 3 : 0))
                                .shadow(color: Color(hex: hex).opacity(0.5), radius: 6)
                        }
                    }
                }.padding(.horizontal, 16)
            }
        }
    }
}

struct AddWishlistView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""; @State private var emoji = "🎁"
    @State private var colorHex = WishlistPreset.colors[0]
    var color: Color { Color(hex: colorHex) }
    var valid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 28) {
                        WishlistPreviewCard(name: name.isEmpty ? "Название" : name, emoji: emoji, color: color)
                        GlassTextField(text: $name, placeholder: "Название *", icon: "pencil", color: color)
                            .padding(.horizontal, 16)
                        EmojiColorPickers(emoji: $emoji, colorHex: $colorHex)
                        Button {
                            guard valid else { return }
                            HapticManager.notification(.success)
                            vm.createWishlist(name: name, emoji: emoji, colorHex: colorHex); dismiss()
                        } label: {
                            Text("Создать вишлист").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(valid ? color : .white.opacity(0.2))
                                    .shadow(color: valid ? color.opacity(0.5) : .clear, radius: 12, y: 4))
                        }.disabled(!valid).padding(.horizontal, 16)
                    }.padding(.vertical, 24).padding(.bottom, 40)
                }
            }
            .navigationTitle("Новый вишлист").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() }.foregroundStyle(color) } }
        }
    }
}

struct EditWishlistView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @Environment(\.dismiss) var dismiss
    let wishlist: WishlistEntity
    @State private var name: String; @State private var emoji: String; @State private var colorHex: String
    init(wishlist: WishlistEntity) {
        self.wishlist = wishlist
        _name = State(initialValue: wishlist.name)
        _emoji = State(initialValue: wishlist.emoji)
        _colorHex = State(initialValue: wishlist.colorHex)
    }
    var color: Color { Color(hex: colorHex) }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 28) {
                        WishlistPreviewCard(name: name.isEmpty ? "Название" : name, emoji: emoji, color: color)
                        GlassTextField(text: $name, placeholder: "Название *", icon: "pencil", color: color)
                            .padding(.horizontal, 16)
                        EmojiColorPickers(emoji: $emoji, colorHex: $colorHex)
                        Button {
                            HapticManager.notification(.success)
                            vm.updateWishlist(wishlist, name: name, emoji: emoji, colorHex: colorHex); dismiss()
                        } label: {
                            Text("Сохранить").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(color).shadow(color: color.opacity(0.5), radius: 12, y: 4))
                        }.padding(.horizontal, 16)
                        Button(role: .destructive) {
                            vm.deleteWishlist(wishlist); dismiss()
                        } label: {
                            Text("Удалить вишлист").font(.system(size: 16, weight: .medium)).foregroundStyle(.red.opacity(0.8))
                        }
                    }.padding(.vertical, 24).padding(.bottom, 40)
                }
            }
            .navigationTitle("Редактировать").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() }.foregroundStyle(color) } }
        }
    }
}
