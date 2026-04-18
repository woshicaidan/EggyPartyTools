//
//  Execute.swift
//  client
//
//  Root 权限命令执行封装
//

import Foundation

enum Execute {

    @discardableResult
    static func rootSpawn(
        binary: String,
        arguments: [String] = [],
        environment: [String: String] = [:]
    ) throws -> AuxiliaryExecute.TerminationReason {
        let receipt = AuxiliaryExecute.spawn(
            command: binary,
            args: arguments,
            environment: environment,
            personaOptions: .init(uid: 0, gid: 0)
        )
        if !receipt.stdout.isEmpty {
            print("标准输出: \(receipt.stdout)")
        }
        if !receipt.stderr.isEmpty {
            print("标准错误: \(receipt.stderr)")
        }
        return receipt.terminationReason
    }

    static func rootSpawnWithOutputs(
        binary: String,
        arguments: [String] = [],
        environment: [String: String] = [:]
    ) throws -> AuxiliaryExecute.ExecuteReceipt {
        let receipt = AuxiliaryExecute.spawn(
            command: binary,
            args: arguments,
            environment: environment,
            personaOptions: .init(uid: 0, gid: 0)
        )
        if !receipt.stdout.isEmpty {
            print("标准输出: \(receipt.stdout)")
        }
        if !receipt.stderr.isEmpty {
            print("标准错误: \(receipt.stderr)")
        }
        return receipt
    }
}
