//  main.swift
//  contacts
//
//  Created by Tim Gray on 2/19/22.
//  Copyright (c) 2022 Tim Gray. All rights reserved.
//

import Foundation
import ArgumentParser
import Contacts

let processName = ProcessInfo.processInfo.processName

struct ContactsOptions: ParsableArguments {
  @Flag(name: [.customShort("m"), .long],
  help: "print results in mutt query compatible format (adds header line)"
  ) var mutt = false
  
  @Flag(name: [.customShort("a"), .long],
  help: "results in mutt alias format"
  ) var alias = false
  
  @Flag(name: [.customShort("g"), .long],
  help: "prints email addresses of searched group"
  ) var group = false
  
  @Flag(name: .long,
  help: "prints all entries"
  ) var all = false
  
  @Flag(name: .shortAndLong,
  help: "display version"
  ) var version = false  
  
  @Argument var searchTerm: String?
}

let options = ContactsOptions.parseOrExit()


// Get version info from the json file that is populated with version.sh.  
if options.version {
  struct versionNum: Codable {
    let version: String
    let build: String
  }

  let filePath = Bundle.module.path(forResource: "version", ofType: "json")
  let contentData = FileManager.default.contents(atPath: filePath!)
  let jsonDecoder = JSONDecoder()
  let versionInfo = try jsonDecoder.decode(versionNum.self, from: contentData!)
  
  print("\(processName) \(versionInfo.version) (\(versionInfo.build))")
  exit(0)
}

//
// MARK - FUNCTIONS
//

// Strip all white space from a string
extension String {
  func stripWhitespace() -> String {
    return self.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: "")
  }
}

// Strip non letters from a string
extension String {
    var letters: String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
}

// Create a slugname for a contact.  Remove spaces, make it lower case, and
// append a number
func slugName(name: String, n: Int) -> String {
  let  slug = name.lowercased().stripWhitespace().appending("\(n + 1)")
  return slug
}

//
// MARK - SETUP
//

// Get the search term, set up the contact store, and keys to fetch
var searchTerm = options.searchTerm

let store = CNContactStore()
let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey,
  CNContactNicknameKey, CNContactEmailAddressesKey,
  CNContactOrganizationNameKey, CNGroupNameKey] as [CNKeyDescriptor]

let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
var contacts = [CNContact]()
var results = [CNContact]()

// Get all the contacts with email addresses.
// This should probably be moved down to the people search section, but oh well.
do {
  try store.enumerateContacts(with: fetchRequest) { contact, stop in
          if contact.emailAddresses.count > 0 {
              contacts.append(contact)
          }
      }
  } catch let e as NSError {
      print(e.localizedDescription)
  }

// 
// MARK - GROUPS
//
// If searching for groups, get all the groups, or just the ones that match the
// search terms.
if options.group {
  let groups = try store.groups(matching: nil)
  var groupresults = [CNGroup]()

  for g in groups {
    if options.all {
      groupresults = groups
    } else {
      if g.name.lowercased().contains(searchTerm!.lowercased()) {
        groupresults.append(g)
      }
    }
  }

  // Fetch the members in a group, get their email address, and print them out.
  var groupmembers = [String]()
  for g in groupresults {
    let gpred = CNContact.predicateForContactsInGroup(withIdentifier: g.identifier)
    contacts = try store.unifiedContacts(matching: gpred, keysToFetch: keysToFetch)
    if !contacts.isEmpty {
      if options.alias {
        let gname = g.name.lowercased().letters
        print("group -group \(gname) -addr ", terminator: "")
      }
      for c in contacts {
        for email in c.emailAddresses {
          groupmembers.append("\(email.value)")
        }
      }
      print(groupmembers.joined(separator: " "))
    }
  }
  
} else {

//
// MARK - PEOPLE SEARCH
//
var stringToSearch = ""

// Get all the contacts, make a string of the info we want to search, and
// search it.

  for c in contacts {
    for email in c.emailAddresses {
      stringToSearch = "\(c.givenName) \(c.familyName) \(c.nickname) \(email.value) \(c.organizationName)"
      if options.all {
        results = contacts
      } else {
        if stringToSearch.lowercased().contains(searchTerm!.lowercased()) {
          if !results.contains(c) {
            results.append(c)
          }
        }
      }
    }
  }

  if options.mutt {
   print("Results:")
  }

  // Print out the matches.
  for c in results {
    for (i, email) in c.emailAddresses.enumerated() {
      if options.alias{
        let slugged = slugName(name: "\(c.givenName) \(c.familyName)", n: i)
        print("alias \(slugged)\t\(c.givenName) \(c.familyName)\t<\(email.value)>")
      } else {
        print("\(email.value)\t\(c.givenName) \(c.familyName)")
      }
    }
  }
}
