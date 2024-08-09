import ComposableArchitecture
import Foundation

extension UnderTheHood {
  static var mock = Store(initialState:
    UnderTheHood.State(basic:
      Shared(PProfBasic(
        uuid: UUID(),
        urls: [
          URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentasdlControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParesdfntalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_object3s.inuse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Library/Application\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Library/Applicdfgation\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Library/Applicadfgtion\\ Support/Apple/ParentalControls/ALRHelperJobs/pprof.etcd.alloc_objects.alloc_space.inuse_objects.infgfguse_space.002.pb.gz"),
          URL(fileURLWithPath: "/Users/clement/Documents/example.txt"),
          URL(fileURLWithPath: "/Users/username/Documents/example.txt")
        ],
        createdAt: Date(),
        presentation: .dft))))
  {
    UnderTheHood()
  }
}
