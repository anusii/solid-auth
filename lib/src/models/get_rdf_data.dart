/// A class for Pod Profile data.
///
/// Copyright (C) 2023 Software Innovation Institute, Australian National University
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Zheyuan Xu

import 'package:rdflib/rdflib.dart';

class PodProfile {
  String profileRdfStr = '';

  PodProfile(String profileRdfStr) {
    this.profileRdfStr = profileRdfStr;
  }

  List<dynamic> divideRdfData(String profileRdfStr) {
    List<String> rdfDataList = [];
    String vcardPrefix = '';
    String foafPrefix = '';

    var profileDataList = profileRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('<http://www.w3.org/2006/vcard/ns#>')) {
        var itemList = dataItem.split(' ');
        vcardPrefix = itemList[1];
      }

      if (dataItem.contains('<http://xmlns.com/foaf/0.1/>')) {
        var itemList = dataItem.split(' ');
        foafPrefix = itemList[1];
      }
    }
    return [rdfDataList, vcardPrefix, foafPrefix];
  }

  List<dynamic> dividePrvRdfData() {
    List<String> rdfDataList = [];
    final Map prefixList = {};

    var profileDataList = profileRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('@prefix')) {
        //print('here');
        var itemList = dataItem.split(' ');
        //print(itemList);
        prefixList[itemList[1]] = itemList[2];
      }

      // if (dataItem.contains('<http://www.w3.org/ns/ldp#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['ldPlatform'] = itemList[1];
      // }

      // if (dataItem.contains('<http://www.w3.org/ns/posix/stat#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['stat'] = itemList[1];
      // }

      // if (dataItem.contains('<http://www.w3.org/2001/XMLSchema#>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['xmlSchema'] = itemList[1];
      // }

      // if (dataItem.contains('<>')) {
      //   var itemList = dataItem.split(' ');
      //   prefixList['prv'] = itemList[1];
      // }
    }
    return [rdfDataList, prefixList];
  }

  String getProfPicture() {
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    String foafPrefix = rdfRes[2];
    String pictureUrl = '';
    String optionalPictureUrl = '';
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + 'hasPhoto')) {
        var itemList = dataItem.split('<');
        pictureUrl = itemList[1].replaceAll('>', '');
      }
      if (dataItem.contains(foafPrefix + 'img')) {
        var itemList = dataItem.split('<');
        optionalPictureUrl = itemList[1].replaceAll('>', '');
      }
    }
    if (pictureUrl.isEmpty & optionalPictureUrl.isNotEmpty) {
      pictureUrl = optionalPictureUrl;
    }
    return pictureUrl;
  }

  String getProfName() {
    String profName = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    // String foafPrefix = rdfRes[2];

    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + 'fn')) {
        var itemList = dataItem.split('"');
        profName = itemList[1];
      }
    }
    if (profName.isEmpty) {
      profName = 'John Doe';
    }
    return profName;
  }

  String getPersonalInfo(String infoLabel) {
    String personalInfo = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + infoLabel)) {
        var itemList = dataItem.split('"');
        personalInfo = itemList[1];
      }
    }
    return personalInfo;
  }

  String getAddressId(String infoLabel) {
    String personalInfo = '';
    var rdfRes = divideRdfData(profileRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String vcardPrefix = rdfRes[1];
    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(vcardPrefix + infoLabel)) {
        var itemList = dataItem.split(':');
        personalInfo = itemList[2];
      }
    }
    return personalInfo;
  }

  String getEncKeyHash() {
    String encKeyHash = '';

    if (profileRdfStr.contains('@prefix')) {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('sh-data:encKey')) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    } else {
      var rdfDataList = profileRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://yarrabah.net/predicates/terms#encKey')) {
          var itemList = dataItem.trim().split(' ');
          encKeyHash = itemList[1].trim().split('"')[1];
        }
      }
    }
    return encKeyHash;
  }
}
// Temporarily comment out
// class EncProfile {
//   String profileRdfStr = '';

