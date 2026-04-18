//
//  AboutView.swift
//  party
//
//  Created by 窝是菜蛋 on 2025/09/20.
//

import SwiftUI

struct AboutView: View {
    @State private var showDebugLog = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 版本信息
                    HStack {
                        Text("Version 1.1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 工具按钮
                    VStack(spacing: 12) {
                        Button(action: {
                            showDebugLog = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.title3)
                                Text("查看调试日志")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            openTrollStore()
                        }) {
                            HStack {
                                Image(systemName: "gear.badge")
                                    .font(.title3)
                                Text("打开 TrollStore")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            clearCache()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.title3)
                                Text("清除缓存")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 使用的封装库
                    VStack(alignment: .leading, spacing: 3) {
                        Text("使用的封装库")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            openURL("https://github.com/Lakr233/AuxiliaryExecute")
                        }) {
                            HStack {
                                Image("github-mark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("AuxiliaryExecute by @Lakr233")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 构建参考
                    VStack(alignment: .leading, spacing: 3) {
                        Text("构建参考")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            openURL("https://github.com/opa334/TrollStore")
                        }) {
                            HStack {
                                Image("github-mark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("TrollStore by @opa334")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 代码参考
                    VStack(alignment: .leading, spacing: 3) {
                        Text("代码参考")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            openURL("https://github.com/huami1314/SuperIcons")
                        }) {
                            HStack {
                                Image("github-mark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("SuperIcons by @huami1314")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            openURL("https://github.com/Lessica/TrollFools")
                        }) {
                            HStack {
                                Image("github-mark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("TrollFools by @Lessica")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("开源")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            openURL("https://github.com/woshicaidan")
                        }) {
                            HStack {
                                Image("github-mark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("窝是菜蛋的GitHub")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 免责声明
                    VStack(spacing: 12) {
                        Text("免责声明")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("本工具仅供学习交流使用，请勿用于非法用途。使用本工具所产生的一切后果由使用者自行承担。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        Text("Swift和Objective-C真的比Kotlin难写")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    // 版权信息
                    VStack(spacing: 8) {
                        Text("菜蛋工具箱v1.0.0(17) 窝是菜蛋版权所有 ©2025 ")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("不要为了越狱放弃升级的乐趣")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding(.bottom, 20)
                }
            }
            // 顶部
            .navigationTitle("菜蛋工具箱")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showDebugLog) {
            DebugLogView()
        }
    }
    // 巨魔的URL Scheme(iOS放大镜)
    func openTrollStore() {
        if let url = URL(string: "apple-magnifier://") {
            UIApplication.shared.open(url)
        }
    }
    
    // 相册功能已经删除，这个按钮实际没有任何作用(╥﹏╥)
    func clearCache() {
        
        let alert = UIAlertController(
            title: "缓存已清除",
            message: "图片缓存已成功清除",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// 信息行
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    AboutView()
}

