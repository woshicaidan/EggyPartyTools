//
//  AppDetailView.swift
//  party
//
//  APP详情中转页面
//

import SwiftUI

struct AppDetailView: View {
    let appDetail: (name: String, bundleID: String, version: String, icon: UIImage?, bundlePath: String, dataPath: String)
    @State private var showContentView = false
    @State private var showPhotoAlbum = false
    @State private var showIconChanger = false
    @State private var showDeprecatedAlert = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
            // 应用信息展示
            VStack(spacing: 16) {
                if let icon = appDetail.icon {
                    Image(uiImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "gamecontroller")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(spacing: 8) {
                    Text(appDetail.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Bundle ID: \(appDetail.bundleID)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("版本: \(appDetail.version)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // 功能按钮列表
            VStack(spacing: 12) {
                Button(action: {
                    showContentView = true
                }) {
                    HStack {
                        Image(systemName: "video.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("更改开屏动画")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("替换登录视频文件")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                // 更换图标功能按钮
                Button(action: {
                    showIconChanger = true
                }) {
                    HStack {
                        Image(systemName: "app.badge.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("更换应用图标")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("自定义应用图标")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            
        }
        .padding()
        .navigationTitle("应用详情")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showContentView) {
            ContentView(selectedBundleID: appDetail.bundleID)
        }
        //.fullScreenCover(isPresented: $showPhotoAlbum) {
        //    PhotoAlbumView(bundleID: appDetail.bundleID)
        //}
        .fullScreenCover(isPresented: $showIconChanger) {
            IconChangerView(appDetail: appDetail)
        }
        
        // 权限提示弹窗
        if showDeprecatedAlert {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {}
            
            // 此容器无实际调用
            VStack(spacing: 20) {
                // 红色叉号
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                // 权限提示
                Text("此功能已被弃用")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("性能优化不佳")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // 按钮容器
                HStack(spacing: 12) {
                    // 确定按钮
                    Button(action: {
                        // 点击后关闭弹窗
                        withAnimation {
                            showDeprecatedAlert = false
                        }
                    }) {
                        Text("确定")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // 仍要进入按钮
                    Button(action: {
                        // 关闭弹窗并打开PhotoAlbumView
                        withAnimation {
                            showDeprecatedAlert = false
                        }
                        showPhotoAlbum = true
                    }) {
                        Text("仍要进入")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding(40)
        }
        
    }
    }
}

// Xcode Preview测试参数
#Preview {
    NavigationView {
        AppDetailView(appDetail: (
            name: "蛋仔派对",
            bundleID: "com.netease.party",
            version: "1.0.0",
            icon: nil,
            bundlePath: "/path/to/bundle",
            dataPath: "/path/to/data"
        ))
    }
    .navigationViewStyle(StackNavigationViewStyle())
}