//   EncProfile(String profileRdfStr) {
//     this.profileRdfStr = profileRdfStr;
//   }

//   String getEncKeyHash() {
//     String encKeyHash = '';

//     if (profileRdfStr.contains('@prefix')) {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem.contains('sh-data:encKey')) {
//           var itemList = dataItem.trim().split(' ');
//           encKeyHash = itemList[1].trim().split('"')[1];
//         }
//       }
//     } else {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem.contains('http://yarrabah.net/predicates/terms#encKey')) {
//           var itemList = dataItem.trim().split(' ');
//           encKeyHash = itemList[1].trim().split('"')[1];
//         }
//       }
//     }
//     return encKeyHash;
//   }

//   String getEncFileHash() {
//     String encFileHash = '';

//     if (profileRdfStr.contains('@prefix')) {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem.contains('sh-data:encFiles')) {
//           var itemList = dataItem.trim().split(' ');
//           encFileHash = itemList[1].trim().split('"')[1];
//         }
//       }
//     } else {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem
//             .contains('http://yarrabah.net/predicates/terms#encFiles')) {
//           var itemList = dataItem.trim().split(' ');
//           encFileHash = itemList[1].trim().split('"')[1];
//         }
//       }
//     }
//     return encFileHash;
//   }

//   String getEncFileCont() {
//     String encFileCont = '';

//     if (profileRdfStr.contains('@prefix')) {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem.contains('sh-data:encVal')) {
//           var itemList = dataItem.trim().split(' ');
//           encFileCont = itemList[2].trim().split('"')[1];
//         }
//       }
//     } else {
//       var rdfDataList = profileRdfStr.split('\n');
//       for (var i = 0; i < rdfDataList.length; i++) {
//         String dataItem = rdfDataList[i];

//         if (dataItem.contains('http://yarrabah.net/predicates/terms#encVal')) {
//           var itemList = dataItem.trim().split(' ');
//           encFileCont = itemList[2].trim().split('"')[1];
//         }
//       }
//     }
//     return encFileCont;
//   }
// }

class SurveyData {
  String surveyRdfStr = '';

  SurveyData(String surveyRdfStr) {
    this.surveyRdfStr = surveyRdfStr;
  }

  List<dynamic> divideSurveyRdfData(String surveyRdfStr) {
    List<String> rdfDataList = [];
    String vcardPrefix = '';
    String foafPrefix = '';
    String siloPrefix = '';
    String smedPrefix = '';
    String surveyPrefix = '';
    var profileDataList = surveyRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('<http://www.w3.org/2006/vcard/ns#>')) {
        var itemList = dataItem.split(' ');
        vcardPrefix = itemList[1];
      }

