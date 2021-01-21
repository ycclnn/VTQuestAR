//
//  listNoteDetails.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/1.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI

//the detail view of a note in a list
struct listNoteDetails: View {
    let note: Note
    let image: UIImage
    
    @EnvironmentObject var audioPlayer: AudioPlayer
    var body: some View {
        Form {
            Section(header: Text("Note title")) {
                Text(note.noteTitle ?? "")
            }
            Section(header: Text("Note Photo")) {
              
                    Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, maxWidth: 500, alignment: .center)
                
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
                Text(note.noteDescription ?? "")
            }
            Section(header: Text("Date Visited")) {
                Text(note.dateVisited ?? "")
            }
            Section(header: Text("Place rating")) {
                Text(note.rating ?? "")
            }
            

            }.onAppear() {
               
                if self.note.photoAndAudio!.audio != nil {
                self.audioPlayer.createAudioPlayer(audioData: self.note.photoAndAudio!.audio!)
                }
            }
            .onDisappear() {
               
                if self.audioPlayer.isPlaying {
                self.audioPlayer.stopAudioPlayer()
                }
            }
        
            // End of Form
            
            .font(.system(size: 14))
            .navigationBarTitle("Note Detail", displayMode: .inline)
        
            .navigationBarHidden(false)
    }
    
}

