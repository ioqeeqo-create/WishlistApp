import SwiftUI

// MARK: - Shared UI components

struct GlassTextField: View {
    @Binding var text: String
    let placeholder: String; let icon: String; let color: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(color).font(.system(size: 16)).frame(width: 24)
            TextField(placeholder, text: $text).foregroundStyle(.white).tint(color)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.15), lineWidth: 1)))
    }
}

struct GlassTextEditor: View {
    @Binding var text: String
    let placeholder: String; let color: Color
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder).foregroundStyle(.white.opacity(0.35))
                    .padding(.horizontal, 16).padding(.vertical, 14).allowsHitTesting(false)
            }
            TextEditor(text: $text).foregroundStyle(.white).tint(color)
                .scrollContentBackground(.hidden).padding(.horizontal, 12).padding(.vertical, 8)
                .frame(minHeight: 90)
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.15), lineWidth: 1)))
    }
}

struct ImagePickerCard: View {
    let image: UIImage?; let color: Color; let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let img = image {
                    Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity).frame(height: 200).clipped()
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "pencil.circle.fill").font(.system(size: 28))
                                .foregroundStyle(.white).shadow(radius: 4).padding(12)
                        }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus").font(.system(size: 40)).foregroundStyle(color.opacity(0.8))
                        Text("Добавить фото").font(.system(size: 15, weight: .medium)).foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity).frame(height: 160)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(color.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController(); p.sourceType = sourceType
        p.delegate = context.coordinator; p.allowsEditing = true; return p
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ p: ImagePicker) { parent = p }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Add Item
struct AddItemView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @Environment(\.dismiss) var dismiss
    let wishlist: WishlistEntity
    @State private var title = ""; @State private var url = ""
    @State private var desc = ""; @State private var image: UIImage?
    @State private var showPicker = false
    @State private var src: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSrcPicker = false
    var color: Color { Color(hex: wishlist.colorHex) }
    var valid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        ImagePickerCard(image: image, color: color) { showSrcPicker = true }
                        VStack(spacing: 16) {
                            GlassTextField(text: $title, placeholder: "Название *", icon: "tag.fill", color: color)
                            GlassTextField(text: $url, placeholder: "Ссылка на товар", icon: "link", color: color)
                                .keyboardType(.URL).autocorrectionDisabled().textInputAutocapitalization(.never)
                            GlassTextEditor(text: $desc, placeholder: "Описание (опционально)", color: color)
                        }.padding(.horizontal, 16)
                        Button {
                            guard valid else { return }
                            HapticManager.notification(.success)
                            vm.addItem(to: wishlist, title: title, urlString: url, description: desc,
                                       imageData: image?.jpegData(compressionQuality: 0.8))
                            dismiss()
                        } label: {
                            Text("Добавить желание").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(valid ? color : .white.opacity(0.2))
                                    .shadow(color: valid ? color.opacity(0.5) : .clear, radius: 12, y: 4))
                        }.disabled(!valid).padding(.horizontal, 16)
                    }.padding(.vertical, 16).padding(.bottom, 40)
                }
            }
            .navigationTitle("Новое желание").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() }.foregroundStyle(color) } }
            .confirmationDialog("Источник фото", isPresented: $showSrcPicker) {
                Button("Галерея") { src = .photoLibrary; showPicker = true }
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Камера") { src = .camera; showPicker = true }
                }
                if image != nil { Button("Удалить фото", role: .destructive) { image = nil } }
            }
            .sheet(isPresented: $showPicker) { ImagePicker(image: $image, sourceType: src) }
        }
    }
}

// MARK: - Edit Item
struct EditItemView: View {
    @EnvironmentObject var vm: WishlistViewModel
    @Environment(\.dismiss) var dismiss
    let item: WishlistItemEntity
    @State private var title: String; @State private var url: String
    @State private var desc: String; @State private var image: UIImage?
    @State private var showPicker = false
    @State private var src: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSrcPicker = false
    var color: Color { Color(hex: item.wishlist?.colorHex ?? "#A78BFA") }

    init(item: WishlistItemEntity) {
        self.item = item
        _title = State(initialValue: item.title)
        _url   = State(initialValue: item.urlString ?? "")
        _desc  = State(initialValue: item.descriptionText ?? "")
        if let d = item.imageData { _image = State(initialValue: UIImage(data: d)) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "#0F0C29"),Color(hex: "#302B63")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        ImagePickerCard(image: image, color: color) { showSrcPicker = true }
                        VStack(spacing: 16) {
                            GlassTextField(text: $title, placeholder: "Название *", icon: "tag.fill", color: color)
                            GlassTextField(text: $url, placeholder: "Ссылка на товар", icon: "link", color: color)
                                .keyboardType(.URL).autocorrectionDisabled().textInputAutocapitalization(.never)
                            GlassTextEditor(text: $desc, placeholder: "Описание", color: color)
                        }.padding(.horizontal, 16)
                        Button {
                            HapticManager.notification(.success)
                            vm.updateItem(item, title: title, urlString: url, description: desc,
                                          imageData: image?.jpegData(compressionQuality: 0.8))
                            dismiss()
                        } label: {
                            Text("Сохранить изменения").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Capsule().fill(color).shadow(color: color.opacity(0.5), radius: 12, y: 4))
                        }.padding(.horizontal, 16)
                    }.padding(.vertical, 16).padding(.bottom, 40)
                }
            }
            .navigationTitle("Редактирование").navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() }.foregroundStyle(color) } }
            .confirmationDialog("Источник фото", isPresented: $showSrcPicker) {
                Button("Галерея") { src = .photoLibrary; showPicker = true }
                if UIImagePickerController.isSourceTypeAvailable(.camera) { Button("Камера") { src = .camera; showPicker = true } }
                if image != nil { Button("Удалить фото", role: .destructive) { image = nil } }
            }
            .sheet(isPresented: $showPicker) { ImagePicker(image: $image, sourceType: src) }
        }
    }
}