      if (dataItem.contains('<http://xmlns.com/foaf/0.1/>')) {
        var itemList = dataItem.split(' ');
        foafPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/terms#>')) {
        var itemList = dataItem.split(' ');
        siloPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/survey#>')) {
        var itemList = dataItem.split(' ');
        surveyPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/medical#>')) {
        var itemList = dataItem.split(' ');
        smedPrefix = itemList[1];
      }
    }
    return [
      rdfDataList,
      vcardPrefix,
      foafPrefix,
      siloPrefix,
      smedPrefix,
      surveyPrefix
    ];
  }

  Map getVcardInfo() {
    Map vcardDict = {};

    if (surveyRdfStr.contains('@prefix')) {
      var rdfRes = divideSurveyRdfData(surveyRdfStr);
      List<String> rdfDataList = rdfRes.first;
      String vcardPrefix = rdfRes[1];
      String foafPrefix = rdfRes[2];

      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];
        if ((dataItem.contains(vcardPrefix) |
                dataItem.contains(foafPrefix + 'name')) &
            !dataItem.contains('@prefix')) {
          var itemList = dataItem.split('"');
          var itemName = itemList.first.split(':')[1];
          itemName = itemName.replaceAll(' ', '');
          var itemVal = itemList[1];
          //itemVal = itemVal.replaceAll(' ', '');
          vcardDict[itemName] = itemVal;
        }
      }
    } else {
      var rdfDataList = surveyRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://www.w3.org/2006/vcard/ns#')) {
          var itemList = dataItem.trim().split(' ');
          var itemName = itemList.first.split('#')[1];
          itemName = itemName.replaceAll('>', '');
          var itemVal = itemList[1].split('"')[1];
          //itemVal = itemVal.replaceAll(' ', '');
          vcardDict[itemName] = itemVal;
        } else if (dataItem.contains('http://xmlns.com/foaf/0.1/name')) {
          var itemList = dataItem.trim().split('>');
          var itemVal = itemList[1].trim().split('"')[1];
          vcardDict['name'] = itemVal;
        }
      }
    }
    return vcardDict;
  }

  Map getSurveyInfo() {
    Map surveyDict = {};

    if (surveyRdfStr.contains('@prefix')) {
      var rdfRes = divideSurveyRdfData(surveyRdfStr);
      List<String> rdfDataList = rdfRes.first;
      String surveyPrefix = rdfRes[5];

      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];
        if (dataItem.contains(surveyPrefix) & !dataItem.contains('@prefix')) {
          var itemList = dataItem.split('"');
          var itemName = itemList.first.split(':')[1];
          itemName = itemName.replaceAll(' ', '');
          //print(itemList);
          var itemVal = itemList[1];
          //itemVal = itemVal.replaceAll(' ', '');
          surveyDict[itemName] = itemVal;
        }
      }
    } else {
      var rdfDataList = surveyRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://yarrabah.net/predicates/survey#')) {
          var itemList = dataItem.trim().split('>');
          //print(itemList);
          var itemName = itemList.first.split('#')[1];
          itemName = itemName.replaceAll('>', '');
          var itemVal = itemList[1].trim().split('"')[1];
          //itemVal = itemVal.replaceAll(' ', '');
          surveyDict[itemName] = itemVal;
        }
      }
    }
    return surveyDict;
  }

  Map getMedInfo() {
    Map medDict = {};
    var rdfRes = divideSurveyRdfData(surveyRdfStr);
    List<String> rdfDataList = rdfRes.first;
    String smedPrefix = rdfRes[4];

    for (var i = 0; i < rdfDataList.length; i++) {
      String dataItem = rdfDataList[i];
      if (dataItem.contains(smedPrefix) & !dataItem.contains('@prefix')) {
        var itemList = dataItem.split('"');
        var itemName = itemList.first.split(':')[1];
        itemName = itemName.replaceAll(' ', '');
        var itemVal = itemList[1];
        itemVal = itemVal.replaceAll(' ', '');
        medDict[itemName] = itemVal;
      }
    }

    return medDict;
  }
}

/// HealthDat is a simple copy of SurveyData
class HealthData {
  String medRdfStr = '';

  HealthData(String medRdfStr) {
    this.medRdfStr = medRdfStr;
  }

  List<dynamic> divideSurveyRdfData(String medRdfStr) {
    List<String> rdfDataList = [];
    String vcardPrefix = '';
    String foafPrefix = '';
    String siloPrefix = '';
    String smedPrefix = '';
    String sanalyticPrefix = '';
    var profileDataList = medRdfStr.split('\n');
    for (var i = 0; i < profileDataList.length; i++) {
      String dataItem = profileDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      if (dataItem.contains('<http://www.w3.org/2006/vcard/ns#>')) {
        var itemList = dataItem.split(' ');
        vcardPrefix = itemList[1];
      }

      if (dataItem.contains('<http://xmlns.com/foaf/0.1/>')) {
        var itemList = dataItem.split(' ');
        foafPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/terms#>')) {
        var itemList = dataItem.split(' ');
        siloPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/medical#>')) {
        var itemList = dataItem.split(' ');
        smedPrefix = itemList[1];
      }

      if (dataItem.contains('<http://yarrabah.net/predicates/analytic#>')) {
        var itemList = dataItem.split(' ');
        sanalyticPrefix = itemList[1];
      }
    }
    return [
      rdfDataList,
      vcardPrefix,
      foafPrefix,
      siloPrefix,
      smedPrefix,
      sanalyticPrefix,
    ];
  }

