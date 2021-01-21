//
//  addNote.swift
//  UIDemo
//
//  Created by zhennan on 2020/6/5.
//  Copyright © 2020 zhennan yao. All rights reserved.
//

import SwiftUI
import AVFoundation
import CoreLocation
import CoreData
import UIKit
import AVKit

let locationManager = CLLocationManager()
fileprivate var idAndFilename = UUID()
struct addNote: View {
    @State var showAudioPermissionAlert = false
    @State var record = false
    //dismiss from current view
    @Environment(\.presentationMode) var presentationMode
    //show alert if any info is missing before saving
    @State private var showAlert = false
    //alert title
    @State private var showAlertTitle = ""
    //alert message
    @State private var showAlertMessage = ""
    //animation of microphone for speech to text button
    @State private var animateOuterFirst = false
    @State private var animateInnerFirst = false
    //animation of microphone for voice memo button
    @State private var animateOuterSecond = false
    @State private var animateInnerSecond = false
    //@State private var stopAnimation = false
    
    //@Binding var isPresented: Bool
    //core data context
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    //disable user to type using keyboard when add description by speech to text option
    @State private var userInteraction = false
    //note title
    @State private var title = ""
    //note description
    @State private var description = "Enter the description of the note"
    //date of note save
    @State private var date = Date()
    //speech to text
    @State private var speechToText = ""
    //audio url
    @State private var audioURL :URL?
    
    //show photo picker
    @State private var showPhotoPicker = false
    //current photo data
    @State private var photo: Data? = nil
    //take photo or pick photo from photo library
    @State private var takeOrPickIndex = 0
    //record the voice or not
    @State private var recordVoice = false
    //convert from speech to text or not
    @State private var sToT = false
    
