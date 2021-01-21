//
//  SearchDatabase.swift
//  VTQuest
//
//  Created by Zhennan Yao on 5/22/20.
//  Copyright © 2020 Zhennan Yao. All rights reserved.
//

import SwiftUI

struct SearchDatabase: View {
    var body: some View {
//        ZStack {
//            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
      // NavigationView {
            List {
                 //Color.green.opacity(0.1).edgesIgnoringSafeArea(.all)
                HStack {
                    Spacer()
                    Text("Search VT Buildings Database")
                    Spacer()
                }
                HStack {
                    Spacer()
                    VStack {
                        Image("SearchDatabase")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 300, maxWidth: 500, minHeight: 100, maxHeight: 200, alignment: .center)
                            .padding()
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: ByName()) {
                            HStack {
                                Image(systemName: "magnifyingglass.circle")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Name")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: ByNameOrDescription()) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Name or Description")
                            }
                        }
                    }
                    Spacer()

                }
                
                HStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: ByAbbreviation()) {
                            HStack {
                                Image(systemName: "a.circle")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Name Abbreviation")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: ByCategory()) {
                            HStack {
                                Image(systemName: "square.stack.3d.down.right")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Category")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        
                        NavigationLink(destination: ByAddress()) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Address")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        
                        NavigationLink(destination: ByYearBuilt()) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Year Building was Built")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        
                        NavigationLink(destination: ByYearRange()) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Year Range Building was Built")
                            }
                        }
                    }
                    Spacer()

                }
                HStack {
                    Spacer()
                    VStack {
                        
                        NavigationLink(destination: ByCategoryAndYearRange()) {
                            HStack {
                                Image(systemName: "rectangle.on.rectangle")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                                    .font(Font.title.weight(.regular))
                                    .frame(width: 60)
                                Text("Search by Building Category and Year Range Building was Built")
                            }
                        }
                    }
                    Spacer()

                }
            
                
                
                
               
            
            }   // End of List
                .background(Color.green)
                .font(.system(size: 16, weight: .regular))
                .navigationBarTitle(Text("Search VT Buildings Database"), displayMode: .inline)
            .navigationBarHidden(true)
                //.padding()
                // Remove the List separator lines only for this view
//                .onAppear { UITableView.appearance().separatorStyle = .none }
//                // Undo the List separator lines removal for other views
//                .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
            
        //}   // End of NavigationView
            // Use single column navigation view for iPhone and iPad
            .navigationViewStyle(StackNavigationViewStyle())
//            
//        }   // End of ZStack
    }   // End of body
}

struct SearchDatabase_Previews: PreviewProvider {
    static var previews: some View {
        SearchDatabase()
    }
}
