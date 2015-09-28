//
//  ComicStrip.swift
//  Webcomic
//
//  Created by Niranjan Ravichandran on 22/09/15.
//  Copyright © 2015 Niranjan. All rights reserved.
//
//Model for
import Foundation

struct ComicStrip {
    let title: String?
    let imgURL: NSURL?
    let transcript: String?
    let year: String?
    
    init(jsonResponse: NSDictionary){
        
        title = jsonResponse["title"] as? String
        imgURL = NSURL(string: jsonResponse["img"] as! String)
        transcript = jsonResponse["transcript"] as? String
        year = jsonResponse["year"] as? String
        
    }
}