    //rating of places
    @State private var rating = 2
    //rating options
    let ratingChoices = ["Excellent", "Good", "Average", "Fair", "Poor"]
    //select photo choices
    var photoChoices = ["Camera", "Photo Library"]
    //date closed range to choose
    var dateClosedRange: ClosedRange<Date> {
        // Set minimum date to 20 years earlier than the current year
        let minDate = Calendar.current.date(byAdding: .year, value: -20, to: Date())!
        
        // Set maximum date to 2 years later than the current year
        let maxDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        return minDate...maxDate
    }
    
    
    //
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    var body: some View {
        Form{
            Section(header: Text("Note Title")) {
                TextField("Enter the title of the note", text: $title)
            }
            Section(header: Text("Note Description"), footer:
                    Button(action: {
                        self.dismissKeyboard()
                    }) {
                        Image(systemName: "keyboard")
                            .font(Font.title.weight(.light))
                            .foregroundColor(.blue)
                    }) {
                HStack {
                    TextEditor(text: self.$description).disabled(userInteraction)
                              .foregroundColor(self.description == "Enter the description of the note" ? .gray : .primary)
                              .onTapGesture {
                                if self.description == "Enter the description of the note" {
                                  self.description = ""
                                }
                              }

                }
                HStack {
                    Spacer()
                    Button(action: {
                        if self.sToT {
                            self.cancelRecording()
                            self.sToT = false
                            self.userInteraction = false
                        } else {
                            self.sToT = true
                            self.recordAndRecognizeSpeech()
                            self.animateInnerFirst = true
                            self.animateOuterFirst = true
                            self.userInteraction = true
                        }
                    }) {
                        
                        
                        
                        
                        VStack {
                            ZStack {
                                //when speech to text func is started
                                if (self.sToT == true) {
                                    Circle()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
                                        .scaleEffect(animateOuterFirst ? 1 : 0.8)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).speed(0.5))
                                        .onAppear() {
                                            self.animateOuterFirst.toggle()
                                       }
                                    
                                    
                                    
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                                        
                                        .scaleEffect(animateInnerFirst ? 1 : 1.5)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).speed(1))
                                        .onAppear() {
                                            self.animateInnerFirst.toggle()
                                    }
                                    
                                    Circle()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    
                                    Image("pauseRecord")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .imageScale(.large)
                                        
                                        .font(Font.title.weight(.medium))
                                        .foregroundColor(.blue)
                                        .padding()
                                }
                                //when speech to text func is stopped
                                if (self.sToT == false) {
                                    Circle().frame(width: 100, height: 100)
                                        .foregroundColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
    
                                    
                                    Circle().frame(width: 60, height: 60)
                                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))

                                    
                                    Circle().frame(width: 50, height: 50)
                                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    
                                    Image("record").resizable()
                                        .frame(width: 35, height: 35)
                                        .imageScale(.large)
                                        .font(Font.title.weight(.medium))
                                        .foregroundColor(.blue)
                                        .padding()
                                }
                                
                                
                            }
                        }
                    }
                    Spacer()
                }
                
            }
            Section(header: Text("Date Visited")) {
                DatePicker(selection: $date, in: dateClosedRange, displayedComponents: .date, label: {Text("Date Visited")})
            }
            Section(header: Text("My Rating of current place")) {
                HStack {
                    Spacer()
                    Picker("", selection: $rating) {
                        ForEach(0 ..< ratingChoices.count, id: \.self) {
                            Text(self.ratingChoices[$0])
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .fixedSize()
                    Spacer()
                }
            }
            Section(header: Text("Take Notes by Recording Your Voice")) {
                HStack {
                    Spacer()
                
                Button(action: {

                    
                    do{
                        
                        if self.recordVoice{
                            
                            // Already Started Recording means stopping and saving...
                            
                            self.recorder.stop()
                            self.recordVoice = false
                            // updating data for every rcd...
                          
                            return
                        }
                        
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        // same file name...
                        // so were updating based on audio count...
                        //let filName = url.appendingPathComponent("myRcd(self.audios.count + 1).m4a")
                        idAndFilename = UUID()
                        let fileName = "idAndFilename.uuidString" + ".m4a"
                        let filName = url.appendingPathComponent(fileName)
                        self.audioURL = filName
                        let settings = [
                            
                            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : 12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                            
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: filName, settings: settings)
                        self.animateInnerSecond = true
                        self.animateOuterSecond = true
                        self.recorder.record()
                        self.recordVoice = true
                    }
                    catch{
                        
                        print(error.localizedDescription)
                    }
                }) {
                    VStack {
                        ZStack {
                            if (self.recordVoice == true) {
                                Circle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))
                                    .scaleEffect(animateOuterSecond ? 1 : 0.8)
                                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).speed(0.5))
                                    .onAppear() {
                                        self.animateOuterSecond.toggle()
                                    }
                                
                                
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))
                                    
                                    .scaleEffect(animateInnerSecond ? 1 : 1.5)
                                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).speed(1))
                                    .onAppear() {
                                        self.animateInnerSecond.toggle()
                                }
                                
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                
                                Image("pauseRecord")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.medium))
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            else {
                                Circle().frame(width: 100, height: 100)
                                    .foregroundColor(Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)))

                                
                                
                                Circle().frame(width: 60, height: 60)
                                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)))

                                
                                Circle().frame(width: 50, height: 50)
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                
                                Image("record").resizable()
                                    .frame(width: 35, height: 35)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.medium))
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                       
                        Text(recordVoice ? "Recording your voice... Tap to Stop!" : "Start Recording!")
                            .multilineTextAlignment(.center)
                    }
                }
                    Spacer()
                }
                
            }
           
            Section(header: Text("Add a Visit Photo")) {
                VStack {
                    Picker("photoPicker", selection: $takeOrPickIndex) {
                        ForEach(0 ..< photoChoices.count, id: \.self) {
                            Text(self.photoChoices[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                
                    Button(action: {
                        self.showPhotoPicker = true
                        print("it is \(self.takeOrPickIndex)")
                    }) {
                        Text("Get Photo")
                            .padding()
                    }
                }   // End of VStack
            }
            Section(header: Text("Campus Visit Photo")) {
                HStack {
                    Spacer()
                
                noteImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100.0, height: 100.0)
                Spacer()
                }
            }
        }.navigationBarItems(trailing: Button(action: {
            self.saveNewNote()
        }) {
            Text("Save")
            }.alert(isPresented: $showAlert) {
                Alert(title: Text(self.showAlertTitle),
                      message: Text(self.showAlertMessage),
                      dismissButton: .default(Text("OK")))
                    
            }
            
        ).navigationBarTitle("Add Note", displayMode: .inline)
            .navigationBarHidden(false)
            .sheet(isPresented: self.$showPhotoPicker) {
                /*
                 🔴 We pass $showPhotoPicker and $photo with $ sign into PhotoCaptureView
                 so that PhotoCaptureView can change them. The @Binding keywork in PhotoCaptureView
                 indicates that the input parameter passed is changeable (mutable).
                 */
                
                PhotoCaptureView(showImagePicker: self.$showPhotoPicker,
                                 photoImageData: self.$photo,
                                 cameraOrLibrary: self.photoChoices[self.takeOrPickIndex]).edgesIgnoringSafeArea(.all)
            }.onAppear() {
                do{
                    
                    // Intializing...
                    
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord)
                    
                    // requesting permission
                    // for this we require microphone usage description in info.plist...
                    self.session.requestRecordPermission { (status) in
                        
                        if !status{
                            self.showAudioPermissionAlert = true
                        }
                        else{
                            //permission granted, do nothing
                        }
                    }
                    
                    
                }
                catch{
                    
                    print(error.localizedDescription)
                }
            }
        .alert(isPresented: $showAudioPermissionAlert) {
            Alert(title: Text("Permission failed"),
                  message: Text("Please go to settings and change the audio permission!"),
                  dismissButton: .default(Text("OK")) {
                    exit(1)
                  })
                
        }
        
    }
    //note image
    var noteImage: Image {
        if let imageData = self.photo {
            let thumbnail = photoImageFromBinaryData(binaryData: imageData)
            return thumbnail
        } else {
            return Image("photoPlaceholder")
        }
    }
    //dismiss the keyboard
    func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    //when save button is tapped, check if anything is missing, if not, store the note into database
    func saveNewNote() {
        
        
        if self.title == "" {
            self.showAlert = true
            self.showAlertTitle = "Title missing"
            self.showAlertMessage = "Please write something down in the title section in order to save the note!"
            return
        }
        if self.description == "" {
            self.showAlert = true
            self.showAlertTitle = "Description missing"
            self.showAlertMessage = "Please complete description by typing or speech to text in order to save the note!"
            return
        }
        
        if self.audioURL == nil {
            self.showAlert = true
            self.showAlertTitle = "Audio missing"
            self.showAlertMessage = "Please record your voice in order to save the note!"
            return
        }
        
        
        
        let noteEntity = Note(context: managedObjectContext)
        
        noteEntity.id = UUID()
        
        
        // ❎ Dress it up by specifying its attributes
        noteEntity.noteTitle = self.title
       
        noteEntity.noteDescription = self.description
     
        // Instantiate a DateFormatter object
        let dateFormatter = DateFormatter()
        // Set the date format to yyyy-MM-dd at HH:mm:ss
        //dateFormatter.dateFormat = "yyyy-MM-dd' at 'HH:mm:ss"
        // Format the Date object as above and convert it to String
        
        // Set the date format to yyyy-MM-dd
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let datetime = dateFormatter.string(from: self.date)
        
        // Obtain DatePicker's selected date, format it as yyyy-MM-dd, and convert it to String
      
        
        noteEntity.rating = self.ratingChoices[self.rating]
        noteEntity.dateVisited = datetime
       
        noteEntity.lat = currentLocation().latitude as NSNumber?
        
        
        noteEntity.long = currentLocation().longitude as NSNumber?
        
        // ❎ Create an instance of the Thumbnail Entity in CoreData managedObjectContext
       let newPhotoAndAudio = PhotoAndAudio(context: self.managedObjectContext)
      
       // Obtain the URL of the park photo filename from main bundle
        if self.photo == nil {
            self.photo = UIImage(named: "photoPlaceholder")!.pngData()
        }
       if let imageData = self.photo {
                  newPhotoAndAudio.photo = imageData
              } else {

                print("ERROR CATCHED")
              }

        do {
           // Try to get the park audio data from audiourl created earlier
            newPhotoAndAudio.audio = try Data(contentsOf: audioURL!, options: NSData.ReadingOptions.mappedIfSafe)
         
            
            
         //now delete file
         do {
             try FileManager.default.removeItem(at: audioURL!)
         } catch let error as NSError {
             print("Error: \(error.domain)")
         }
        } catch {
             fatalError("Unable to save the audio!")
         }
  
       
        /*
         ==============================
         Establish Entity Relationships
         ==============================
        */
       
        // ❎ Establish Relationship between entities Song and Thumbnail
        noteEntity.photoAndAudio = newPhotoAndAudio
        newPhotoAndAudio.note = noteEntity
        
        /*
         ==================================
         Save Changes to Core Data Database
         ==================================
        */
       
        // ❎ CoreData Save operation
        do {
            try self.managedObjectContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error)
            return
        }
    }
    /*
     ----------------------------------
     MARK: - Start Voice Memo Recording
     ----------------------------------
     */
    func startRecording() {
        
        idAndFilename = UUID()
        let filename = "idAndFilename.uuidString" + ".m4a"
        audioURL = documentDirectory.appendingPathComponent(filename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder.record()
        } catch {
            finishRecording()
        }
    }
    
    /*
     -----------------------------------
     MARK: - Finish Voice Memo Recording
     -----------------------------------
     */
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        self.recordVoice = false
    }
    
    func photoImageFromBinaryData(binaryData: Data?) -> Image {
        
        // Create a UIImage object from binaryData
        let uiImage = UIImage(data: binaryData!)
        
        // Unwrap uiImage to see if it has a value
        if let imageObtained = uiImage {
            
            // Image is successfully obtained
            return Image(uiImage: imageObtained)
            
        } else {
            return Image("DefaultParkPhoto")
        }
        
    }
    /*
     ------------------------
     MARK: - Cancel Recording
     ------------------------
     */
    func cancelRecording() {
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionTask?.finish()
    }
    /*
     ----------------------------------------------
     MARK: - Record Audio and Transcribe it to Text
     ----------------------------------------------
     */
    func recordAndRecognizeSpeech() {
        //--------------------
        // Set up Audio Buffer
        //--------------------
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        //---------------------
        // Prepare Audio Engine
        //---------------------
        audioEngine.prepare()
        
        //-------------------
        // Start Audio Engine
        //-------------------
        do {
            try audioEngine.start()
        } catch {
            print("Unable to start Audio Engine!")
            return
        }
        
        //-------------------------------
        // Convert recorded voice to text
        //-------------------------------
        recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { result, error in
            
            if result != nil {  // check to see if result is empty (i.e. no speech found)
                if let resultObtained = result {
                    let bestString = resultObtained.bestTranscription.formattedString
                    self.description = bestString
                    
                } else if let error = error {
                    print("Transcription failed, but will continue listening and try to transcribe. See \(error)")
                }
            }
        })
    }
    
}


