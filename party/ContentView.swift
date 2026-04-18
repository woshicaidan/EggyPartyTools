// 老项目搬过来的

import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import PhotosUI
import AVFoundation

struct ContentView: View {
    let selectedBundleID: String?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var bundleId: String = "com.netease.party"
    @State private var fileName: String = "login.mp4"
    @State private var selectedFileURL: URL?
    @State private var logMessages: [String] = []
    @State private var isReplacing: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var hasRootAccess: Bool = false
    @State private var isConverting: Bool = false
    @State private var conversionProgress: Double = 0.0
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("应用信息")) {
                            TextField("Bundle ID", text: $bundleId)
                            //蛋仔Bundle ID的输入框(自动填充可更改)
                            
                            //没招了只能整个退出键盘按钮
                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                HStack {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                    Text("退出键盘")
                                }
                                .font(.system(size: 14))
                            }
                        }

                        //选择文件
                        Section(header: Text("文件操作")) {
                            Button(action: {
                                showFilePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "folder")
                                    Text("选择替换文件")
                                }
                            }
                            //添加从相册中选择按钮
                            Button(action: {
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("从相册中选择")
                                }
                            }
                            
                            if let fileURL = selectedFileURL {
                                Text("已选择: \(fileURL.lastPathComponent)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                replaceFiles()
                            }) {
                                HStack {
                                    if isReplacing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isReplacing ? "替换中..." : "开始替换")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .disabled(selectedFileURL == nil || isReplacing || isConverting || !hasRootAccess)
                            .listRowBackground(
                                (selectedFileURL != nil && !isReplacing && !isConverting && hasRootAccess) ? Color.blue : Color.gray
                            )
                            .foregroundColor(.white)
                        }
                        //更多板块
                        Section(header: Text("更多")) {
                            Button("检查权限") {
                                checkPermissions()
                            }
                            
                        }
                        
                        Section(header: Text("操作日志")) {
                            ScrollViewReader { proxy in
                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: 4) {
                                        ForEach(logMessages, id: \.self) { message in
                                            Text(message)
                                                .font(.system(size: 12, design: .monospaced))
                                                .id(message)
                                        }
                                    }
                                    .padding(4)
                                }
                                .frame(height: 200)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onChange(of: logMessages) { _ in
                                    if let lastMessage = logMessages.last {
                                        withAnimation {
                                            proxy.scrollTo(lastMessage, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }

                        //记得给我的蛋仔主页留言嘻嘻嘻
                        Text("不要为了越狱放弃升级的乐趣")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                            .padding(.horizontal, 8)
                    }
                }

                //权限提示弹窗
                if !hasRootAccess {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {}
                    
                    VStack(spacing: 20) {
                        //红色叉号
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        //权限提示
                        Text("需要内核读写权限")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("请使用TrollStore签名此应用")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        //确定按钮
                        Button(action: {
                            //点击后关闭弹窗
                            withAnimation {
                                hasRootAccess = true
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
            .navigationTitle("蛋仔开屏动画替换工具")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                }
            }
            .sheet(isPresented: $showFilePicker) {
                DocumentPicker(selectedFileURL: $selectedFileURL)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedFileURL: $selectedFileURL)
            }
            .onAppear {
                if let selectedBundleID = selectedBundleID {
                    bundleId = selectedBundleID
                }
                checkPermissions()
            }
            .overlay(
                Group {
                    if isConverting {
                        VStack {
                            ProgressView(value: conversionProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: 200)
                            Text("正在转换视频格式...")
                                .padding(.top)
                            Text("\(Int(conversionProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())  //使用栈导航样式(适配iPad)
    }
    
    func checkPermissions() {
        log("开始检查权限...")
        let fileManager = FileManager.default
        
        // 测试是否可以访问data
        let testPaths = [
            "/var/mobile/Containers/Data/Application",
        ]
        
        //测试的日志输出
        var accessible = true
        for path in testPaths {
            log("检查路径: \(path)")
            if !fileManager.isReadableFile(atPath: path) {
                accessible = false
                log("无法访问: \(path)")
            } else {
                log("可以访问: \(path)")
            }
        }
        
        hasRootAccess = accessible
        
        if accessible {
            log("权限检查通过")
        } else {
            log("权限不足，请确保使用 TrollStore 签名")
        }
    }
    
    func replaceFiles() {
        guard let replacementURL = selectedFileURL else {
            log("错误: 未选择文件")
            return
        }
        
        guard !bundleId.isEmpty else {
            log("错误: Bundle ID 不能为空")
            return
        }
        
        log("选择的文件: \(replacementURL.lastPathComponent)")
        log("目标 Bundle ID: \(bundleId)")
        log("目标文件名: \(fileName)")
        
        // 检查文件格式，如果是 MOV 需要转换
        let fileExtension = replacementURL.pathExtension.lowercased()
        if fileExtension == "mov" {
            log("检测到 MOV 格式，开始转换为 MP4...")
            convertVideoToMP4(inputURL: replacementURL) { convertedURL in
                if let convertedURL = convertedURL {
                    self.log("视频转换完成")
                    self.performFileReplacement(with: convertedURL)
                } else {
                    self.log("视频转换失败")
                }
            }
        } else {
            performFileReplacement(with: replacementURL)
        }
    }
    
    private func performFileReplacement(with fileURL: URL) {
        isReplacing = true
        log("开始替换文件...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.replaceFilesWithRootAccess(
                replacementURL: fileURL,
                fileName: self.fileName,
                bundleId: self.bundleId
            )
            
            DispatchQueue.main.async {
                self.isReplacing = false
                if result {
                    self.log("文件替换操作完成！")
                    self.log("请重启目标应用查看效果")
                } else {
                    self.log("文件替换操作失败，请查看上方日志")
                }
            }
        }
    }
    
    // 删除这个函数（第242-318行）
    // 保留这个函数（第320行开始）
    func replaceFilesWithRootAccess(replacementURL: URL, fileName: String, bundleId: String) -> Bool {
        log("开始查找应用路径...")
        let fileManager = FileManager.default
        
        // 查找应用路径
        let containerPaths = findApplicationPaths(for: bundleId)
        
        if containerPaths.bundlePath.isEmpty || containerPaths.dataPath.isEmpty {
            log("未找到应用路径")
            if containerPaths.bundlePath.isEmpty {
                log("Bundle 路径为空")
            }
            if containerPaths.dataPath.isEmpty {
                log("Data 路径为空")
            }
            return false
        }
        
        log("找到Bundle路径: \(containerPaths.bundlePath)")
        log("找到Data路径: \(containerPaths.dataPath)")
        
        // 构建目标文件路径
        let bundleTargetPath = containerPaths.bundlePath + "/res/video/\(fileName)"
        let dataTargetPath = containerPaths.dataPath + "/Documents/res/video/\(fileName)"
        
        log("Bundle目标路径: \(bundleTargetPath)")
        log("Data目标路径: \(dataTargetPath)")
        
        var success = true
        
        // 替换Bundle路径下的文件
        log("开始处理Bundle路径文件...")
        if fileManager.fileExists(atPath: bundleTargetPath) {
            log("找到Bundle路径目标文件")
            do {
                // 使用libs的rm命令以root权限删除原文件
                let rmBinaryURL = getRmBinaryURL()
                log("使用rm命令删除原文件: \(rmBinaryURL.path)")
                let rmRetCode = try Execute.rootSpawnWithOutputs(
                    binary: rmBinaryURL.path,
                    arguments: ["-rf", bundleTargetPath]
                )
                
                if case .exit(let rmCode) = rmRetCode.terminationReason, rmCode == 0 {
                    log("成功删除Bundle路径原文件")
                    
                    // 使用libs的cp命令以root权限复制新文件
                    let cpBinaryURL = getCpBinaryURL()
                    log("使用cp命令复制新文件: \(cpBinaryURL.path)")
                    let cpRetCode = try Execute.rootSpawnWithOutputs(
                        binary: cpBinaryURL.path,
                        arguments: ["-rfp", replacementURL.path, bundleTargetPath]
                    )
                    
                    if case .exit(let cpCode) = cpRetCode.terminationReason, cpCode == 0 {
                        log("成功替换Bundle路径文件")
                    } else {
                        if case .exit(let cpCode) = cpRetCode.terminationReason {
                            log("复制文件到Bundle路径失败，退出代码: \(cpCode)")
                        } else {
                            log("复制文件到Bundle路径失败")
                        }
                        log("错误输出: \(cpRetCode.stderr)")
                        success = false
                    }
                } else {
                    if case .exit(let rmCode) = rmRetCode.terminationReason {
                        log("删除Bundle路径原文件失败，退出代码: \(rmCode)")
                    } else {
                        log("删除Bundle路径原文件失败")
                    }
                    log("错误输出: \(rmRetCode.stderr)")
                    success = false
                }
            } catch {
                log("替换Bundle路径文件失败: \(error.localizedDescription)")
                success = false
            }
        } else {
            log("Bundle路径下未找到目标文件: \(bundleTargetPath)")
        }
        
        // 替换Data路径下的文件
        log("开始处理Data路径文件...")
        if fileManager.fileExists(atPath: dataTargetPath) {
            log("找到Data路径目标文件")
            do {
                // 使用libs的rm命令以root权限删除原文件
                let rmBinaryURL = getRmBinaryURL()
                log("使用rm命令删除原文件: \(rmBinaryURL.path)")
                let rmRetCode = try Execute.rootSpawnWithOutputs(
                    binary: rmBinaryURL.path,
                    arguments: ["-rf", dataTargetPath]
                )
                
                if case .exit(let rmCode) = rmRetCode.terminationReason, rmCode == 0 {
                    log("成功删除Data路径原文件")
                    
                    // 使用libs的cp命令以root权限复制新文件
                    let cpBinaryURL = getCpBinaryURL()
                    log("使用cp命令复制新文件: \(cpBinaryURL.path)")
                    let cpRetCode = try Execute.rootSpawnWithOutputs(
                        binary: cpBinaryURL.path,
                        arguments: ["-rfp", replacementURL.path, dataTargetPath]
                    )
                    
                    if case .exit(let cpCode) = cpRetCode.terminationReason, cpCode == 0 {
                        log("成功替换Data路径文件")
                    } else {
                        if case .exit(let cpCode) = cpRetCode.terminationReason {
                            log("复制文件到Data路径失败，退出代码: \(cpCode)")
                        } else {
                            log("复制文件到Data路径失败")
                        }
                        log("错误输出: \(cpRetCode.stderr)")
                        success = false
                    }
                } else {
                    if case .exit(let rmCode) = rmRetCode.terminationReason {
                        log("删除Data路径原文件失败，退出代码: \(rmCode)")
                    } else {
                        log("删除Data路径原文件失败")
                    }
                    log("错误输出: \(rmRetCode.stderr)")
                    success = false
                }
            } catch {
                log("替换Data路径文件失败: \(error.localizedDescription)")
                success = false
            }
        } else {
            log("Data路径下未找到目标文件，尝试创建...")
            // 尝试创建目录并复制文件
            let dataTargetDir = containerPaths.dataPath + "/Documents/res/video/"
            log("检查目录: \(dataTargetDir)")
            if !fileManager.fileExists(atPath: dataTargetDir) {
                log("目录不存在，开始创建...")
                do {
                    try fileManager.createDirectory(
                        atPath: dataTargetDir,
                        withIntermediateDirectories: true
                    )
                    log("创建目录成功: \(dataTargetDir)")
                } catch {
                    log("创建目录失败: \(error.localizedDescription)")
                    success = false
                    return success
                }
            } else {
                log("目录已存在")
            }
            
            do {
                // 使用libs的cp命令以root权限复制新文件
                let cpBinaryURL = getCpBinaryURL()
                log("使用cp命令复制新文件到Data路径: \(cpBinaryURL.path)")
                let cpRetCode = try Execute.rootSpawnWithOutputs(
                    binary: cpBinaryURL.path,
                    arguments: ["-rfp", replacementURL.path, dataTargetPath]
                )
                
                if case .exit(let cpCode) = cpRetCode.terminationReason, cpCode == 0 {
                    log("成功创建并复制文件到Data路径")
                } else {
                    if case .exit(let cpCode) = cpRetCode.terminationReason {
                        log("复制文件到Data路径失败，退出代码: \(cpCode)")
                    } else {
                        log("复制文件到Data路径失败")
                    }
                    log("错误输出: \(cpRetCode.stderr)")
                    success = false
                }
            } catch {
                log("复制文件到Data路径失败: \(error.localizedDescription)")
                success = false
            }
        }
        
        return success
    }
    
    func findApplicationPaths(for bundleId: String) -> (bundlePath: String, dataPath: String) {
        let fileManager = FileManager.default
        var bundlePath = ""
        var dataPath = ""
        
        //查找.app路径
        let bundleContainerPath = "/var/containers/Bundle/Application"
        do {
            let appUUIDs = try fileManager.contentsOfDirectory(atPath: bundleContainerPath)
            for appUUID in appUUIDs {
                let appPath = bundleContainerPath + "/" + appUUID
                let appContents = try? fileManager.contentsOfDirectory(atPath: appPath)
                
                //根据Bundle ID查找.app路径
                for content in appContents ?? [] {
                    if content.hasSuffix(".app") {
                        let infoPlistPath = appPath + "/" + content + "/Info.plist"
                        if let infoDict = NSDictionary(contentsOfFile: infoPlistPath),
                           let appBundleId = infoDict["CFBundleIdentifier"] as? String,
                           appBundleId == bundleId {
                            bundlePath = appPath + "/" + content
                            break
                        }
                    }
                }
                if !bundlePath.isEmpty { break }
            }
        } catch {
            log("查找Bundle路径时出错: \(error.localizedDescription)")
        }
        
        //根据Bundle ID查找APP Data路径
        let dataContainerPath = "/var/mobile/Containers/Data/Application"
        do {
            let appUUIDs = try fileManager.contentsOfDirectory(atPath: dataContainerPath)
            for appUUID in appUUIDs {
                let metadataPath = dataContainerPath + "/" + appUUID + "/.com.apple.mobile_container_manager.metadata.plist"
                if let metadataDict = NSDictionary(contentsOfFile: metadataPath),
                   let appBundleId = metadataDict["MCMMetadataIdentifier"] as? String,
                   appBundleId == bundleId {
                    dataPath = dataContainerPath + "/" + appUUID
                    break
                }
            }
        } catch {
            log("查找Data路径时出错: \(error.localizedDescription)")
        }
        
        return (bundlePath, dataPath)
    }
    
    func log(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(message)"
        
        DispatchQueue.main.async {
            logMessages.append(logMessage)
        }
    }
    
    // 获取cp二进制文件URL
    private func getCpBinaryURL() -> URL {
        if #available(iOS 16.0, *) {
            return Bundle.main.url(forResource: "cp", withExtension: nil)!
        } else {
            return Bundle.main.url(forResource: "cp-15", withExtension: nil)!
        }
    }
    
    // 获取rm二进制文件URL
    private func getRmBinaryURL() -> URL {
        return Bundle.main.url(forResource: "rm", withExtension: nil)!
    }
    
    // 视频格式转换函数
    private func convertVideoToMP4(inputURL: URL, completion: @escaping (URL?) -> Void) {
        isConverting = true
        conversionProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: inputURL)
            
            // 创建输出URL
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            
            // 删除已存在的文件
            try? FileManager.default.removeItem(at: outputURL)
            
            // 创建导出会话
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                DispatchQueue.main.async {
                    self.isConverting = false
                    completion(nil)
                }
                return
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            // 设置进度监控
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    self.conversionProgress = Double(exportSession.progress)
                }
            }
            
            exportSession.exportAsynchronously {
                timer.invalidate()
                
                DispatchQueue.main.async {
                    self.isConverting = false
                    
                    switch exportSession.status {
                    case .completed:
                        self.log("视频转换成功: \(outputURL.lastPathComponent)")
                        completion(outputURL)
                    case .failed:
                        self.log("视频转换失败: \(exportSession.error?.localizedDescription ?? "未知错误")")
                        completion(nil)
                    case .cancelled:
                        self.log("视频转换被取消")
                        completion(nil)
                    default:
                        self.log("视频转换状态未知")
                        completion(nil)
                    }
                }
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.movie, .video, .data],
            asCopy: true
        )
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedFileURL = url
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            //处理取消操作
        }
    }
}

//添加ImagePicker结构体
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie", "public.video"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                //复制视频文件到临时目录
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent(videoURL.lastPathComponent)
                
                do {
                    try FileManager.default.copyItem(at: videoURL, to: destinationURL)
                    parent.selectedFileURL = destinationURL
                } catch {
                    print("复制视频文件失败: \(error)")
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


