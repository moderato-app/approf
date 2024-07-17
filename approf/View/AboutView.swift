import SwiftUI

struct AboutView: View {
  var body: some View {
    HStack(spacing: 50) {
      Image("About")
        .resizable()
        .scaledToFit()
      VStack(alignment: .leading) {
        VStack(alignment: .leading){
          Text("approf")
            .font(.system(size: 40))
            .fontWeight(.semibold)
          Spacer().frame(height: 5)
          Text("Version \(getAppVersion())")
            .font(.headline)
            .fontWeight(.regular)
        }
        .offset(y: -15)

        Spacer()
        Text("Copyright © 2024 https://github.com/moderato-app/approf")
          .font(.footnote)
      }
      .padding(.bottom, 5)
    }
    .frame(height: 100)
    .padding(40)
  }
}

#Preview {
  AboutView()
}
