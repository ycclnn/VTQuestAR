//
//  mapViewNoteCallout.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/2.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI


//when a callout of a note is tapped on the map view, this view will be presented to user
struct noteCallOutDetail: View {
    //The title of note
    @State var noteId: UUID?
    @State var noteTitle: String?
    //the image of note
    @State var image: UIImage?
    //The note object
    @State var note: Note?
    //The audioplayer
    @EnvironmentObject var audioPlayer: AudioPlayer

    
    
    @State var hideNavBar: Bool
    var body: some View {
        Form {
            Section(header: Text("Note title")) {
                if (self.noteTitle != nil) {
                Text(self.noteTitle! )
                }
            }
            Section(header: Text("Note Photo")) {
              
                if (self.image != nil) {
                Image(uiImage: self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, maxWidth: 500, alignment: .center)
                }
                
                
            }
            Section(header: Text("Play Notes Taken by Voice Recording")) {
                Button(action: {
                    if self.audioPlayer.isPlaying {
                        self.audioPlayer.pauseAudioPlayer()
                    } else {
                        self.audioPlayer.startAudioPlayer()
                    }
                }) {
                    Image(systemName: self.audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.blue)
                        .font(Font.title.weight(.regular))
                    }
            }
            Section(header: Text("Note description")) {
                if (self.note != nil) {
                Text(note!.noteDescription ?? "")
                }
            }
            Section(header: Text("Date Visited")) {
                if (self.note != nil) {
                Text(note!.dateVisited ?? "")
                }
            }
            Section(header: Text("Place rating")) {
                if (self.note != nil) {
                Text(note!.rating ?? "")
                }
            }
            
            //on appearing
            }.onAppear() {
                //show the nav bar
                self.hideNavBar = false
                let noteReturned = searchDatabaseForNote(id: self.noteId!)
                self.noteTitle = noteReturned.noteTitle!
                self.note = noteReturned
                //prepare image, note, and load audio player that will be used to present the view
                self.image = getImage(imageData: (noteReturned.photoAndAudio?.photo)!)
                
                self.audioPlayer.createAudioPlayer(audioData:noteReturned.photoAndAudio!.audio!)
               
            }
        //on disappearing
            .onDisappear() {
                //hide the nav bar again
                self.hideNavBar = true
                //stop the audio player
                if self.audioPlayer.isPlaying {
                self.audioPlayer.stopAudioPlayer()
                }
          
            }
            .font(.system(size: 14))
            .navigationBarTitle("Note Detail", displayMode: .inline)
            .navigationBarHidden(false)
        
       
        
    }
}