  Map getVcardInfo() {
    Map vcardDict = {};

    if (medRdfStr.contains('@prefix')) {
      var rdfRes = divideSurveyRdfData(medRdfStr);
      List<String> rdfDataList = rdfRes.first;
      String vcardPrefix = rdfRes[1];
      String foafPrefix = rdfRes[2];

      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];
        if ((dataItem.contains(vcardPrefix) |
                dataItem.contains(foafPrefix + 'name')) &
            !dataItem.contains('@prefix')) {
          var itemList = dataItem.split('"');
          var itemName = itemList.first.split(':')[1];
          itemName = itemName.replaceAll(' ', '');
          var itemVal = itemList[1];
          //itemVal = itemVal.replaceAll(' ', '');
          vcardDict[itemName] = itemVal;
        }
      }
    } else {
      var rdfDataList = medRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://www.w3.org/2006/vcard/ns#')) {
          var itemList = dataItem.trim().split(' ');
          var itemName = itemList.first.split('#')[1];
          itemName = itemName.replaceAll('>', '');
          var itemVal = itemList[1].split('"')[1];
          //itemVal = itemVal.replaceAll(' ', '');
          vcardDict[itemName] = itemVal;
        } else if (dataItem.contains('http://xmlns.com/foaf/0.1/name')) {
          var itemList = dataItem.trim().split('>');
          var itemVal = itemList[1].trim().split('"')[1];
          vcardDict['name'] = itemVal;
        }
      }
    }
    return vcardDict;
  }

  Map getSurveyInfo() {
    Map surveyDict = {};

    if (medRdfStr.contains('@prefix')) {
      var rdfRes = divideSurveyRdfData(medRdfStr);
      List<String> rdfDataList = rdfRes.first;
      String surveyPrefix = rdfRes[5];

      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];
        if (dataItem.contains(surveyPrefix) & !dataItem.contains('@prefix')) {
          var itemList = dataItem.split('"');
          var itemName = itemList.first.split(':')[1];
          itemName = itemName.replaceAll(' ', '');
          //print(itemList);
          var itemVal = itemList[1];
          //itemVal = itemVal.replaceAll(' ', '');
          surveyDict[itemName] = itemVal;
        }
      }
    } else {
      var rdfDataList = medRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains('http://yarrabah.net/predicates/survey#')) {
          var itemList = dataItem.trim().split('>');
          //print(itemList);
          var itemName = itemList.first.split('#')[1];
          itemName = itemName.replaceAll('>', '');
          var itemVal = itemList[1].trim().split('"')[1];
          //itemVal = itemVal.replaceAll(' ', '');
          surveyDict[itemName] = itemVal;
        }
      }
    }
    return surveyDict;
  }

  Map getFileInfo(String filePrefix) {
    Map medDict = {};

    if (medRdfStr.contains('@prefix')) {
      var rdfRes = divideSurveyRdfData(medRdfStr);
      List<String> rdfDataList = rdfRes.first;
      String smedPrefix = rdfRes[4];

      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];
        if (dataItem.contains(smedPrefix) & !dataItem.contains('@prefix')) {
          var itemList = dataItem.split('"');
          var itemName = itemList.first.split(':')[1];
          itemName = itemName.replaceAll(' ', '');
          var itemVal = itemList[1];
          itemVal = itemVal.replaceAll(' ', '');
          medDict[itemName] = itemVal;
        }
      }
    } else {
      var rdfDataList = medRdfStr.split('\n');
      for (var i = 0; i < rdfDataList.length; i++) {
        String dataItem = rdfDataList[i];

        if (dataItem.contains(filePrefix)) {
          var itemList = dataItem.trim().split('>');
          //print(itemList);
          var itemName = itemList.first.split('#')[1];
          itemName = itemName.replaceAll('>', '');
          var itemVal = itemList[1].trim().split('"')[1];
          //itemVal = itemVal.replaceAll(' ', '');
          medDict[itemName] = itemVal;
        }
      }
    }

    return medDict;
  }

  Map getAnalyticInfo() {
    Map medDict = {};

    Graph g = Graph();
    // parse the long text string into Graph
    g.parseTurtle(medRdfStr);
    // the part that has health data, e.g., bmi, blood pressure
    Namespace predicate_ns =
        Namespace(ns: 'http://yarrabah.net/predicates/analytic#');
    // after parsing, loop through all triples to find corresponding records
    for (Triple t in g.triples) {
      if (t.pre.inNamespace(predicate_ns)) {
        // because we know that the data we're interested in has a predicate of a certain form
        // so just check if it's in the corresponding namespace,
        // and then extract the relevant part
        String attribute = t.pre.value.split("#").last;
        String value = t.obj.value;
        medDict[attribute] = value;
      }
    }

    return medDict;
  }
}

