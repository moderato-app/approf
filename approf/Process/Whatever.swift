import Foundation

func dotExist(_ dirPath: String) -> (String, Bool) {
  let dotFilePath = URL(fileURLWithPath: dirPath).appending(component: "dot").path(percentEncoded: false)
  return (dotFilePath, FileManager.default.fileExists(atPath: dotFilePath))
}
