//
//  AudioPlayer.swift
//  UIDemo
//
//  Created by zhennan on 2020/7/1.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
//The audioplayer class used to play, pause, and load an audio file
final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
   
    @Published var isPlaying = false
   
    var audioPlayer: AVAudioPlayer!
   
    /*
     ==============================================================================
     |   Create Audio Player to play an audio file with a given url of type URL   |
     ==============================================================================
     */
    // url = URL struct pointing to the audio file to be played
    func createAudioPlayer(url: URL) {
        do {
            
            if url.checkFileExist() {
                audioPlayer = try AVAudioPlayer(contentsOf: url,fileTypeHint: nil)
                audioPlayer!.prepareToPlay()
            }
            else {
                print("Error")
            }
            
           
        } catch let error {
            print("Error iss:", error.localizedDescription)
        }
    }
   
    /*
     ========================================================================
     |   Create Audio Player to play an audio file stored as of type Data   |
     ========================================================================
    
     
      audioData value is of type Data of the audio recording
      stored as Data or Binary Data in Core Data database.
      */
     func createAudioPlayer(audioData: Data) {
         do {
             audioPlayer = try AVAudioPlayer(data: audioData)
             audioPlayer!.prepareToPlay()
         } catch {
             print("Unable to create AVAudioPlayer!")
         }
     }
 
    
   
    func startAudioPlayer() {
       
        let audioSession = AVAudioSession.sharedInstance()
       
        do {
            /*
             AVAudioSession.PortOverride.speaker option causes the system to route audio
             to the built-in speaker and microphone regardless of other settings.
             */
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error {
            print("Error iss:", error.localizedDescription)
        }
        /*
         Make this class to be a delegate for the AVAudioPlayerDelegate protocol so that
         we can implement the audioPlayerDidFinishPlaying protocol method below.
         */
        audioPlayer.delegate = self
       
        audioPlayer.play()
        
        isPlaying = true
    }
   
    func pauseAudioPlayer() {
        audioPlayer.pause()
        isPlaying = false
    }
   
    func stopAudioPlayer() {
        audioPlayer.stop()
        isPlaying = false
    }
   
    /*
     This AVAudioPlayerDelegate protocol method is implemented to set the
     @Published var isPlaying to false when the player finishes playing.
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
   
}
 
extension URL    {
    func checkFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            print("FILE AVAILABLE")
            return true
        }else        {
            print("FILE NOT AVAILABLE")
            return false;
        }
    }
}
