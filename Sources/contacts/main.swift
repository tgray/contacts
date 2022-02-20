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

extension String {
  func stripWhitespace() -> String {
    return self.components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: "")
  }
}

extension String {
    var letters: String {
        return String(unicodeScalars.filter(CharacterSet.letters.contains))
    }
}


func slugName(name: String, n: Int) -> String {
  let  slug = name.lowercased().stripWhitespace().appending("\(n + 1)")
/* 
  if n > 0 {
    slug = slug.appending("\(n + 1)")
  }
 */
  return slug
}

var searchTerm = options.searchTerm

if options.all {
  searchTerm = "*"
}


/* 
for (i, arg) in arguments.enumerated() {
  if helpArgs.contains(arg) {
    print("Usage: \(processName) <options> search_term\n")
    print(
"""
  -h, --help    display this help
  -v, --version   display version
  -a, --alias   results in mutt alias format
    --all     prints all entries
  -g, --group   prints email addresses of GROUP members
  -m, --mutt    print results in mutt query compatible format (adds header line)
"""      )
    exit(0)
  } else if versionArgs.contains(arg) {
    print("\(versionInfo.version) (\(versionInfo.build))")
    exit(0)      
  } else if muttArgs.contains(arg) {
    muttFormat = true
    usedargs.append(arg)
//      print("mutt")
  } else if groupArgs.contains(arg) {
    groupList = true
    usedargs.append(arg)
//      print("group")
  } else if allArgs.contains(arg) {
    printAll = true
    usedargs.append(arg)
  } else if aliasArgs.contains(arg) {
    aliasFormat = true
    usedargs.append(arg)
//      print("alias")
  } 
}

var set1:Set<String> = Set(arguments)
var set2:Set<String> = Set(usedargs)

//let otherargs = Array(set1.subtract(set2))
let otherargs = arguments.filter { !usedargs.contains($0)}
var searchterm = otherargs.last

if printAll == true {
  searchterm = "*"
}
 */

//print(otherargs.last ?? "")

let store = CNContactStore()
let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey,
  CNContactNicknameKey, CNContactEmailAddressesKey,
  CNContactOrganizationNameKey, CNGroupNameKey] as [CNKeyDescriptor]

let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
var contacts = [CNContact]()

do {
  try store.enumerateContacts(with: fetchRequest) { contact, stop in
          if contact.emailAddresses.count > 0 {
              contacts.append(contact)
          }
      }
  } catch let e as NSError {
      print(e.localizedDescription)
  }
  
var results = [CNContact]()


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
      for (i, email) in c.emailAddresses.enumerated() {
        groupmembers.append("\(email.value)")
      }
    }
    print(groupmembers.joined(separator: " "))
  }
}


} else { 
var stringToSearch = ""

// Get all the contacts, make a string of the info we want to search, and
//  search it.

for c in contacts {
  for (i, email) in c.emailAddresses.enumerated() {
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



//let predicate = CNContact.predicateForContactsInGroup(withIdentifier: "NASA")

//do {
// let predicate = CNContact.predicateForContacts(matchingName: "evan")
// let contacts = try store.unifiedContacts(matching: predicate,
//   keysToFetch: keysToFetch)
// 
////    print("Fetched contacts: \(contacts)")
//  if options.mutt {
//    print("Results:")
//  }
//  for cont in contacts {
//    for (i, email) in cont.emailAddresses.enumerated() {
//      if options.alias{
//      let slugged = slugName(name: "\(cont.givenName) \(cont.familyName)", n: i)
//      print("alias \(slugged)\t\(cont.givenName) \(cont.familyName)\t<\(email.value)>")
//      } else {
//        print("\(email.value)\t\(cont.givenName) \(cont.familyName)")
//      }
//    }
//  }
//
//} catch {
//  print("Failed to fetch contact, error: \(error)")
//  // Handle the error
//}

