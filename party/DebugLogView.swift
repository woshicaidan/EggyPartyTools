//
//  DebugLogView.swift
//  party
//
//  调试日志查看界面
//

import SwiftUI

struct DebugLogView: View {
    @State private var logContent: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 日志路径信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("日志文件路径:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(DebugLogger.shared.getLogFilePath())
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                
                Divider()
                
                // 日志内容
                ScrollView {
                    Text(logContent.isEmpty ? "暂无日志" : logContent)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("调试日志")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button("清空") {
                            DebugLogger.shared.clearLog()
                            loadLog()
                        }
                        
                        Button("刷新") {
                            loadLog()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadLog()
        }
    }
    
    func loadLog() {
        logContent = DebugLogger.shared.getLogContent()
    }
}

#Preview {
    DebugLogView()
}

