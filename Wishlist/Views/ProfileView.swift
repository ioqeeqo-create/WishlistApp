import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @State private var nickname = ""; @State private var avatar: UIImage?
    @State private var showPicker = false
    @State private var src: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSrcPicker = false
    @State private var isEditing = false; @State private var showSaved = false
    let accent = Color(hex: "#A78BFA")

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63"),Color(hex: "#24243E")],
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Circle().fill(accent.opacity(0.2)).frame(width: 350).blur(radius: 80)
                    .offset(y: -120).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 32) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                if isEditing {
                                    TextField("Никнейм", text: $nickname)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white).tint(accent)
                                } else {
                                    Text(vm.userProfile?.nickname ?? "Мой профиль")
                                        .font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(.white)
                                }
                                Text("Мой профиль").font(.system(size: 14)).foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            Button { if isEditing { showSrcPicker = true } } label: {
                                ZStack(alignment: .bottomTrailing) {
                                    avatarImage.frame(width: 80, height: 80).clipShape(Circle())
                                    if isEditing {
                                        Circle().fill(accent).frame(width: 24, height: 24)
                                            .overlay(Image(systemName: "camera.fill").font(.system(size: 11)).foregroundStyle(.white))
                                    }
                                }
                                .overlay(Circle().strokeBorder(accent.opacity(0.4), lineWidth: 2).frame(width: 84, height: 84))
                                .shadow(color: accent.opacity(0.3), radius: 12)
                            }
                        }.padding(.horizontal, 20).padding(.top, 16)

                        HStack(spacing: 16) {
                            StatCard(value: "\(vm.wishlists.count)", label: "Вишлистов", color: accent)
                            StatCard(value: "\(vm.wishlists.reduce(0) { $0 + $1.itemsArray.count })",
                                     label: "Желаний", color: Color(hex: "#F472B6"))
                        }.padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Мои списки").font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white).padding(.horizontal, 20)
                            ForEach(vm.wishlists, id: \.id) { wl in
                                HStack(spacing: 14) {
                                    Text(wl.emoji).font(.system(size: 28)).frame(width: 48, height: 48)
                                        .background(Circle().fill(Color(hex: wl.colorHex).opacity(0.2)))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(wl.name).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                                        Text("\(wl.itemsArray.count) желаний").font(.system(size: 13)).foregroundStyle(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.07))
                                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.1), lineWidth: 1)))
                                .padding(.horizontal, 16)
                            }
                        }
                        Spacer(minLength: 40)
                    }.padding(.bottom, 60)
                }

                if showSaved {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill"); Text("Сохранено!")
                        }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(Capsule().fill(Color(hex: "#34D399")))
                        .shadow(color: Color(hex: "#34D399").opacity(0.5), radius: 12)
                        .padding(.bottom, 100).transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Профиль").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Готово" : "Изменить") {
                        if isEditing {
                            vm.updateProfile(nickname: nickname, avatarData: avatar?.jpegData(compressionQuality: 0.8))
                            HapticManager.notification(.success)
                            withAnimation(.spring()) { showSaved = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showSaved = false } }
                        } else { nickname = vm.userProfile?.nickname ?? "" }
                        isEditing.toggle()
                    }.foregroundStyle(accent).font(.system(size: 16, weight: .semibold))
                }
            }
            .confirmationDialog("Источник фото", isPresented: $showSrcPicker) {
                Button("Галерея") { src = .photoLibrary; showPicker = true }
                if UIImagePickerController.isSourceTypeAvailable(.camera) { Button("Камера") { src = .camera; showPicker = true } }
            }
            .sheet(isPresented: $showPicker) { ImagePicker(image: $avatar, sourceType: src) }
            .onAppear { nickname = vm.userProfile?.nickname ?? "" }
        }
    }

    @ViewBuilder var avatarImage: some View {
        if let img = avatar { Image(uiImage: img).resizable().aspectRatio(contentMode: .fill) }
        else if let d = vm.userProfile?.avatarData, let img = UIImage(data: d) {
            Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
        } else {
            ZStack { Circle().fill(accent.opacity(0.25)); Image(systemName: "person.fill").font(.system(size: 36)).foregroundStyle(accent) }
        }
    }
}

struct StatCard: View {
    let value: String; let label: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 36, weight: .bold, design: .rounded)).foregroundStyle(color)
            Text(label).font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20).liquidGlassCard(color: color)
    }
}
