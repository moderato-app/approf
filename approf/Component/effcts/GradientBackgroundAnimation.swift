/*
 Thanks to https://github.com/flawless-code/swiftui-animations/blob/main/SwiftUIAnimations/SwiftUIAnimations/GradientBackgroundAnimation.swift
  */
import SwiftUI

struct GradientBackgroundAnimation: View {
  @State private var animateGradient: Bool = false
  @State private var showName: Bool = false
  @State private var showFullContent: Bool = false

  private let startColor: Color = .blue
  private let endColor: Color = .green

  var body: some View {
    VStack(spacing: 20) {
      if showFullContent {
        Image("jobs")
          .resizable()
          .scaledToFit()
          .clipShape(RoundedRectangle(cornerRadius: 15))
          .containerRelativeFrame(.vertical) { v, _ in v * 0.4 }
          .padding(.top, 40)
          .padding(.bottom, 40)
      } else {
        Image(systemName: "swiftdata")
          .font(.system(size: 72, weight: .light))
          .padding(.top, 80)
          .padding(.bottom, 64)
      }

      Text("Here's to the crazy ones.")
        .font(.largeTitle).bold()
      Text("The misfits, the rebels, the troublemakers,")
        .font(.title)
      Text("the round pegs in the square holes, the ones who see things differently.")
        .font(.title)
      Text("You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. \nBecause they change things - they push the human race forward. And while some may see them as the crazy ones, we see genius. \nBecause the people who are crazy enough to think they can change the world, are the ones who do.")
        .scaleEffect(showFullContent ? 1 : 0)
        .opacity(showFullContent ? 1 : 0)
      Spacer()
      Text("Steven Paul Jobs (February 24, 1955 – October 5, 2011)")
        .fontWeight(.thin)
        .padding(6)
        .opacity(showName ? 1 : 0)
    }
    .frame(maxWidth: .infinity)
    .foregroundColor(.black)
    .padding(.horizontal)
    .multilineTextAlignment(.center)
    .background {
      LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
        .hueRotation(.degrees(animateGradient ? 45 : 0))
        .onAppear {
          withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            animateGradient.toggle()
          }
        }
    }
    .delayedHover(5) { h in
      withAnimation {
        showName = h
      }
    }
    .delayedHover(10) { h in
      withAnimation(.easeInOut(duration: 1)) {
        showFullContent = h
      }
    }
  }
}

struct GradientBackgroundAnimation_Previews: PreviewProvider {
  static var previews: some View {
    GradientBackgroundAnimation()
      .ignoresSafeArea()
  }
}