class AclResource {
  String aclResStr = '';

  AclResource(String aclResStr) {
    this.aclResStr = aclResStr;
  }

  List divideAclData() {
    Map<String, String> userNameMap = {};
    Map<String, List> userPermMap = {};

    RegExp prefixRegExp = new RegExp(
      r"@prefix ([a-zA-Z0-9: <>#].*)",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp accessGroupRegExp = new RegExp(
      r"(?<=^:[a-zA-Z]+\n)(?:^\s+.*;$\n)*(?:^\s+.*\.\n?)",
      caseSensitive: false,
      multiLine: true,
    );

    Iterable<RegExpMatch> accessGroupList =
        accessGroupRegExp.allMatches(aclResStr);
    Iterable<RegExpMatch> prefixList = prefixRegExp.allMatches(aclResStr);

    for (final prefixItem in prefixList) {
      String prefixLine = prefixItem[0].toString();
      if (prefixLine.contains('/card#>')) {
        var itemList = prefixLine.split(' ');
        userNameMap[itemList[1]] =
            itemList[2].substring(0, itemList[2].length - 1);
      }
    }

    for (final accessGroup in accessGroupList) {
      String accessGroupStr = accessGroup[0].toString();

      RegExp accessRegExp = new RegExp(
        r"acl:access[T|t]o (?<resource><[a-zA-Z0-9_-]*.[a-z]*>)",
        caseSensitive: false,
        multiLine: false,
      );

      RegExp modeRegExp = new RegExp(
        r"acl:mode ([^.]*)",
        caseSensitive: false,
        multiLine: false,
      );

      RegExp agentRegExp = new RegExp(
        r"acl:agent[a-zA-Z]*? ([^;]*);",
        caseSensitive: false,
        multiLine: false,
      );

      Iterable<RegExpMatch> accessPers = agentRegExp.allMatches(accessGroupStr);
      Iterable<RegExpMatch> accessRes = accessRegExp.allMatches(accessGroupStr);
      Iterable<RegExpMatch> accessModes = modeRegExp.allMatches(accessGroupStr);

      for (final accessModesItem in accessModes) {
        List accessList = accessModesItem[1].toString().split(',');
        List accessItemList = [];
        Set accessItemSet = {};
        for (String accessItem in accessList) {
          accessItemList.add(accessItem.replaceAll('acl:', '').trim());
          accessItemSet.add((accessItem).trim());
        }
        accessItemList.sort();
        String accessStr = accessItemList.join('');

        Set accessResItemSet = {};
        for (final accessResItem in accessRes) {
          List accessResList = accessResItem[1].toString().split(',');
          for (String accessItem in accessResList) {
            accessResItemSet.add(accessItem.trim());
          }
        }

        Set accessPersItemSet = {};
        for (final accessPersItem in accessPers) {
          List accessPersList = accessPersItem[1].toString().split(',');
          for (String accessItem in accessPersList) {
            accessPersItemSet.add(accessItem.replaceAll('me', '').trim());
          }
        }
        userPermMap[accessStr] = [
          accessResItemSet,
          accessPersItemSet,
          accessItemSet
        ];
      }
    }
    // print('full permission map');
    // print(userPermMap);

    // int j = 0;
    // for (final m in accessModes) {
    //   List accessList = m[1].toString().split(',');
    //   List accessItemList = [];
    //   for (String accessItem in accessList){
    //     accessItemList.add(accessItem.replaceAll('acl:', '').trim());
    //   }
    //   accessItemList.sort();
    //   String accessStr = accessItemList.join('');

    //   // Getting resources list for the specific access mode
    //   int a = 0;
    //   List accessResItemList = [];
    //   for (final n in accessRes) {
    //     print(n[1].toString());
    //     if(a == j){
    //       List accessResList = n[1].toString().split(',');

    //       for (String accessItem in accessResList){
    //         accessResItemList.add(accessItem.trim());
    //       }
    //       a+=1;
    //     }
    //     else{
    //       a+=1;
    //       continue;
    //     }
    //   }

    //   // Getting user list for the specific access mode
    //   int b = 0;
    //   List accessPersItemList = [];
    //   for (final n in accessPers) {
    //     print(n[1].toString());
    //     if(b == j){
    //       List accessPersList = n[1].toString().split(',');

    //       for (String accessItem in accessPersList){
    //         accessPersItemList.add(accessItem.replaceAll('me', '').trim());
    //       }
    //       b+=1;
    //     }
    //     else{
    //       b+=1;
    //       continue;
    //     }
    //   }

    //   print(accessResItemList);
    //   print(accessPersItemList);

    //   userPermMap[accessStr] = [];

    //   j+=1;
    // }

    // var aclDataList = aclResStr.split('\n');
    // Map permUserMap = {};

    // for (var i = 0; i < aclDataList.length; i++) {
    //   String dataItem = aclDataList[i];

    //   if(dataItem.contains('@prefix') && dataItem.contains('/card#>')){
    //     var itemList = dataItem.split(' ');
    //     permUserMap[itemList[1]] = itemList[2].substring(0, itemList[2].length - 1);
    //   }
    // }

    //   if (dataItem.contains(';')) {
    //     var itemList = dataItem.split(';');
    //     for (var j = 0; j < itemList.length; j++) {
    //       String item = itemList[j];
    //       rdfDataList.add(item);
    //     }
    //   } else {
    //     rdfDataList.add(dataItem);
    //   }

    //   if (dataItem.contains('<http://www.w3.org/ns/auth/acl#>')) {
    //     var itemList = dataItem.split(' ');
    //     aclPrefix = itemList[1];
    //   }

    //   if (dataItem.contains('</profile/card#>')) {
    //     var itemList = dataItem.split(' ');
    //     profilePrefix = itemList[1];
    //   }
    // }
    return [userNameMap, userPermMap];
  }

  List<dynamic> divideRdfData(String aclResStr) {
    List<String> rdfDataList = [];
    // String aclPrefix = '';
    // String profilePrefix = '';

    var aclDataList = aclResStr.split('\n');

    for (var i = 0; i < aclDataList.length; i++) {
      String dataItem = aclDataList[i];
      if (dataItem.contains(';')) {
        var itemList = dataItem.split(';');
        for (var j = 0; j < itemList.length; j++) {
          String item = itemList[j];
          rdfDataList.add(item);
        }
      } else {
        rdfDataList.add(dataItem);
      }

      /// Temporarily comment out for unused variables
      // if (dataItem.contains('<http://www.w3.org/ns/auth/acl#>')) {
      //   var itemList = dataItem.split(' ');
      //   aclPrefix = itemList[1];
      // }

      // if (dataItem.contains('</profile/card#>')) {
      //   var itemList = dataItem.split(' ');
      //   profilePrefix = itemList[1];
      // }
    }
    return [rdfDataList];
  }
}

