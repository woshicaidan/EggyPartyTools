//
//  AppListView.swift
//  party
//
//  蛋仔派对应用列表界面
//

import SwiftUI

struct AppListView: View {
    @State private var appDetails: [(name: String, bundleID: String, version: String, icon: UIImage?, bundlePath: String, dataPath: String)] = []
    @State private var isLoading = true
    @State private var showDebugLog = false
    
    // 硬编码的Bundle ID
    private let presetBundleIDs = [
        "com.netease.party",
        "com.netease.party1", 
        "com.netease.party2",
        "com.netease.party3",
        "com.netease.party4",
        "com.netease.party5",
        "com.netease.party6",
        "com.netease.tiyan.party",
        "com.netease.pre.party",
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("正在扫描蛋仔派对应用...")
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if appDetails.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("未找到应用")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("请确保已使用TrollStore签名此应用")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("重新扫描") {
                            fetchAppDetails()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(appDetails, id: \.bundleID) { appDetail in
                            NavigationLink(destination: AppDetailView(appDetail: appDetail)) {
                                HStack {
                                    if let icon = appDetail.icon {
                                        Image(uiImage: icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: "gamecontroller")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(appDetail.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Bundle ID: \(appDetail.bundleID)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("版本: \(appDetail.version)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("菜蛋工具箱")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                }
            }
            .onAppear {
                fetchAppDetails()
            }
            .sheet(isPresented: $showDebugLog) {
                DebugLogView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func fetchAppDetails() {
        isLoading = true
        appDetails = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 在模拟器环境中，私有API不可用
            #if targetEnvironment(simulator)
            DispatchQueue.main.async {
                // 模拟一些应用数据用于预览
                self.appDetails = [
                    (name: "测试模拟1", bundleID: "com.netease.party", version: "1.0.200", icon: nil, bundlePath: "/path/to/bundle", dataPath: "/path/to/data"),
                    (name: "测试模拟2", bundleID: "com.netease.party2", version: "1.0.199", icon: nil, bundlePath: "/path/to/bundle2", dataPath: "/path/to/data2")
                ]
                self.isLoading = false
            }
            return
            #endif
            
            // 提权使用苹果私有API枚举应用(某粥行为)
            guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type,
                  let workspace = workspaceClass.perform(NSSelectorFromString("defaultWorkspace")).takeUnretainedValue() as? NSObject,
                  let applications = workspace.perform(NSSelectorFromString("allApplications")).takeUnretainedValue() as? [NSObject] else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let detectedApps = applications.compactMap { app -> (name: String, bundleID: String, version: String, icon: UIImage?, bundlePath: String, dataPath: String)? in
                guard let bundleIDResult = app.perform(NSSelectorFromString("applicationIdentifier")),
                      let bundleID = bundleIDResult.takeUnretainedValue() as? String,
                      let bundlePathResult = app.perform(NSSelectorFromString("bundleURL")),
                      let bundlePath = bundlePathResult.takeUnretainedValue() as? URL,
                      let dataContainerResult = app.perform(NSSelectorFromString("dataContainerURL")),
                      let dataContainerURL = dataContainerResult.takeUnretainedValue() as? URL else {
                    return nil
                }
                
                // 只枚举预设
                if presetBundleIDs.contains(bundleID) {
                    let infoPlistPath = bundlePath.appendingPathComponent("Info.plist").path
                    if FileManager.default.fileExists(atPath: infoPlistPath),
                       let infoDict = NSDictionary(contentsOfFile: infoPlistPath),
                       let displayName = infoDict["CFBundleDisplayName"] as? String,
                       let version = infoDict["CFBundleShortVersionString"] as? String {
                        let icon = getAppIcon(from: bundlePath)
                        return (name: displayName, bundleID: bundleID, version: version, icon: icon, bundlePath: bundlePath.path, dataPath: dataContainerURL.path)
                    }
                }
                return nil
            }
            
            DispatchQueue.main.async {
                self.appDetails = detectedApps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                self.isLoading = false
            }
        }
    }
    
    func getAppIcon(from bundleURL: URL) -> UIImage? {
        let possibleIconPaths = [
            "AppIcon_AA.png",
            "AppIcon60x60@2x.png",
            "AppIcon76x76@2x.png",
            "AppIcon83.5x83.5@2x.png",
            "AppIcon40x40@2x.png",
            "AppIcon29x29@2x.png",
            "AppIcon.png",
            "Icon.png",
            "icon.png",
            "Icon-60.png",
            "icon-60.png"
        ]
        
        for iconName in possibleIconPaths {
            let iconPath = bundleURL.appendingPathComponent(iconName)
            if let image = UIImage(contentsOfFile: iconPath.path) {
                return image
            }
        }
        
        return nil
    }
}

#Preview {
    AppListView()
}
