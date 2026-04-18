//
//  IconChangerView.swift
//  party
//
//  应用图标更换页面
//

import SwiftUI
import PhotosUI

struct IconChangerView: View {
    let appDetail: (name: String, bundleID: String, version: String, icon: UIImage?, bundlePath: String, dataPath: String)
    
    @State private var selectedImageURL: URL?
    @State private var showImagePicker = false
    @State private var statusMessage = ""
    @State private var isProcessing = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                ZStack {
                    Text("更换图标")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                Text("返回")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .overlay(
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.gray.opacity(0.3)),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 应用信息
                        VStack(spacing: 16) {
                            if let icon = appDetail.icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            Text(appDetail.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(appDetail.bundleID)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // 选择新图标
                        VStack(spacing: 16) {
                            if let imageURL = selectedImageURL,
                               let image = UIImage(contentsOfFile: imageURL.path) {
                                VStack(spacing: 12) {
                                    Text("新图标预览")
                                        .font(.headline)
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                }
                            }
                            
                            Button(action: {
                                debugLog("点击选择图标按钮")
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.title3)
                                    Text(selectedImageURL == nil ? "选择图标" : "重新选择")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 操作按钮
                        VStack(spacing: 12) {
                            Button(action: {
                                changeIcon()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("更换图标")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedImageURL == nil ? Color.gray : Color.green)
                                .cornerRadius(12)
                            }
                            .disabled(selectedImageURL == nil || isProcessing)
                            
                            Button(action: {
                                restoreIcon()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("恢复原图标")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                            .disabled(isProcessing)
                        }
                        .padding(.horizontal, 20)
                        
                        // 状态信息
                        if !statusMessage.isEmpty {
                            Text(statusMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
                        
                        // 提示信息
                        VStack(alignment: .leading, spacing: 8) {
                            Text("使用说明")
                                .font(.headline)
                            
                            Text("1. 选择一张图片作为新图标")
                            Text("2. 点击\"更换图标\"按钮")
                            Text("3. 在 TrollStore 中重建图标缓存")
                            Text("4. 图标更换完成")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .fileImporter(isPresented: $showImagePicker, allowedContentTypes: [.png, .jpeg, .image]) { result in
            debugLog("fileImporter 回调触发")
            switch result {
            case .success(let url):
                debugLog("成功选择图片: \(url.path)")
                
                // 需要访问安全作用域资源
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                // 复制到临时目录
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                    debugLog("图片复制成功: \(destinationURL.path)")
                    selectedImageURL = destinationURL
                } catch {
                    debugLog("复制图片失败: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                debugLog("选择图片失败: \(error.localizedDescription)")
            }
        }
    }
    
    func changeIcon() {
        guard let iconURL = selectedImageURL else { return }
        
        isProcessing = true
        statusMessage = "正在更换图标..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let infoPlistPath = "\(appDetail.bundlePath)/Info.plist"
            IconChanger.changeIcon(
                mainpath: infoPlistPath,
                iconPath: iconURL.path,
                iconName: "AppIcon_AA.png"
            ) { success, message in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.statusMessage = message
                    
                    if success {
                        // 提示用户在 TrollStore 中重建图标缓存
                        showSuccessAlert()
                    }
                }
            }
        }
    }
    
    func restoreIcon() {
        isProcessing = true
        statusMessage = "正在恢复原图标..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let infoPlistPath = "\(appDetail.bundlePath)/Info.plist"
            IconChanger.restoreIcon(mainpath: infoPlistPath) { success, message in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.statusMessage = message
                    
                    if success {
                        showSuccessAlert()
                    }
                }
            }
        }
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(
            title: "操作成功",
            message: "请在 TrollStore 中重建图标缓存以应用更改",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "打开 TrollStore", style: .default) { _ in
            if let url = URL(string: "apple-magnifier://") {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "稍后", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

#Preview {
    IconChangerView(appDetail: (
        name: "蛋仔派对",
        bundleID: "com.netease.party",
        version: "1.0.0",
        icon: nil,
        bundlePath: "/path/to/bundle",
        dataPath: "/path/to/data"
    ))
}

