import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @State private var showAdd = false
    @State private var selected: WishlistEntity?

    let cols = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack {
                background
                GeometryReader { g in
                    Circle().fill(Color(hex: "#A78BFA").opacity(0.22))
                        .frame(width: 280).blur(radius: 60).offset(x: -60, y: 80)
                    Circle().fill(Color(hex: "#F472B6").opacity(0.18))
                        .frame(width: 220).blur(radius: 50)
                        .offset(x: g.size.width - 160, y: g.size.height - 300)
                }.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        LazyVGrid(columns: cols, spacing: 16) {
                            ForEach(vm.wishlists, id: \.id) { wl in
                                WishlistCardButton(wishlist: wl) { selected = wl }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(item: $selected) { wl in
                WishlistDetailView(wishlist: wl).environmentObject(vm)
            }
            .sheet(isPresented: $showAdd) {
                AddWishlistView().environmentObject(vm)
            }
        }
    }

    var background: some View {
        LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63"),Color(hex: "#24243E")],
                       startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Привет, \(vm.userProfile?.nickname ?? "друг") 👋")
                    .font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.7))
                Text("Мои вишлисты")
                    .font(.system(size: 32, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            Button { HapticManager.impact(.light); showAdd = true } label: {
                Image(systemName: "plus.circle.fill").font(.system(size: 32))
                    .foregroundStyle(Color(hex: "#A78BFA"))
                    .shadow(color: Color(hex: "#A78BFA").opacity(0.5), radius: 8)
            }
        }
        .padding(.horizontal, 20).padding(.top, 8)
    }
}

struct WishlistCardButton: View {
    let wishlist: WishlistEntity
    let action: () -> Void
    @State private var pressed = false
    var color: Color { Color(hex: wishlist.colorHex) }

    var body: some View {
        Button {
            HapticManager.impact(.medium); action()
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(color.opacity(0.3)).frame(width: 64, height: 64)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
                    Text(wishlist.emoji).font(.system(size: 32))
                }
                .shadow(color: color.opacity(0.5), radius: 12)

                VStack(spacing: 4) {
                    Text(wishlist.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white).multilineTextAlignment(.center)
                        .lineLimit(2).minimumScaleFactor(0.8)
                    Text("\(wishlist.itemsArray.count) желаний")
                        .font(.system(size: 12, weight: .medium)).foregroundStyle(color.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 24).padding(.horizontal, 12)
            .liquidGlassCard(color: color, isPressed: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        ._onButtonGesture(pressing: { pressed = $0 }, perform: {})
    }
}
