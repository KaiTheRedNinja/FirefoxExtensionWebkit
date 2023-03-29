//
//  FileManager.swift
//  Orion
//
//  Created by Kai Quan Tay on 22/3/23.
//

import Cocoa
import Foundation

public extension FileManager {

    /// Reads a type from a file
    func read<T: Decodable>(_ type: T.Type, from file: String) -> T? {
        let filename = getDocumentsDirectory().appendingPathComponent(file)
        if let data = try? Data(contentsOf: filename) {
            if let values = try? JSONDecoder().decode(T.self, from: data) {
                return values
            }
        }

        return nil
    }

    /// Writes a type to a file
    func write<T: Encodable>(_ value: T, to file: String, error onError: @escaping (Error) -> Void = { _ in }) {
        var encoded: Data

        do {
            encoded = try JSONEncoder().encode(value)
        } catch {
            onError(error)
            return
        }

        let filename = getDocumentsDirectory().appendingPathComponent(file)
        do {
            try encoded.write(to: filename)
            return
        } catch {
            // failed to write file – bad permissions, bad filename,
            // missing permissions, or more likely it can't be converted to the encoding
            onError(error)
        }
    }

    /// Checks if a file exists at a path
    func exists(file: String) -> Bool {
        let path = getDocumentsDirectory().appendingPathComponent(file)
        return FileManager.default.fileExists(atPath: path.relativePath)
    }

    /// Creates a directory with a name in the documents directory
    func makeDirectory(name: String,
                       onError: (Error) -> Void = { _ in }) {
        let path = getDocumentsDirectory().appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        } catch {
            onError(error)
        }
    }

    /// Gets the documents directory.
    ///
    /// Usually equal to `/Users/[username]/Library/Containers/com.kaithebuilder.Orion/Data/Documents/`
    func getDocumentsDirectory() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return url.first!
    }
}