/*
 ************************************************************
 MARK: - Obtain and Return User's Current Location Coordinate
 ************************************************************
 */
public func currentLocation() -> CLLocationCoordinate2D {
    /*
     IMPORTANT NOTE: Current GPS location cannot be accurately determined under the iOS Simulator
     on your laptop or desktop computer because those computers do NOT have a GPS antenna.
     Therefore, do NOT expect the code herein to work under the iOS Simulator!
     
     You must deploy your location-aware app to an iOS device to be able to test it properly.
     
     Monitoring the user's current location is a serious privacy issue!
     You are required to get the user's permission in two ways:
     
     (1) requestWhenInUseAuthorization:
     (a) Ask your locationManager to request user's authorization while the app is being used.
     (b) Add a new row in the Info.plist file for "Privacy - Location When In Use Usage Description", for which you specify
     
     (2) requestAlwaysAuthorization:
     (a) Ask your locationManager to request user's authorization even when the app is not being used.
     (b) Add a new row in the Info.plist file for "Privacy - Location Always Usage Description", for which you specify
     You select and use only one of these two options depending on your app's requirement.
     */
    
    // Instantiate a CLLocationCoordinate2D object with initial values
    var currentLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    /*
     The user can turn off location services on an iOS device in Settings.
     First, you must check to see of it is turned off or not.
     */
    if CLLocationManager.locationServicesEnabled() {
        
        // Set up locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        // Ask locationManager to obtain the user's current location coordinate
        if let location = locationManager.location {
            currentLocationCoordinate = location.coordinate
        } else {
            print("Unable to obtain user's current location")
        }
        
    } else {
        // Location Services turned off in Settings
    }
    // Stop updating location when not needed to save battery of the device
    locationManager.stopUpdatingLocation()
    
    return currentLocationCoordinate
}
/*
 ************************************************************
 MARK: - Obtain and Return User's Current Location Coordinate in CLLocation
 ************************************************************
 */
