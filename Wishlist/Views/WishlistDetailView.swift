import SwiftUI

struct WishlistDetailView: View {
    @EnvironmentObject var vm: WishlistViewModel
    let wishlist: WishlistEntity
    @State private var showAdd = false
    @State private var editing: WishlistItemEntity?
    @State private var showShare = false
    @State private var showEditWL = false
    @State private var shareText = ""
    var color: Color { Color(hex: wishlist.colorHex) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63"),Color(hex: "#24243E")],
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Circle().fill(color.opacity(0.2)).frame(width: 300).blur(radius: 70)
                .offset(x: 100, y: -100).ignoresSafeArea()

            if wishlist.itemsArray.isEmpty {
                EmptyWishlistView(color: color) { showAdd = true }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(wishlist.itemsArray, id: \.id) { item in
                            WishlistItemCard(item: item, color: color) {
                                editing = item
                            } onDelete: {
                                withAnimation(.spring()) { vm.deleteItem(item) }
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 100)
                }
            }

            VStack { Spacer()
                HStack { Spacer()
                    Button { HapticManager.impact(.medium); showAdd = true } label: {
                        ZStack {
                            Circle().fill(LinearGradient(colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 60, height: 60)
                                .shadow(color: color.opacity(0.6), radius: 16, y: 6)
                            Image(systemName: "plus").font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                        }
                    }
                    .padding(.trailing, 24).padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("\(wishlist.emoji) \(wishlist.name)")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button { shareText = vm.shareText(for: wishlist); showShare = true } label: {
                        Image(systemName: "square.and.arrow.up").foregroundStyle(color)
                    }
                    Button { showEditWL = true } label: {
                        Image(systemName: "pencil.circle.fill").foregroundStyle(color).font(.system(size: 22))
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd)    { AddItemView(wishlist: wishlist).environmentObject(vm) }
        .sheet(item: $editing)           { EditItemView(item: $0).environmentObject(vm) }
        .sheet(isPresented: $showEditWL) { EditWishlistView(wishlist: wishlist).environmentObject(vm) }
        .sheet(isPresented: $showShare)  { ShareSheet(items: [shareText]) }
    }
}

struct EmptyWishlistView: View {
    let color: Color; let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 120, height: 120)
                Image(systemName: "gift").font(.system(size: 50)).foregroundStyle(color.opacity(0.8))
            }
            VStack(spacing: 8) {
                Text("Список пуст").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("Добавь первое желание!").font(.system(size: 16)).foregroundStyle(.white.opacity(0.6))
            }
            Button { onAdd() } label: {
                Label("Добавить желание", systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 28).padding(.vertical, 14)
                    .background(Capsule().fill(color).shadow(color: color.opacity(0.5), radius: 12, y: 4))
            }
            Spacer()
        }.padding()
    }
}

struct WishlistItemCard: View {
    let item: WishlistItemEntity; let color: Color
    let onEdit: () -> Void; let onDelete: () -> Void
    @State private var pressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let d = item.imageData, let img = UIImage(data: d) {
                Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
                    .frame(height: 180).clipped().cornerRadius(20, corners: [.topLeft,.topRight])
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(color.opacity(0.15)).frame(height: 100)
                        .cornerRadius(20, corners: [.topLeft,.topRight])
                    VStack(spacing: 6) {
                        Image(systemName: "photo").font(.system(size: 28)).foregroundStyle(color.opacity(0.5))
                        Text(item.title).font(.system(size: 13)).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title).font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white).lineLimit(2)
                if let d = item.descriptionText, !d.isEmpty {
                    Text(d).font(.system(size: 14)).foregroundStyle(.white.opacity(0.65)).lineLimit(2)
                }
                if let u = item.urlString, !u.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "link").font(.system(size: 12)).foregroundStyle(color)
                        Text(u).font(.system(size: 13)).foregroundStyle(color).lineLimit(1).truncationMode(.middle)
                    }
                    .onTapGesture { if let url = URL(string: u) { UIApplication.shared.open(url) } }
                }
                HStack {
                    Button { onEdit() } label: {
                        Label("Изменить", systemImage: "pencil").font(.system(size: 13, weight: .medium)).foregroundStyle(color)
                    }
                    Spacer()
                    Button(role: .destructive) { onDelete() } label: {
                        Image(systemName: "trash").font(.system(size: 15)).foregroundStyle(.red.opacity(0.8))
                    }
                }.padding(.top, 4)
            }.padding(16)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.07))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.white.opacity(0.12), lineWidth: 1)))
        .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        .scaleEffect(pressed ? 0.97 : 1.0).animation(.spring(response: 0.3), value: pressed)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
