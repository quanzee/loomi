//
//  MovieView.swift
//  loomi
//
//  Created by Zayn on 1/12/2025.
//

import SwiftUI

struct MovieView: View {
    
    let movie: Movie
    
    @State private var showAll = false
    @State private var showQuestions = false
    @State private var isBookmarked = false
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 1)
    ]
    
    
    var body: some View {
        ZStack {
            ZStack {
                Color.paletteBackground
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        // top buttons
                        HStack{
                            Spacer()
                            
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(Color.paletteText)
                                .onTapGesture {
                                    withAnimation {
                                        isBookmarked.toggle()
                                    }
                                }
                            Image(systemName:
                                    "text.bubble")
                            .foregroundColor(Color.paletteText)
                        }
                        .font(.title)
                        .foregroundColor(Color.paletteText)
                        .padding([.bottom], 10)
                        
                        //movie title, release date, length
                        HStack {
                            VStack(alignment:.leading) {
                                Text(movie.name)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.paletteText)
                                Text("\(movie.releasedDate) | \(102) mins")
                                    .foregroundColor(Color.paletteText)
                            }
                            
                            Spacer()
                            
                            //recommended age
                            ZStack{
                                Circle()
                                    .fill(Color.paletteText) // fill first
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Circle().stroke(Color(red: 89/255, green: 89/255, blue: 89/255), lineWidth: 5) // border on top
                                    )
                                Text(movie.suitableAge)
                                    .font(.title2)
                                    .foregroundStyle(Color.black)
                            }
                            .padding(.trailing, 5)
                        }
                        .frame(maxWidth: .infinity)
                        
                        //genres and popularity
                        HStack {
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack {
                                    ForEach(movie.genres, id: \.self) { genre in
                                        Text(genre)
                                            .padding(8)
                                            .background(Color.paletteValue)
                                            .cornerRadius(15)
                                            .foregroundStyle(Color.black)
                                    }
                                }
                            }
                            
                            
                            HStack {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundStyle(Color.paletteText)
                                Text(movie.popularity)
                                    .foregroundColor(Color.paletteText)
                            }
                        }
                        
                        //poster and trailer
                        ZStack {
                            Image(movie.posterLandscape)
                                .resizable()
                                .scaledToFill() // fills the frame while maintaining aspect ratio
                                .clipped()
                            
                            Rectangle()
                                .frame(width: 350, height: 175)
                                .cornerRadius(15)
                                .opacity(0.3)
                                .foregroundStyle(Color.black)
                            
                            Button {
                                openYouTube(with: movie.trailerID)
                            } label: {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.largeTitle)
                            }
                            .buttonStyle(.plain)
                            
                            
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                                    .frame(width: 39, height: 33)
                                
                                Text(movie.movieAgeRating)
                                    .foregroundStyle(Color.black)
                            }
                            .frame(maxWidth: 350, maxHeight: 175, alignment: .topTrailing)
                            
                        }
                        .frame(width:350, height: 175)
                        .cornerRadius(15)
                        .clipped()
                        
                        //synopsis
                        Text(movie.synopsis)
                            .foregroundStyle(Color.paletteText)
                            .lineLimit(nil)          // allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true)
                        
                        //values
                        VStack(alignment: .leading) {
                            Text("Values")
                                .foregroundStyle(Color.paletteText)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack {
                                    ForEach(movie.values, id: \.self) { value in
                                        Text(value)
                                            .padding(8)
                                            .background(Color.paletteValue)
                                            .cornerRadius(15)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.black)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        .padding([.top], 15)
                        .padding([.bottom], 10)
                        
                        //questions
                        Button {
                            showQuestions = true
                        } label: {
                            ZStack(alignment: .center) {
                                Rectangle()
                                        .frame(width: 351, height: 110)
                                        .cornerRadius(15)
                                        .foregroundStyle(Color.paletteBigBlock)
                                
                                Text("Hey Beck! Tap here to dive into fun conversation starters for you and your kids after the movie.")
                                    .multilineTextAlignment(.center)
                                    .fontWeight(.medium)
                                    .padding(10)
                                    .foregroundStyle(Color.black)
                            }
                        }
                        
                        .buttonStyle(.plain) // removes button styling so it looks like your card
                        .sheet(isPresented: $showQuestions) {
                            QuestionsView(questions: movie.questions)
                        }
                        
                        
                        //user reviews
                        VStack(alignment: .leading){
                            Text("User Reviews")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.paletteText)
                            
                            //user review 1
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .cornerRadius(15)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "hand.thumbsup.fill")
                                        Text("Username1")
                                            .font(.title3)
                                            .foregroundStyle(Color.paletteText)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text("Age: 9, 11")
                                            .fontWeight(.thin)
                                            .foregroundStyle(Color.paletteText)
                                    }
                                    
                                    Text("My kids loved this!")
                                        .foregroundStyle(Color.paletteText)
                                    
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack {
                                            Text("Empathy")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            Text("Courage")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            Text("Confidence")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                            }
                            
                            //user review 2
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .cornerRadius(15)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "hand.thumbsdown.fill")
                                        Text("Username2")
                                            .font(.title3)
                                            .foregroundStyle(Color.paletteText)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        Text("Age: 10")
                                            .fontWeight(.thin)
                                            .foregroundStyle(Color.paletteText)
                                    }
                                    
                                    Text("Tried too hard to be funny.")
                                        .foregroundStyle(Color.paletteText)
                                    
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack {
                                            Text("Empathy")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                            }
                            
                            
                            //user review 3
                            ZStack {
                                Rectangle()
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .cornerRadius(15)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "hand.thumbsup.fill")
                                        Text("Username3")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color.paletteText)
                                        
                                        Spacer()
                                        
                                        Text("Age: 8, 10, 12")
                                            .fontWeight(.thin)
                                            .foregroundStyle(Color.paletteText)
                                    }
                                    
                                    Text("Great movie for teaching my kids about emotions.")
                                        .foregroundStyle(Color.paletteText)
                                    
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack {
                                            Text("Resilience")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            Text("Honesty")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            Text("Empathy")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                            Text("Compassion")
                                                .padding(8)
                                                .background(Color.paletteValue)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(15)
                                                .foregroundStyle(Color.black)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                            }
                            
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top], 15)
                    }
                }
                .padding([.leading, .trailing], 25)
            }
        }

    }
    
    func openYouTube(with id: String) {
        let appURL = URL(string: "youtube://watch?v=\(id)")!
        let webURL = URL(string: "https://www.youtube.com/watch?v=\(id)")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}
    