public func currentLocationCL() -> CLLocation {
    /*
     IMPORTANT NOTE: Current GPS location cannot be accurately determined under the iOS Simulator
     on your laptop or desktop computer because those computers do NOT have a GPS antenna.
     Therefore, do NOT expect the code herein to work under the iOS Simulator!
     
     You must deploy your location-aware app to an iOS device to be able to test it properly.
     
     Monitoring the user's current location is a serious privacy issue!
     You are required to get the user's permission in two ways:
     
     (1) requestWhenInUseAuthorization:
     (a) Ask your locationManager to request user's authorization while the app is being used.
     (b) Add a new row in the Info.plist file for "Privacy - Location When In Use Usage Description", for which you specify
     
     (2) requestAlwaysAuthorization:
     (a) Ask your locationManager to request user's authorization even when the app is not being used.
     (b) Add a new row in the Info.plist file for "Privacy - Location Always Usage Description", for which you specify
     You select and use only one of these two options depending on your app's requirement.
     */
    
    // Instantiate a CLLocationCoordinate2D object with initial values
    var currentLocation = CLLocation()
    
    /*
     The user can turn off location services on an iOS device in Settings.
     First, you must check to see of it is turned off or not.
     */
    if CLLocationManager.locationServicesEnabled() {
        
        // Set up locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        // Ask locationManager to obtain the user's current location coordinate
        if let location = locationManager.location {
            currentLocation = location
        } else {
            print("Unable to obtain user's current location")
        }
        
    } else {
        // Location Services turned off in Settings
    }
    // Stop updating location when not needed to save battery of the device
    locationManager.stopUpdatingLocation()
    
    return currentLocation
}
